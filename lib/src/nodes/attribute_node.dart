part of html_parser.src.nodes;

/// Attribute node AST.
class Attribute extends Node {
  /// Name of the attribute.
  final String name;

  /// Value of the attribute.
  final String value;

  /// Token before the attribute, if any.
  final HtmlToken beforeToken;

  /// Token of the attribute name.
  final HtmlToken nameToken;

  /// Token before the value, if any.
  final HtmlToken valueStartToken;

  /// Token of the value.
  final HtmlToken valueToken;

  /// Create an attribute.
  Attribute(this.name, [this.value])
      : beforeToken = null,
        nameToken = null,
        valueStartToken = null,
        valueToken = null;

  /// Create an attribute from lexed tokens.
  Attribute.fromTokens(
    HtmlToken beforeToken,
    HtmlToken nameToken, [
    HtmlToken valueStartToken,
    HtmlToken valueToken,
  ])
      : this.beforeToken = beforeToken,
        this.nameToken = nameToken,
        this.valueStartToken = valueStartToken,
        this.valueToken = valueToken,
        this.name = nameToken.value,
        this.value = valueToken?.value;

  @override
  List<Node> get childNodes => const [];

  @override
  bool operator ==(o) => o is Attribute && o.name == name && o.value == value;

  @override
  int get hashCode => _combine(name.hashCode, value.hashCode);

  /// A union of all the tokens that were parsed for this node.
  SourceSpan get source {
    var source = nameToken.source;
    if (valueToken != null) {
      return source.union(valueStartToken.source).union(valueToken.source);
    }
    return source;
  }
}
