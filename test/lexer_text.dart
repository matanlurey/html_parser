import 'package:html_parser/src/lexer.dart';
import 'package:html_parser/src/lexer_error.dart';
import 'package:test/test.dart';

void main() {
  group('$HtmlLexer', () {
    test('should work for a trivial case', () {
      final lexer = new HtmlLexer('<strong>Hello</strong>');
      expect(_toTypes(lexer).toList(), [
        HtmlTokenType.tagOpenStart,
        HtmlTokenType.tagName,
        HtmlTokenType.tagOpenEnd,
        HtmlTokenType.text,
        HtmlTokenType.tagCloseStart,
        HtmlTokenType.tagName,
        HtmlTokenType.tagCloseEnd,
      ]);
    });
    test('it should throw basic missmatched tag errors', () {
      final raw = '<h1>\n<p [baz]="foo"> This is some markup</p>\n<div>some mo</div></h1>>';
      final lexer = new HtmlLexer(raw);
      expect(() => lexer.tokenize().toList(),
        throwsA(predicate(
          (e) => e is LexerError && e.kind == LexerErrorKind.misMatchedClose)));
    });
  });
}

Iterable<HtmlTokenType> _toTypes(HtmlLexer htmlLexer) =>
    htmlLexer.tokenize().map/*<HtmlTokenType>*/((t) => t.type);
