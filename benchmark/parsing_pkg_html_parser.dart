import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:html_parser/html_parser.dart';

import 'shared/html.dart';

void main() {
  const PkgHtmlParserBenchmark().report();
}

/// Runs the `package:html_parser` benchmark.
class PkgHtmlParserBenchmark extends BenchmarkBase {
  /// Create the benchmark.
  const PkgHtmlParserBenchmark() : super('package:html_parser');

  @override
  void run() {
    parseHtml(html);
  }
}
