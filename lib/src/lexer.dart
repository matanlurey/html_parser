import 'package:charcode/charcode.dart';
import 'package:source_span/source_span.dart';
import 'package:string_scanner/string_scanner.dart';

import 'lexer_error.dart';

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
  none,

  /// Scanning text.
  scanningText,

  /// Scanning open tag.
  scanningOpenTag,

  /// Scanning close tag.
  scanningCloseTag,

  /// Scanning the tag name in the </...>
  scanningClosingTagName,
}

/// Produces [HtmlToken]s from a [String].
class HtmlLexer {
  final LineScanner _scanner;

  HtmlLexerState _state = HtmlLexerState.scanningText;
  int _sentinel = 0;

  /// Create a new [HtmlLexer] to lex [contents] from [sourceUrl].
  factory HtmlLexer(String contents, {/*String|Uri*/ sourceUrl}) {
    return new HtmlLexer._fromScanner(
        new LineScanner(contents, sourceUrl: sourceUrl));
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
    _sentinel = _scanner.position;
    return span;
  }

  // Creates a source span from the beginning of the line, with line info.
  SourceSpan _errorContext() {
    int start = _scanner.position - _scanner.column;
    int stop = _scanner.position;
    return new SourceSpan(
        new SourceLocation(
          start,
          sourceUrl: _scanner.sourceUrl,
          line: _scanner.line,
        ),
        new SourceLocation(
          stop,
          sourceUrl: _scanner.sourceUrl,
          line: _scanner.line,
        ),
        _scanner.substring(start, stop));
  }

  SourceSpan _point([int offset = 0]) => new SourceLocation(
        _scanner.position + offset,
        sourceUrl: _scanner.sourceUrl,
      )
          .pointSpan();

  /// Returns a lazy [Iterable<HtmlToken>].
  Iterable<HtmlToken> tokenize({void onError(HtmlTokenError error)}) sync* {
    bool hasTextSpan() => _scanner.position - 1 > _sentinel;
    while (!_scanner.isDone) {
      var index = _scanner.position;
      switch (_state) {
        case HtmlLexerState.scanningText:
          if (_scanner.scanChar($lt)) {
            if (hasTextSpan()) {
              yield new HtmlTokenImpl.text(_span());
            }
            if (_scanner.scanChar($slash)) {
              _state = HtmlLexerState.scanningCloseTag;
              yield new HtmlTokenImpl.tagCloseStart(_point());
            } else {
              _state = HtmlLexerState.scanningOpenTag;
              yield new HtmlTokenImpl.tagOpenStart(_point());
            }
          } else if (_scanner.scanChar($gt)) {
            throw new LexerError(
                _errorContext(), LexerErrorKind.misMatchedClose);
          }
          break;
        case HtmlLexerState.scanningOpenTag:
          if (_scanner.scanChar($gt)) {
            yield new HtmlTokenImpl.tagName(_span());
            yield new HtmlTokenImpl.tagOpenEnd(_point());
            _state = HtmlLexerState.scanningText;
          } else if (_scanner.scanChar($lt)) {
            throw new LexerError(
                _errorContext(), LexerErrorKind.misMatchedOpen);
          }
          break;
        case HtmlLexerState.scanningCloseTag:
          if (_scanner.scanChar($gt)) {
            yield new HtmlTokenImpl.tagName(_span());
            yield new HtmlTokenImpl.tagCloseEnd(_point());
            _state = HtmlLexerState.scanningText;
          }
          break;
        default:
          throw new UnimplementedError(
            '$_state ("${new String.fromCharCode(_scanner.peekChar())}")',
          );
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
