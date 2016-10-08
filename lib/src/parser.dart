import 'lexer.dart';
import 'nodes.dart';
import 'utils.dart';
import 'visitor.dart';

/// Parses raw HTML strings into a tree of DOM nodes.
abstract class HtmlParser {
  /// Create a new default [HtmlParser].
  const factory HtmlParser() = _NodeBuilderHtmlParser;

  /// Returns a DOM [Node] by parsing [html].
  ///
  /// If [visitor] is specified, is called incrementally as the tree is built.
  Node parse(String html, {/* Uri | String */ sourceUrl, HtmlVisitor<Node> visitor,});
}

class _NodeBuilderHtmlParser implements HtmlParser {
  const _NodeBuilderHtmlParser();

  @override
  Node parse(String html, {/* Uri | String */ sourceUrl, HtmlVisitor<Node> visitor: HtmlVisitor.identity,}) {
    final lexer = new HtmlLexer(html, sourceUrl: sourceUrl);
    final iterator = lexer.tokenize().iterator;
    return new _NodeBuilder(iterator, visitor).build();
  }
}

// Helper class to make iterating over an Iterator<Html> easier.
class _IteratorReader<T> {
  final Iterator<T> _tokens;

  T _current;

  _IteratorReader(this._tokens) {
    _tokens.moveNext();
  }

  T advance() {
    _current = _tokens.current;
    _tokens.moveNext();
    return _current;
  }

  bool get eof => _tokens.current == null;

  T peek() => _tokens.current;
}

class _NodeBuilder {
  final List<Node> _root = <Node>[];
  final List<Node> _stack = <Node>[];
  final _IteratorReader<HtmlToken> _tokens;
  final HtmlVisitor<Node> _visitor;

  _NodeBuilder(Iterator<HtmlToken> iterator, [this._visitor = const _IdentityHtmlVisitor()])
      : _tokens = new _IteratorReader<HtmlToken>(iterator);

  Node build() {
    final fragment = _visitor.visitFragment(new Fragment(<Node>[]));
    if (_tokens.eof) {
      return fragment;
    }
    _stack.add(fragment);
    while (!_tokens.eof) {
      switch (_tokens.peek().type) {
        case HtmlTokenType.tagOpenStart:
          _consumeTagOpen(_tokens.advance());
          break;
        case HtmlTokenType.tagCloseStart:
          _consumeTagClose(_tokens.advance());
          break;
        case HtmlTokenType.text:
          _consumeText(_tokens.advance());
          break;
        case HtmlTokenType.comment:
          final comment = _visitor.visitComment(new Comment(_tokens.peek().value));
          if (comment != null) {
            _stack.last.childNodes.add(comment);
          }
          _tokens.advance();
          break;
        default:
          throw new FormatException('Unexpected: ${_tokens.peek()}');
      }
    }
    assert(_stack.length == 1);
    return _stack.removeLast();
  }

  void _consumeAttribute(HtmlToken token) {
    assert(token.type == HtmlTokenType.attributeNameStart);
    final nextToken = _tokens.advance();
    if (nextToken.type != HtmlTokenType.attributeName) {
      throw new FormatException('Expected attribute name, got $nextToken');
    }
    final attributeName = nextToken.value;
    String attributeValue;
    if (_tokens.peek().type == HtmlTokenType.attributeValueStart) {
      _tokens.advance();
      attributeValue = _tokens.advance().value;
    }
    final peek = _stack.last;
    if (peek is Element) {
      final attribute = _visitor.visitAttribute(new Attribute(attributeName, attributeValue, token));
      if (attribute != null) {
        peek.attributes.add(attribute);
      }
    }
    if (_tokens.peek().type == HtmlTokenType.attributeNameStart) {
      _tokens.advance();
      _consumeAttribute(token);
    }
  }

  void _consumeTagOpen(HtmlToken token) {
    assert(token.type == HtmlTokenType.tagOpenStart);
    final nextToken = _tokens.advance();
    if (nextToken.type == HtmlTokenType.tagName) {
      final tagName = nextToken.value;
      final element = _visitor.visitElement(new Element(tagName));
      if (element != null) {
        if (_stack.isNotEmpty) {
          _stack.last.childNodes.add(element);
        }
        if (!isVoid(tagName)) {
          _stack.add(element);
        }
      }
      var nextNextToken = _tokens.advance();
      if (nextNextToken.type == HtmlTokenType.attributeNameStart) {
        _consumeAttribute(nextNextToken);
        nextNextToken = _tokens.advance();
      }
      if (nextNextToken.type != HtmlTokenType.tagOpenEnd) {
        throw new FormatException('Expected tagOpenEnd, got $nextNextToken');
      }
    } else {
      throw new FormatException('Expected tagName, got $nextToken.');
    }
  }

  void _consumeTagClose(HtmlToken token) {
    assert(token.type == HtmlTokenType.tagCloseStart);
    final nextToken = _tokens.advance();
    if (nextToken.type == HtmlTokenType.tagName) {
      final nextNextToken = _tokens.advance();
      assert(nextNextToken.type == HtmlTokenType.tagCloseEnd);
      final pop = _stack.removeLast();
      if (_stack.isEmpty) {
        _root.add(pop);
      }
    } else {
      throw new FormatException('Expected tagName, got $nextToken');
    }
  }

  void _consumeText(HtmlToken token) {
    assert(token.type == HtmlTokenType.text);
    final text = _visitor.visitText(new Text(token.value));
    if (text != null) {
      _stack.last.childNodes.add(text);
    }
  }
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
