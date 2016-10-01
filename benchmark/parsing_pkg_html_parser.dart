import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:html_parser/src/parser.dart';

import 'shared/html.dart';

void main() {
  new PkgHtmlBenchmark().report();
}

class PkgHtmlBenchmark extends BenchmarkBase {
  const PkgHtmlBenchmark() : super('package:html_parser');

  @override
  void run() {
    const HtmlParser().parse(HTML);
  }
}
