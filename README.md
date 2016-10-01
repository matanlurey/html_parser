# html_parser

[![Build Status](https://travis-ci.org/matanlurey/html_parser.svg?branch=master)](https://travis-ci.org/matanlurey/html_parser)
[![Pub](https://img.shields.io/pub/v/html_parser.svg)](https://pub.dartlang.org/packages/html_parser)

A fast and forgiving HTML parser for Dart. Loosely based on
[htmlparser2](https://github.com/fb55/htmlparser2).

This package is **in development** as an experiment to replace the
transpiled HTML parser from [angular_2][angular_2_gh]. It is not meant
to be a full DOM parser, or to emulate behavior of the browser.

Goals are speed, ease of use, and [great error messages][elm].

[angular_2_gh]: https://github.com/dart-lang/angular2
[elm]: http://elm-lang.org/blog/compiler-errors-for-humans

## Usage

```dart
import 'package:html_parser/html_parser.dart';

void main() {
  var fragment = parseHtml('<div>Hello World</div>');
  
  // Prints: '<div>Hello World</div>'
  print(nodeToString(fragment));
}
```

## Limitations

A lot is missing from making this a package ready to use.

- [ ] Does not [support comments][i1] `<!--` or [attributes][i6], yet.
- [ ] Needs to be battle-tested on [more complex documents][i2].
- [ ] Needs user friendly ways ([CSS][i4], [visitors][i3]) to traverse.
- [ ] Needs to [handle error messages][i5].

[i1]: https://github.com/matanlurey/html_parser/issues/1
[i2]: https://github.com/matanlurey/html_parser/issues/2
[i3]: https://github.com/matanlurey/html_parser/issues/3
[i4]: https://github.com/matanlurey/html_parser/issues/4
[i5]: https://github.com/matanlurey/html_parser/issues/5
[i6]: https://github.com/matanlurey/html_parser/issues/6

See [issues][issues] for more details.

[issues]: https://github.com/matanlurey/html_parser/issues
