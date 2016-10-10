import 'nodes.dart';
import 'visitor.dart';

/// An implementation of [HtmlVisitor] that writes an HTML string.
///
/// After visiting nodes, call [toString]:
///     print(new PrintedHtmlVisitor()..visit(node));
class PrinterHtmlVisitor extends HtmlVisitor<Null> {
  final StringBuffer _buffer;

  /// Create a new visitor that outputs HTML.
  PrinterHtmlVisitor([StringBuffer buffer])
      : _buffer = buffer ?? new StringBuffer();

  @override
  Null visitAttribute(Attribute attribute) {
    _buffer..write(attribute.beforeToken.value)..write(attribute.name);
    if (attribute.value != null) {
      _buffer..write('"')..write(attribute.value)..write('"');
    }
    return null;
  }

  @override
  Null visitComment(Comment comment) {
    _buffer..write('<!--')..write(comment.value)..write('-->');
    return null;
  }

  @override
  Null visitElement(Element element) {
    _buffer..write('<')..write(element.tagName);
    visitChildren(element.attributes);
    _buffer.write('>');
    visitChildren(element.childNodes);
    _buffer..write('</')..write(element.tagName)..write('>');
    return null;
  }

  @override
  Null visitText(Text text) {
    _buffer.write(text.value);
    return null;
  }

  @override
  String toString() => _buffer.toString();
}
