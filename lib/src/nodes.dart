library html_parser.src.nodes;

import 'package:collection/collection.dart';
import 'package:source_span/source_span.dart';

import 'lexer.dart';
import 'printer.dart';

part 'nodes/attribute_node.dart';
part 'nodes/element_node.dart';

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
  /// Where the comment was parsed for.
  final HtmlToken token;

  /// Value of the comment.
  final String value;

  /// Create a comment.
  Comment(this.value) : this.token = null;

  /// Create a comment from [token].
  Comment.fromToken(HtmlCommentToken token)
      : this.token = token,
        this.value = token.value;

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

/// Text node AST.
class Text extends Node {
  /// Text token.
  final HtmlTextToken token;

  /// Text value.
  final String value;

  /// Create a text node.
  Text(this.value) : token = null;

  /// Create a text node from a lexed token.
  Text.fromToken(HtmlTextToken token)
      : this.token = token,
        this.value = token.value;

  @override
  List<Node> get childNodes => const [];

  @override
  bool operator ==(o) => o is Text && o.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Returns [node] as an HTML string.
String nodeToString(Node node) =>
    (new PrinterHtmlVisitor()..visitNode(node)).toString();
