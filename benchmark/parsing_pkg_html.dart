import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:html/dom.dart';

import 'shared/html.dart';

void main() {
  const PkgHtmlBenchmark().report();
}

/// Runs the benchmark for `package:html`.
class PkgHtmlBenchmark extends BenchmarkBase {
  /// Creates the benchmark.
  const PkgHtmlBenchmark() : super('package:html');

  @override
  void run() {
    new DocumentFragment.html(html);
  }
}
