import 'package:collection/collection.dart';

import 'lexer.dart';

int _combine(int hash, int value) {
  hash = 0x1fffffff & (hash + value);
  hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
  return hash ^ (hash >> 6);
}

abstract class Node {
  List<Node> get childNodes;
}

class Comment extends Node {
  final String value;

  Comment(this.value);

  @override
  List<Node> get childNodes => const [];
}

class Fragment extends Node {
  @override
  final List<Node> childNodes;

  Fragment(this.childNodes);

  @override
  bool operator ==(o) =>
      o is Fragment && const ListEquality().equals(childNodes, o.childNodes);

  @override
  int get hashCode => const ListEquality().hash(childNodes);
}

class Attribute extends Node {
  final HtmlToken before;
  final String name;
  final String value;

  Attribute(this.name, [this.value, this.before]);

  @override
  List<Node> get childNodes => const [];

  @override
  bool operator ==(o) => o is Attribute && o.name == name && o.value == value;

  @override
  int get hashCode => _combine(name.hashCode, value.hashCode);
}

class Element extends Node {
  final List<Attribute> attributes;

  @override
  final List<Node> childNodes;
  final String tagName;

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

  @override
  String toString() => '<$tagName>${childNodes.join('')}</$tagName>';
}

class Text extends Node {
  final String value;

  Text(this.value);

  @override
  List<Node> get childNodes => const [];

  @override
  bool operator ==(o) => o is Text && o.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}

String nodeToString(Node node, [StringBuffer buffer]) {
  if (node is Fragment) {
    buffer ??= new StringBuffer();
    for (final child in node.childNodes) {
      nodeToString(child, buffer);
    }
    return buffer.toString();
  }
  if (node is Element) {
    buffer..write('<')..write(node.tagName);
    for (final attr in node.attributes) {
      buffer..write(attr.before.value)..write(attr.name);
      if (attr.value != null) {
        buffer..write('"')..write(attr.value)..write('"');
      }
    }
    buffer.write('>');
    for (final child in node.childNodes) {
      nodeToString(child, buffer);
    }
    buffer..write('</')..write(node.tagName)..write('>');
  } else if (node is Text) {
    buffer.write(node.value);
  } else if (node is Comment) {
    buffer..write('<!--')..write(node.value)..write('-->');
  }
  return '';
}
