import 'package:flutter/material.dart';

// EThemeColor to define a color group
class EThemeColor {
  static MaterialColor _primary = Colors.blue;
  static MaterialColor get primary => _primary;

  static set primary(Color basecolor) {
    _primary = MaterialColor(
      basecolor.value,
      <int, Color>{
        50: Color(basecolor.value),
        100: Color(basecolor.value),
        200: Color(basecolor.value),
        300: Color(basecolor.value),
        400: Color(basecolor.value),
        500: Color(basecolor.value),
        600: Color(basecolor.value),
        700: Color(basecolor.value),
        800: Color(basecolor.value),
        900: Color(basecolor.value),
      },
    );
  }
}
