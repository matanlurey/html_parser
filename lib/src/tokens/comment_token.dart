part of html_parser.src.lexer;

/// Comment token.
class HtmlCommentToken implements HtmlToken {
  @override
  final SourceSpan source;

  /// Create a new comment token from [source].
  HtmlCommentToken(this.source);

  @override
  final HtmlTokenType type = HtmlTokenType.comment;

  // Remove <!-- and --> from the value.
  @override
  String get value => source.text.substring(4, source.text.length - 3);
}
