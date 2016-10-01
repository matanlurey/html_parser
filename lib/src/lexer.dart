import 'package:charcode/charcode.dart';
import 'package:source_span/source_span.dart';
import 'package:string_scanner/string_scanner.dart';

/// A parsed HTML token.
abstract class HtmlToken {
  /// Where the token is from.
  SourceSpan get source;

  /// The token type.
  HtmlTokenType get type;

  /// String value of the token, if any.
  String get value;
}

/// Internal implementation of [HtmlToken].
class HtmlTokenImpl implements HtmlToken {
  @override
  final SourceSpan source;

  @override
  final HtmlTokenType type;

  /// Comment token.
  factory HtmlTokenImpl.comment(SourceSpan source) =>
      new HtmlTokenImpl._(HtmlTokenType.comment, source);

  /// Text token.
  factory HtmlTokenImpl.text(SourceSpan source) =>
      new HtmlTokenImpl._(HtmlTokenType.text, source);

  /// Before `<` token.
  factory HtmlTokenImpl.tagOpenStart(SourceSpan source) =>
      new HtmlTokenImpl._(HtmlTokenType.tagOpenStart, source);

  /// After `<` token.
  factory HtmlTokenImpl.tagOpenEnd(SourceSpan source) =>
      new HtmlTokenImpl._(HtmlTokenType.tagOpenEnd, source);

  /// Between `<` and `>`.
  factory HtmlTokenImpl.tagName(SourceSpan source) =>
      new HtmlTokenImpl._(HtmlTokenType.tagName, source);

  /// Before `>` token.
  factory HtmlTokenImpl.tagCloseStart(SourceSpan source) =>
      new HtmlTokenImpl._(HtmlTokenType.tagCloseStart, source);

  /// After `>` token.
  factory HtmlTokenImpl.tagCloseEnd(SourceSpan source) =>
      new HtmlTokenImpl._(HtmlTokenType.tagCloseEnd, source);

  HtmlTokenImpl._(this.type, this.source);

  @override
  String get value => source.text;

  @override
  String toString() =>
      'HtmlToken {' +
      {
        'source': source,
        'type': type,
        'value': value,
      }.toString() +
      '}';
}

/// Different types of [HtmlToken].
enum HtmlTokenType {
  /// Text.
  text,

  /// `<`
  tagOpenStart,

  /// `>`
  tagOpenEnd,

  /// A name between `<` and `>`.
  tagName,

  /// `</`
  tagCloseStart,

  /// `>` after `</`
  tagCloseEnd,

  /// <!--VALUE-->
  comment,
}

/// Error.
class HtmlTokenError {
  /// Readable error message.
  final String message;

  /// Where the token is from.
  final SourceSpan source;

  /// The token type.
  final HtmlTokenType type;

  HtmlTokenError._(this.message, this.type, [this.source]);
}

/// What the [HtmlLexer] is doing.
enum HtmlLexerState {
  /// Scanning text.
  scanningText,

  /// Scanning open tag.
  scanningOpenTag,

  /// Scanning close tag.
  scanningCloseTag,

  /// Scanning a comment.
  scanningComment,
}

/// Produces [HtmlToken]s from a [String].
class HtmlLexer {
  final StringScanner _scanner;

  HtmlLexerState _state = HtmlLexerState.scanningText;
  int _sentinel = 0;

  /// Create a new [HtmlLexer] to lex [contents] from [sourceUrl].
  factory HtmlLexer(String contents, {/*String|Uri*/ sourceUrl}) {
    return new HtmlLexer._fromScanner(
        new StringScanner(contents, sourceUrl: sourceUrl));
  }

  // An HtmlTokenizer wraps a StringScanner instance.
  HtmlLexer._fromScanner(this._scanner);

  // Creates a source span based on start --> _scanner.position.
  SourceSpan _span() {
    final span = new SourceSpan(
      new SourceLocation(
        _sentinel,
        sourceUrl: _scanner.sourceUrl,
      ),
      new SourceLocation(
        _scanner.position,
        sourceUrl: _scanner.sourceUrl,
      ),
      _scanner.substring(_sentinel),
    );
    _reset();
    return span;
  }

  SourceSpan _point([int offset = 0]) {
    final span = new SourceLocation(_scanner.position + offset,
            sourceUrl: _scanner.sourceUrl)
        .pointSpan();
    _reset();
    return span;
  }

  void _reset() {
    _sentinel = _scanner.position;
  }

  /// Returns a lazy [Iterable<HtmlToken>].
  Iterable<HtmlToken> tokenize({void onError(HtmlTokenError error)}) sync* {
    bool hasTextSpan() => _scanner.position > _sentinel;
    while (!_scanner.isDone) {
      var index = _scanner.position;
      switch (_state) {
        case HtmlLexerState.scanningText:
          if (_scanner.peekChar() == $lt) {
            if (hasTextSpan()) {
              yield new HtmlTokenImpl.text(_span());
            }
            if (_scanner.peekChar(1) == $exclamation &&
                _scanner.peekChar(2) == $dash &&
                _scanner.peekChar(3) == $dash) {
              _scanner.readChar();
              _scanner.readChar();
              _scanner.readChar();
              _state = HtmlLexerState.scanningComment;
              _reset();
              break;
            }
            _scanner.readChar();
            if (_scanner.scanChar($slash)) {
              _state = HtmlLexerState.scanningCloseTag;
              yield new HtmlTokenImpl.tagCloseStart(_point());
            } else {
              _state = HtmlLexerState.scanningOpenTag;
              _sentinel++;
              yield new HtmlTokenImpl.tagOpenStart(_point());
            }
          }
          break;
        case HtmlLexerState.scanningOpenTag:
          if (_scanner.peekChar() == $gt) {
            yield new HtmlTokenImpl.tagName(_span());
            _scanner.readChar();
            yield new HtmlTokenImpl.tagOpenEnd(_point());
            _state = HtmlLexerState.scanningText;
          }
          break;
        case HtmlLexerState.scanningCloseTag:
          if (_scanner.peekChar() == $gt) {
            yield new HtmlTokenImpl.tagName(_span());
            _scanner.readChar();
            yield new HtmlTokenImpl.tagCloseEnd(_point());
            _state = HtmlLexerState.scanningText;
          }
          break;
        case HtmlLexerState.scanningComment:
          if (_scanner.peekChar(0) == $dash &&
              _scanner.peekChar(1) == $dash &&
              _scanner.peekChar(2) == $gt) {
            _sentinel++;
            yield new HtmlTokenImpl.comment(_span());
            _scanner.readChar();
            _scanner.readChar();
            _scanner.readChar();
            _reset();
            _state = HtmlLexerState.scanningText;
          }
          break;
      }
      if (index == _scanner.position) {
        _scanner.readChar();
      }
    }
    if (_state == HtmlLexerState.scanningText && hasTextSpan()) {
      yield new HtmlTokenImpl.text(_span());
    }
  }
}
