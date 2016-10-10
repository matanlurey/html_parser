part of html_parser.src.nodes;

/// Element node AST.
class Element extends Node {
  /// Attributes of the element.
  final List<Attribute> attributes;

  @override
  final List<Node> childNodes;

  /// Name of the element.
  final String tagName;

  /// <
  final HtmlToken tagOpenStartToken;

  /// <...>
  final HtmlToken tagNameToken;

  /// >
  final HtmlToken tagOpenEndToken;

  /// </
  final HtmlToken tagCloseStartToken;

  /// </...>
  final HtmlToken tagCloseNameToken;

  /// </...>
  final HtmlToken tagCloseEndToken;

  /// Create a new element.
  Element(this.tagName, {List<Attribute> attributes, List<Node> childNodes})
      : this.attributes = attributes ?? <Attribute>[],
        this.childNodes = childNodes ?? <Node>[],
        this.tagOpenStartToken = null,
        this.tagNameToken = null,
        this.tagOpenEndToken = null,
        this.tagCloseStartToken = null,
        this.tagCloseNameToken = null,
        this.tagCloseEndToken = null;

  /// Create a new element from HTML tokens.
  Element.fromTokens(
    this.tagOpenStartToken,
    HtmlToken tagNameToken,
    this.tagOpenEndToken, {
    List<Attribute> attributes,
    List<Node> childNodes,
    this.tagCloseStartToken,
    this.tagCloseNameToken,
    this.tagCloseEndToken,
  })
      : this.tagNameToken = tagNameToken,
        this.attributes = attributes ?? <Attribute>[],
        this.childNodes = childNodes ?? <Node>[],
        this.tagName = tagNameToken.value;

  @override
  bool operator ==(o) =>
      o is Element &&
      o.tagName == tagName &&
      const ListEquality().equals(childNodes, o.childNodes);

  @override
  int get hashCode =>
      _combine(const ListEquality().hash(childNodes), tagName.hashCode);

  /// Tag open source.
  SourceSpan get tagOpenSource {
    return tagOpenStartToken.source.union(tagNameToken.source);
  }

  /// Tag close source.
  SourceSpan get tagCloseSource {
    return tagCloseStartToken.source
        .union(tagCloseNameToken.source)
        .union(tagCloseEndToken.source);
  }
}
