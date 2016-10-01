import 'package:source_span/source_span.dart';

/// A pretty error format for the project.
abstract class FriendlyError extends Error {
  /// the line number of the error.
  String get line;

  /// the sourceFile (if availible) or None.
  String get sourceFile;

  /// the text span where the error is located.
  String get sourceLine;

  /// A friendly, Actionable error message.
  String get errorMessage;

  @override
  String toString() {
    return '\n---- PARSE ERROR ----------- $sourceFile\n' +
        '\n' +
        'There was a problem while parsing the following line:\n' +
        '$line| $sourceLine\n' +
        '${' ' * (line.length + sourceLine.length + 1)}^\n' +
        '$errorMessage\n';
  }
}

/// Simple errors which can occur during lexical analysis.
class LexerError extends FriendlyError {
  /// The source span where the error was encountered, from column 0.
  final SourceSpan span;

  /// Additional lexer context into the failure.
  final LexerErrorKind kind;

  /// Used to signal possible malformed html to the parser.
  LexerError(this.span, this.kind);

  @override
  String get sourceFile => span.sourceUrl?.path ?? 'No File';
  @override
  String get sourceLine => span.text;
  @override
  String get line => '${span.start.line}';
  @override
  String get errorMessage {
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
