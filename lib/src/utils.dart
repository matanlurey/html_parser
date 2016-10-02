import 'package:charcode/charcode.dart';

/// Whether [c] is considered a white-space character.
bool isWhitespace(int c) =>
    c == $space /* ' '  */ ||
    c == $lf /**** '\n' */ ||
    c == $ht /**** '\t' */ ||
    c == $ff /**** '\f' */ ||
    c == $cr /**** '\r' */;

/// Whether [tagName] is a considered a `void` HTML element (no closing tag).
bool isVoid(String tagName) => const <String>[
      'area',
      'base',
      'basefont',
      'bgsound',
      'br',
      'col',
      'command',
      'embed',
      'frame',
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
    ].contains(tagName.toLowerCase());
