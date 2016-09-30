import 'package:charcode/charcode.dart';

/// Whether [c] is considered a white-space character.
bool isWhitespace(int c) =>
    c == $space /* ' '  */ ||
    c == $lf /**** '\n' */ ||
    c == $ht /**** '\t' */ ||
    c == $ff /**** '\f' */ ||
    c == $cr /**** '\r' */;
