part of html_parser.src.lexer;

/// Attribute value token.
class HtmlAttributeValueToken implements HtmlToken {
  @override
  final SourceSpan source;

  /// Create a new attribute value token from [source].
  HtmlAttributeValueToken(this.source);

  @override
  final HtmlTokenType type = HtmlTokenType.attributeValue;

  // Remove quotes from the value.
  @override
  String get value => source.text.substring(1, source.text.length - 1);
}
