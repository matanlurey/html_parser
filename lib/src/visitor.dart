import 'nodes.dart';

/// A visitor pattern for an HTML syntax tree.
abstract class HtmlVisitor<T> {
  /// Default constructor.
  const HtmlVisitor();

  /// Create a new visitor by defining closures for implementations.
  static HtmlVisitor<Node> create({
    VisitAttribute<Node> visitAttribute,
    VisitChildren<Node> visitChildren,
    VisitComment<Node> visitComment,
    VisitElement<Node> visitElement,
    VisitFragment<Node> visitFragment,
    VisitNode<Node> visitNode,
    VisitText<Node> visitText,
  }) => new _AnonymousHtmlVisitor(
    visitAttribute: visitAttribute,
    visitChildren: visitChildren,
    visitComment: visitComment,
    visitElement: visitElement,
    visitFragment: visitFragment,
    visitNode: visitNode,
    visitText: visitText,
  );

  /// Identity visitor.
  static const HtmlVisitor<Node> identity = const _IdentityHtmlVisitor();

  /// Visit [attribute].
  T visitAttribute(Attribute attribute) => null;

  /// Visits each of [nodes].
  T visitChildren(Iterable<Node> nodes) {
    for (final node in nodes) {
      visitNode(node);
    }
    return null;
  }

  /// Visit [comment].
  T visitComment(Comment comment) => null;

  /// Visit [element].
  T visitElement(Element element) {
    visitChildren(element.attributes);
    visitChildren(element.childNodes);
    return null;
  }

  /// Visit [fragment].
  T visitFragment(Fragment fragment) => visitChildren(fragment.childNodes);

  /// Visit [node].
  T visitNode(Node node) {
    if (node is Attribute) {
      return visitAttribute(node);
    }
    if (node is Comment) {
      return visitComment(node);
    }
    if (node is Element) {
      return visitElement(node);
    }
    if (node is Fragment) {
      return visitFragment(node);
    }
    if (node is Text) {
      return visitText(node);
    }
    if (node == null) {
      return null;
    }
    assert(() {
      throw new UnsupportedError('Unknown: ${node.runtimeType}');
    });
    return null;
  }

  /// Visit [text].
  T visitText(Text text) => null;
}

class _IdentityHtmlVisitor implements HtmlVisitor<Node> {
  const _IdentityHtmlVisitor();

  @override
  Node visitAttribute(Attribute attribute) => attribute;

  @override
  Node visitChildren(Iterable<Node> nodes) => null;

  @override
  Node visitComment(Comment comment) => comment;

  @override
  Node visitElement(Element element) => element;

  @override
  Node visitFragment(Fragment fragment) => fragment;

  @override
  Node visitNode(Node node) => node;

  @override
  Node visitText(Text text) => text;
}

/// Visits [attribute] nodes.
typedef T VisitAttribute<T>(Attribute attribute);

/// Visits each [nodes].
typedef T VisitChildren<T>(Iterable<Node> nodes);

/// Visits [comment] nodes.
typedef T VisitComment<T>(Comment comment);

/// Visits [element] nodes.
typedef T VisitElement<T>(Element element);

/// Visits [fragment] nodes.
typedef T VisitFragment<T>(Fragment fragment);

/// Visits any [node].
typedef T VisitNode<T>(Node node);

/// Visits [text] nodes.
typedef T VisitText<T>(Text text);

class _AnonymousHtmlVisitor extends _IdentityHtmlVisitor {
  final VisitAttribute<Node> _visitAttribute;
  final VisitChildren<Node> _visitChildren;
  final VisitComment<Node> _visitComment;
  final VisitElement<Node> _visitElement;
  final VisitFragment<Node> _visitFragment;
  final VisitNode<Node> _visitNode;
  final VisitText<Node> _visitText;

  const _AnonymousHtmlVisitor({
    VisitAttribute<Node> visitAttribute,
    VisitChildren<Node> visitChildren,
    VisitComment<Node> visitComment,
    VisitElement<Node> visitElement,
    VisitFragment<Node> visitFragment,
    VisitNode<Node> visitNode,
    VisitText<Node> visitText,
  }) :
      _visitAttribute = visitAttribute,
      _visitChildren = visitChildren,
      _visitComment = visitComment,
      _visitElement = visitElement,
      _visitFragment = visitFragment,
      _visitNode = visitNode,
      _visitText = visitText,
      super();

  @override
  Node visitAttribute(Attribute attribute) {
    if (_visitAttribute != null) {
      return super.visitAttribute(_visitAttribute(attribute));
    }
    return super.visitAttribute(attribute);
  }

  @override
  Node visitChildren(Iterable<Node> nodes) {
    if (_visitChildren != null) {
      return _visitChildren(nodes);
    }
    return super.visitChildren(nodes);
  }

  @override
  Node visitComment(Comment comment) {
    if (_visitComment != null) {
      return super.visitComment(_visitComment(comment));
    }
    return super.visitComment(comment);
  }

  @override
  Node visitElement(Element element) {
    if (_visitElement != null) {
      return super.visitElement(_visitElement(element));
    }
    return super.visitElement(element);
  }

  @override
  Node visitFragment(Fragment fragment) {
    if (_visitFragment != null) {
      return super.visitFragment(_visitFragment(fragment));
    }
    return super.visitFragment(fragment);
  }

  @override
  Node visitNode(Node node) {
    if (_visitNode != null) {
      return super.visitNode(_visitNode(node));
    }
    return super.visitNode(node);
  }

  @override
  Node visitText(Text text) {
    if (_visitText != null) {
      return super.visitText(_visitText(text));
    }
    return super.visitText(text);
  }
}
