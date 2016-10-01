import 'package:source_span/source_span.dart';

/// A pretty error format for the project.
abstract class SourceError extends Error {
  /// The source span where the error occurred.
  SourceSpan get source;

  /// A friendly, Actionable error message.
  String get message;

  @override
  String toString() {
    final line = span.start.line.toString();
    return '\n---- PARSE ERROR ----------- ${span.sourceUrl?.path ?? 'No File'}\n' +
        '\n' +
        'There was a problem while parsing the following line:\n' +
        '$line| ${source.text}\n' +
        '${' ' * (line.length + source.text.length + 1)}^\n' +
        '$message\n';
  }
}

/// Simple errors which can occur during lexical analysis.
class LexerError extends SourceError {
  /// The source span where the error was encountered, from column 0.
  final SourceSpan source;

  /// Additional lexer context into the failure.
  final LexerErrorKind kind;

  /// Used to signal possible malformed html to the parser.
  LexerError(this.source, this.kind);

  @override
  String get message {
    switch (kind) {
      case LexerErrorKind.misMatchedClose:
        return 'I found an unnecessary closing tag.';
      case LexerErrorKind.misMatchedOpen:
        return 'I found an unnecessary opening tag.';
      default:
        return "This shouldn't happen.";
    }
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
