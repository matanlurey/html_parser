import 'package:angular2/src/compiler/html_parser.dart';
import 'package:benchmark_harness/benchmark_harness.dart';

import 'shared/html.dart';

void main() {
  new PkgHtmlBenchmark().report();
}

class PkgHtmlBenchmark extends BenchmarkBase {
  const PkgHtmlBenchmark() : super('package:angular2');

  @override
  void run() {
    new HtmlParser().parse(HTML, 'foo.html');
  }
}
