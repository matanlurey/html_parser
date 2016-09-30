import 'package:html_parser/src/utils.dart';
import 'package:test/test.dart';

void main() {
  group('isWhitespace', () {
    test('should recognize spaces', () {
      expect(isWhitespace(' '.codeUnitAt(0)), isTrue);
    });

    test('should recognize new lines', () {
      expect(isWhitespace('\n'.codeUnitAt(0)), isTrue);
    });

    test('should recognize tabs', () {
      expect(isWhitespace('\t'.codeUnitAt(0)), isTrue);
    });

    test('should recognize carriage returns', () {
      expect(isWhitespace('\r'.codeUnitAt(0)), isTrue);
    });

    test('should recognize form feeds', () {
      expect(isWhitespace('\f'.codeUnitAt(0)), isTrue);
    });

    test('should recognize not anything else', () {
      expect(new Iterable<int>.generate(255).where(isWhitespace), hasLength(5));
    });
  });
}
