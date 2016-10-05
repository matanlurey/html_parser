import 'package:charcode/charcode.dart';
import 'nodes.dart';

/// Defines HTML elements which are not supported by this parser.
const List<String> unsupportedTags = const [
  '!DOCTYPE',
];

/// Defines `void` HTML elements (no closing tag).
Set<String> voidTags = new Set.from([
  'area',
  'base',
  'basefont',
  'bgsound',
  'br',
  'col',
  'command',
  'embed',
  //'frame', -- is this still a valid HTML5 tag?
  'hr',
  'img',
  'input',
  'keygen',
  'link',
  'meta',
  'param',
  'source',
  'track',
  'wbr',
]);

/// Defines normal HTML elements (requires closing tags).
Set<String> regularTags = new Set.from([
  'a',
  'abbr',
  'address',
  'article',
  'aside',
  'audio',
  'b',
  'bdi',
  'bdo',
  'blockquote',
  'body',
  'button',
  'canvas',
  'caption',
  'cite',
  'code',
  'colgroup',
  'datalist',
  'dd',
  'del',
  'details',
  'dfn',
  'dir',
  'div',
  'dl',
  'dt',
  'em',
  'fieldset',
  'figcaption',
  'figure',
  'footer',
  'form',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'head',
  'header',
  'hgroup',
  'html',
  'i',
  'iframe',
  'ins',
  'kbd',
  'label',
  'legend',
  'li',
  'map',
  'mark',
  'menu',
  'meter',
  'nav',
  'noscript',
  'object',
  'ol',
  'optgroup',
  'option',
  'output',
  'p',
  'pre',
  'progress',
  'q',
  'rp',
  'rt',
  'ruby',
  's',
  'samp',
  'script',
  'section',
  'select',
  'small',
  'span',
  'strong',
  'style',
  'sub',
  'summary',
  'sup',
  'table',
  'tbody',
  'td',
  'textarea',
  'tfoot',
  'th',
  'thead',
  'time',
  'title',
  'tr',
  'u',
  'ul',
  'var',
  'video',
]);

/// Whether [c] is considered a white-space character.
bool isWhitespace(int c) =>
    c == $space /* ' '  */ ||
    c == $lf /**** '\n' */ ||
    c == $ht /**** '\t' */ ||
    c == $ff /**** '\f' */ ||
    c == $cr /**** '\r' */;

/// Whether [tagName] is a considered a `void` HTML element (no closing tag).
bool isVoid(String tagName) => voidTags.contains(tagName.toLowerCase());

/// Whether [tagName] is a know HTML element, or a web/angular component.
bool isKnownTag(String tagName) {
  final lowerName = tagName.toLowerCase();
  return voidTags.contains(lowerName) || regularTags.contains(lowerName);
}

/// Retrieves all tags which are not known as part of the HTML spec.
///
/// This can be used to identify cases where the developer forgot to include
/// a component in directives.
/// __example__:
///     final xs = nonNativeTags(element);
///     print(xs);
///     // prints ["my-div", "foo-bar"]
Iterable<String> nonNativeTags(Element element) sync* {
  if (!isKnownTag(element.tagName)) {
    yield element.tagName;
  }
  for (Element child in element.childNodes) {
    yield* nonNativeTags(child);
  }
}
