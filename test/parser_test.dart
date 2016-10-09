import 'package:html_parser/src/nodes.dart';
import 'package:html_parser/src/parser.dart';
import 'package:html_parser/src/visitor.dart';
import 'package:test/test.dart';

void main() {
  test('should work for a trivial case', () {
    /*
       0: <strong>Hello World</strong>
     */
    final fragment = const HtmlParser().parse('<strong>Hello World</strong>');
    expect(fragment.childNodes, [
      new Element('strong', childNodes: [
        new Text('Hello World'),
      ]),
    ]);

    Text text = fragment.childNodes.first.childNodes.first;
    final offset = '<strong>'.length;
    expect(text.token.source.start.offset, offset);
    expect(text.token.source.end.offset, 'Hello World'.length + offset);
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
      new Element('div', childNodes: [
        new Text('\n  '),
        new Element('span', childNodes: [new Text('Hello World')]),
        new Text('\n'),
      ]),
      new Text('\n'),
    ]);

    Element span = fragment.childNodes.first.childNodes[1];
    expect(
      span.tagOpenSource.message(''),
      'line 1, column 10: \n'
          'span\n'
          '^^^^',
    );
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

  test('should parse comments', () {
    const html = '<div>Hello<!--World--></div>';
    final fragment = const HtmlParser().parse(html);
    expect(nodeToString(fragment), html);

    Comment comment = fragment.childNodes.first.childNodes[1];
    final offset = '<div>Hello'.length;
    expect(comment.token.source.start.offset, offset);
    expect(comment.token.source.end.offset, '<!--World-->'.length + offset);
  });

  test('should parse attributes', () {
    const html = '<button class="fancy" disabled></button>';
    final fragment = const HtmlParser().parse(html);
    expect(fragment.childNodes, [
      new Element('button', attributes: [
        new Attribute('class', 'fancy'),
        new Attribute('disabled'),
      ])
    ]);
    expect(nodeToString(fragment), html);
  });

  test('should parse attributes with whitespace', () {
    const html = r'''
      <button
        [disabled]="disabled"
        (click)="onClick">
          Hello World
      </button>
    ''';
    final fragment = const HtmlParser().parse(html);
    expect(nodeToString(fragment), html);

    Element button = fragment.childNodes[1];
    Attribute attribute = button.attributes.first;
    expect(
      attribute.source.message(''),
      'line 1, column 23: \n'
          '[disabled]="disabled"\n'
          '^^^^^^^^^^^^^^^^^^^^^',
    );
  });

  test('should supports void elements', () {
    const html = 'Hello<br>World<div><hr></div>';
    final fragment = const HtmlParser().parse(html);
    expect(fragment.childNodes, [
      new Text('Hello'),
      new Element('br'),
      new Text('World'),
      new Element('div', childNodes: [
        new Element('hr'),
      ]),
    ]);
  });

  test('should parse attributes', () {
    const html = '<button class="fancy" disabled></button>';
    final fragment = const HtmlParser().parse(html);
    expect(fragment.childNodes, [
      new Element('button', attributes: [
        new Attribute('class', 'fancy'),
        new Attribute('disabled'),
      ])
    ]);
    expect(nodeToString(fragment), html);
  });

  test('should parse attributes with whitespace', () {
    const html = r'''
      <button
        [disabled]="disabled"
        (click)="onClick">
          Hello World
      </button>
    ''';
    final fragment = const HtmlParser().parse(html);
    expect(nodeToString(fragment), html);
  });

  test('should support a streaming interceptor', () {
    const html = r'<div><!--Hello-->World</div>';
    final fragment = new HtmlParser().parse(
      html,
      visitor: HtmlVisitor.create(
        visitComment: (Comment comment) => null,
      ),
    );
    expect(nodeToString(fragment), '<div>World</div>');
  });
}
