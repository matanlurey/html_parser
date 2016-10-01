import 'package:html_parser/src/nodes.dart';
import 'package:html_parser/src/parser.dart';
import 'package:test/test.dart';

void main() {
  test('should work for a trivial case', () {
    /*
       0: <strong>Hello World</strong>
     */
    final fragment = const HtmlParser().parse('<strong>Hello World</strong>');
    expect(fragment.childNodes, [
      new Element('strong', [
        new Text('Hello World'),
      ]),
    ]);
  });

  test('should work for a nested case', () {
    /*
      0: <div>
      1:   <span>Hello world</span>
      2: </div>
      3:
    */
    const html = '<div>\n  <span>Hello World</span>\n</div>\n';
    final fragment = const HtmlParser().parse(html);
    expect(nodeToString(fragment), html);
    expect(fragment.childNodes, [
      new Element('div', [
        new Text('\n  '),
        new Element('span', [new Text('Hello World')]),
        new Text('\n'),
      ]),
      new Text('\n'),
    ]);
  });

  test('should work for a very nested complicated case', () {
    const html = r'''
      <div>
        <span>
          <span>Hello</span>World
        </span>
        <button>I am a button</button>
      </div>
    ''';
    final fragment = const HtmlParser().parse(html);
    expect(nodeToString(fragment), html);
  });
}
