import 'package:collection/collection.dart';

int _combine(int hash, int value) {
  hash = 0x1fffffff & (hash + value);
  hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
  return hash ^ (hash >> 6);
}

abstract class Node {
  List<Node> get childNodes;
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

class Element extends Node {
  @override
  final List<Node> childNodes;
  final String tagName;

  Element(this.tagName, [List<Node> childNodes])
      : this.childNodes = childNodes ?? <Node>[];

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
    buffer..write('<')..write(node.tagName)..write('>');
    for (final child in node.childNodes) {
      nodeToString(child, buffer);
    }
    buffer..write('</')..write(node.tagName)..write('>');
  } else if (node is Text) {
    buffer.write(node.value);
  }
  return '';
}
