import 'package:html_parser/html_parser.dart';
import 'package:test/test.dart';

void main() {
  group('$HtmlVisitor', () {
    test('can traverse a tree of HTML nodes', () {
      final fragment = parseHtml(r'''
        <div>
          <div>
            <!-- A panel -->
            <ul>
              <li>
                <!-- A item -->
              </li>
            </ul>
          </div>
        </div>
      ''');
      final comments = <String>[];
      new _TestHtmlVisitor(comments).visitNode(fragment);
      expect(comments, [
        ' A panel ',
        ' A item ',
      ]);
    });
  });
}

class _TestHtmlVisitor extends HtmlVisitor {
  final List<String> comments;

  _TestHtmlVisitor(this.comments);

  @override
  visitComment(Comment comment) {
    comments.add(comment.value);
  }
}
