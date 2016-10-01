import 'lexer.dart';
import 'nodes.dart';

/// Parses raw HTML strings into a tree of DOM nodes.
abstract class HtmlParser {
  const factory HtmlParser() = _NodeBuilderHtmlParser;

  /// Returns a DOM [Node] by parsing [html].
  Node parse(String html, {/* Uri | String */ sourceUrl});
}

class _NodeBuilderHtmlParser implements HtmlParser {
  const _NodeBuilderHtmlParser();

  @override
  Node parse(String html, {/* Uri | String */ sourceUrl}) => new _NodeBuilder(
          new HtmlLexer(html, sourceUrl: sourceUrl).tokenize().iterator)
      .build();
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

  _NodeBuilder(Iterator<HtmlToken> iterator)
      : _tokens = new _IteratorReader<HtmlToken>(iterator);

  Node build() {
    if (_tokens.eof) {
      return new Fragment(<Node>[]);
    }
    _stack.add(new Fragment(<Node>[]));
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
          _stack.last.childNodes.add(new Comment(_tokens.peek().value));
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
    (_stack.last as Element).attributes.add(
          new Attribute(attributeName, attributeValue, token),
        );
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
      final element = new Element(tagName);
      if (_stack.isNotEmpty) {
        _stack.last.childNodes.add(element);
      }
      _stack.add(element);
      var nextNextToken = _tokens.advance();
      if (nextNextToken.type == HtmlTokenType.attributeNameStart) {
        _consumeAttribute(nextNextToken);
        nextNextToken = _tokens.advance();
      }
      if (nextNextToken.type != HtmlTokenType.tagOpenEnd) {
        throw new FormatException('Expected tagOpenEnd, got ${nextNextToken}');
      }
    } else {
      throw new FormatException('Expected tagName, got ${nextToken}.');
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
      throw new FormatException('Expected tagName, got ${nextToken}');
    }
  }

  void _consumeText(HtmlToken token) {
    assert(token.type == HtmlTokenType.text);
    _stack.last.childNodes.add(new Text(token.value));
  }
}
