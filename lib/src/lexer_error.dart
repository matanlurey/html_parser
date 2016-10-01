import 'package:source_span/source_span.dart';

/// Simple errors which can occur during lexical analysis.
class LexerError extends Error {
  /// The source span where the error was encountered, from column 0.
  final SourceSpan span;
  /// Additional lexer context into the failure.
  final LexerErrorKind kind;

  /// Used to signal possible malformed html to the parser.
  LexerError(this.span, this.kind);

  /// Returns a string representation of the file path.
  String get filePath => span.sourceUrl?.path ?? 'No File';

  String _errorMessage() {
    switch(kind) {
      case LexerErrorKind.misMatchedClose:
        return 'I found an unecessary closing tag.';
      case LexerErrorKind.misMatchedOpen:
        return 'I found an unecessary opening tag.';
      default:
        return "This shouldn't happen";
    }
  }
  /// If the error can not be handled, use this nicely formatted message.
  /// called a parsing error because people know what that is.
  /// TODO: standard error formatting class?
  @override
  String toString() {
    final index = span.start.line;
    return '\n---- PARSE ERROR ----------- $filePath\n' +
    '\n' +
    'There was a problem while parsing the following line:\n' +
    '$index| ${span.text}\n' +
    '  ${' ' * index.toString().length}${' ' * (span.text.length - 1)}^\n' +
    '${_errorMessage()}\n';
  }
}

/// LexerErrorKind provides more specific context about the kind of error
/// encountered.
enum LexerErrorKind {
  /// found an extra '<'
  misMatchedOpen,
  /// found an extra '>'
  misMatchedClose,
  /// found a character inside of a tag that doesn't belong
  misMatchedTag,
}
