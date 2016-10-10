part of html_parser.src.lexer;

/// Text token.
class HtmlTextToken implements HtmlToken {
  @override
  final SourceSpan source;

  /// Create a new text token from [source].
  HtmlTextToken(this.source);

  @override
  final HtmlTokenType type = HtmlTokenType.text;

  @override
  String get value => source.text;
}
