import 'package:collection/collection.dart';

import 'lexer.dart';
import 'printer.dart';

int _combine(int hash, int value) {
  hash = 0x1fffffff & (hash + value);
  hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
  return hash ^ (hash >> 6);
}

/// Base node AST.
abstract class Node {
  /// Child nodes if any.
  List<Node> get childNodes;

  @override
  String toString() => nodeToString(this);
}

/// Comment node AST.
class Comment extends Node {
  /// Text within the comment.
  final String value;

  /// Create a comment.
  Comment(this.value);

  @override
  List<Node> get childNodes => const [];
}

/// Document fragment node AST.
class Fragment extends Node {
  @override
  final List<Node> childNodes;

  /// Create a fragment.
  Fragment(this.childNodes);

  @override
  bool operator ==(o) =>
      o is Fragment && const ListEquality().equals(childNodes, o.childNodes);

  @override
  int get hashCode => const ListEquality().hash(childNodes);
}

/// Attribute node AST.
class Attribute extends Node {
  /// Token before the attribute, if any.
  final HtmlToken before;

  /// Name of the attribute.
  final String name;

  /// Value of the attribute.
  final String value;

  /// Create an attribute.
  Attribute(this.name, [this.value, this.before]);

  @override
  List<Node> get childNodes => const [];

  @override
  bool operator ==(o) => o is Attribute && o.name == name && o.value == value;

  @override
  int get hashCode => _combine(name.hashCode, value.hashCode);
}

/// Element node AST.
class Element extends Node {
  /// Attributes of the element.
  final List<Attribute> attributes;

  @override
  final List<Node> childNodes;

  /// Name of the element.
  final String tagName;

  /// Create a new element.
  Element(this.tagName, {List<Attribute> attributes, List<Node> childNodes})
      : this.attributes = attributes ?? <Attribute>[],
        this.childNodes = childNodes ?? <Node>[];

  @override
  bool operator ==(o) =>
      o is Element &&
      o.tagName == tagName &&
      const ListEquality().equals(childNodes, o.childNodes);

  @override
  int get hashCode =>
      _combine(const ListEquality().hash(childNodes), tagName.hashCode);
}

/// Text node AST.
class Text extends Node {
  /// Text value.
  final String value;

  /// Create a text node.
  Text(this.value);

  @override
  List<Node> get childNodes => const [];

  @override
  bool operator ==(o) => o is Text && o.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Returns [node] as an HTML string.
String nodeToString(Node node) => (new PrinterHtmlVisitor()..visitNode(node)).toString();
