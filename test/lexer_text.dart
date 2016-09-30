import 'package:html_parser/src/lexer.dart';
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
  });
}

Iterable<HtmlTokenType> _toTypes(HtmlLexer htmlLexer) =>
    htmlLexer.tokenize().map/*<HtmlTokenType>*/((t) => t.type);
