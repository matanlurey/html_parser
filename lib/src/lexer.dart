library html_parser.src.lexer;

import 'package:charcode/charcode.dart';
import 'package:source_span/source_span.dart';
import 'package:string_scanner/string_scanner.dart';

import 'error.dart';
import 'utils.dart';

part 'tokens/attribute_value_token.dart';
part 'tokens/comment_token.dart';
part 'tokens/text_token.dart';

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

  /// Before an attribute name.
  factory HtmlTokenImpl.attributeNameStart(SourceSpan source) =>
      new HtmlTokenImpl._(HtmlTokenType.attributeNameStart, source);

  /// An attribute name.
  factory HtmlTokenImpl.attributeName(SourceSpan source) =>
      new HtmlTokenImpl._(HtmlTokenType.attributeName, source);

  /// Before an attribute value.
  factory HtmlTokenImpl.attributeValueStart(SourceSpan source) =>
      new HtmlTokenImpl._(HtmlTokenType.attributeValueStart, source);

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

  /// Before the name of an attribute.
  attributeNameStart,

  /// A full attribute name.
  attributeName,

  /// Before the value of an attribute.
  attributeValueStart,

  /// An attribute value in "'s (and implicitly the end of the attribute).
  attributeValue,
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

  /// Scanning an attribute.
  scanningForAttribute,

  /// Scanning an attribute name.
  scanningAttributeName,

  /// Scanning an attribute value.
  scanningAttributeValue,
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
  SourceSpan _span([int startOffset = 0, int endOffset = 0]) {
    final span = new SourceSpan(
      new SourceLocation(
        _sentinel + startOffset,
        sourceUrl: _scanner.sourceUrl,
      ),
      new SourceLocation(
        _scanner.position + endOffset,
        sourceUrl: _scanner.sourceUrl,
      ),
      _scanner.substring(
        _sentinel + startOffset,
        _scanner.position + endOffset,
      ),
    );
    _reset();
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
              yield new HtmlTextToken(_span());
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
          } else if (_scanner.scanChar($gt)) {
            throw new LexerError(
                _errorContext(), LexerErrorKind.misMatchedClose);
          }
          break;
        case HtmlLexerState.scanningOpenTag:
          if (_scanner.peekChar() == $gt) {
            yield new HtmlTokenImpl.tagName(_span());
            _scanner.readChar();
            yield new HtmlTokenImpl.tagOpenEnd(_point());
            _state = HtmlLexerState.scanningText;
          } else if (isWhitespace(_scanner.peekChar())) {
            yield new HtmlTokenImpl.tagName(_span());
            _state = HtmlLexerState.scanningForAttribute;
          } else if (_scanner.scanChar($lt)) {
            throw new LexerError(
                _errorContext(), LexerErrorKind.misMatchedOpen);
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
            yield new HtmlCommentToken(_span(-4, 3));
            _scanner.readChar();
            _scanner.readChar();
            _scanner.readChar();
            _reset();
            _state = HtmlLexerState.scanningText;
          }
          break;
        case HtmlLexerState.scanningForAttribute:
          if (_scanner.peekChar() == $gt) {
            _scanner.readChar();
            yield new HtmlTokenImpl.tagOpenEnd(_span());
            _state = HtmlLexerState.scanningText;
          } else if (!isWhitespace(_scanner.peekChar())) {
            yield new HtmlTokenImpl.attributeNameStart(_span());
            _state = HtmlLexerState.scanningAttributeName;
          } else {
            // TODO: Error.
          }
          break;
        case HtmlLexerState.scanningAttributeName:
          if (isWhitespace(_scanner.peekChar()) || _scanner.peekChar() == $gt) {
            yield new HtmlTokenImpl.attributeName(_span());
            if (_scanner.scanChar($gt)) {
              yield new HtmlTokenImpl.tagOpenEnd(_span());
              _state = HtmlLexerState.scanningText;
            } else {
              _scanner.readChar();
              _state = HtmlLexerState.scanningForAttribute;
            }
          } else if (_scanner.scanChar($equal)) {
            yield new HtmlTokenImpl.attributeName(_span());
            while (!_scanner.scanChar($double_quote)) {
              if (!isWhitespace(_scanner.readChar())) {
                // TODO: Make this a pretty contextual error message.
                throw new FormatException('Unexpected character parsing value');
              }
            }
            yield new HtmlTokenImpl.attributeValueStart(_span());
            _state = HtmlLexerState.scanningAttributeValue;
            _reset();
          } else if (_scanner.scanChar($gt)) {
            yield new HtmlTokenImpl.tagOpenEnd(_span());
            _state = HtmlLexerState.scanningText;
          }
          break;
        case HtmlLexerState.scanningAttributeValue:
          while (true) {
            if (_scanner.peekChar() == $double_quote) {
              break;
            }
            _scanner.readChar();
          }
          yield new HtmlAttributeValueToken(_span(-1, 1));
          _scanner.readChar();
          _reset();
          _state = HtmlLexerState.scanningForAttribute;
          break;
      }
      if (index == _scanner.position) {
        _scanner.readChar();
      }
    }
    if (_state == HtmlLexerState.scanningText && hasTextSpan()) {
      yield new HtmlTextToken(_span());
    }
  }
}
