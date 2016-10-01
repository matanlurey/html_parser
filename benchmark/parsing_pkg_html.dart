import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:html/dom.dart';

import 'shared/html.dart';

void main() {
  new PkgHtmlBenchmark().report();
}

class PkgHtmlBenchmark extends BenchmarkBase {
  const PkgHtmlBenchmark() : super('package:html');

  @override
  void run() {
    new DocumentFragment.html(HTML);
  }
}
