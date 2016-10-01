import 'src/parser.dart';
import 'src/nodes.dart' show Fragment;
export 'src/nodes.dart' show Element, Fragment, Node, Text, nodeToString;

/// Parses [html] into a DOM tree.
///
/// __Example use__:
///     import 'package:html_parser/html_parser.dart';
///
///     void main() {
///       var fragment = parseHtml('<div>Hello World</div>');
///
///       // Prints: '<div>Hello World</div>'
///       print(nodeToString(fragment));
///     }
Fragment parseHtml(String html, {/* Uri | String */ sourceUrl}) {
  return const HtmlParser().parse(html, sourceUrl: sourceUrl);
}
