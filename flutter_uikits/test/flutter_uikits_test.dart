import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter_uikits/utils/string_utils.dart';

// import 'package:flutter_uikits/flutter_uikits.dart';

// import 'package:flutter_uikits/extensions/camel_case.dart';

void p(String text) {
  // print(text.camelCase);
  // print(text.pascalCase);
  // print(text.snakeCase);
}

void main() {
  test('adds one to input values', () {
    // StringUtils
    p("AaaBbb12");
    p("AAaBbb12");
    p("AAaBbB12");
    p("x_y");
    // final calculator = Calculator();
    // expect(calculator.addOne(2), 3);
    // expect(calculator.addOne(-7), -6);
    // expect(calculator.addOne(0), 1);
  });
}
