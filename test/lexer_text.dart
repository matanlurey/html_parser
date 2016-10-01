import 'package:html_parser/src/lexer.dart';
import 'package:html_parser/src/error.dart';
import 'package:test/test.dart';

void main() {
  group('$HtmlLexer', () {
    test('should lex an element with a text node', () {
      final lex = new HtmlLexer('<strong>Hello</strong>');
      expect(_toTypes(lex).toList(), [
        HtmlTokenType.tagOpenStart,
        HtmlTokenType.tagName,
        HtmlTokenType.tagOpenEnd,
        HtmlTokenType.text,
        HtmlTokenType.tagCloseStart,
        HtmlTokenType.tagName,
        HtmlTokenType.tagCloseEnd,
      ]);
    });
    test('should lex a tag name correctly', () {
      final lex = new HtmlLexer('<strong>Hello</strong>');
      final token = lex.tokenize().elementAt(1);
      expect(token.type, HtmlTokenType.tagName);
      expect(token.value, 'strong');
    });

    test('should lex nested HTML with newlines and indents', () {
      final lex = new HtmlLexer('<div>\n  <span>Hello World</span>\n</div>\n');
      expect(_toTypes(lex).toList(), [
        HtmlTokenType.tagOpenStart, // "<"
        HtmlTokenType.tagName, // "div"
        HtmlTokenType.tagOpenEnd, // ">"
        HtmlTokenType.text, // "\n  "
        HtmlTokenType.tagOpenStart, // "<"
        HtmlTokenType.tagName, // "span"
        HtmlTokenType.tagOpenEnd, // ">"
        HtmlTokenType.text, // "Hello World"
        HtmlTokenType.tagCloseStart, // "</"
        HtmlTokenType.tagName, // "span"
        HtmlTokenType.tagCloseEnd, // ">"
        HtmlTokenType.text, // "\n"
        HtmlTokenType.tagCloseStart, // "<"
        HtmlTokenType.tagName, // "div"
        HtmlTokenType.tagCloseEnd, // "</"
        HtmlTokenType.text, // "\n"
      ]);
    });
    test('it should throw basic missmatched tag errors', () {
      final raw =
          '<h1>\n<p [baz]="foo"> This is markup</p>\n<div>some mo</div></h1>>';
      final lexer = new HtmlLexer(raw);
      expect(
          () => lexer.tokenize().toList(),
          throwsA(predicate((e) =>
              e is LexerError && e.kind == LexerErrorKind.misMatchedClose)));
    });
    test('supports lexing comments', () {
      final lex = new HtmlLexer('<div>Hello<!--World--></div>');
      expect(_toTypes(lex).toList(), [
        HtmlTokenType.tagOpenStart,
        HtmlTokenType.tagName,
        HtmlTokenType.tagOpenEnd,
        HtmlTokenType.text,
        HtmlTokenType.comment,
        HtmlTokenType.tagCloseStart,
        HtmlTokenType.tagName,
        HtmlTokenType.tagCloseEnd,
      ]);
    });
  });
}

Iterable<HtmlTokenType> _toTypes(HtmlLexer htmlLexer) =>
    htmlLexer.tokenize().map/*<HtmlTokenType>*/((t) => t.type);
