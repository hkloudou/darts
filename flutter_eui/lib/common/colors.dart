import 'package:flutter/material.dart';

class EColor {
  Color primaryText = const Color(0xFF303133);
  Color regularText = const Color(0xFF606266);
  Color secondaryText = const Color(0xFF909399);
  Color placeholderText = const Color(0xFFC0C4CC);

  // Color foregroundColor = Colors.black;
  Color placeholderColor = Colors.white;
  Color backgroundColor = const Color.fromRGBO(146, 155, 165, 1);

  Color border1 = const Color(0xFFDCDFE6);
  Color border2 = const Color(0xFFE4E7ED);
  Color border3 = const Color(0xFFEBEEF5);
  Color border4 = const Color(0xFFF2F6FC);

  Color success = const Color(0xFF67C23A);
  Color success1 = const Color(0xFFe1f3d8);
  Color success2 = const Color(0xFFf0f9eb);

  Color warning = const Color(0xFFE6A23C);
  Color warning1 = const Color(0xFFfaecd8);
  Color warning2 = const Color(0xFFfdf6ec);

  Color danger = const Color(0xFFF56C6C);
  Color danger1 = const Color(0xFFfde2e2);
  Color danger2 = const Color(0xFFfef0f0);

  Color info = const Color(0xFF909399);
  Color info1 = const Color(0xFFe9e9eb);
  Color info2 = const Color(0xFFf4f4f5);

  mergaWith({
    Color? primaryText,
    Color? regularText,
    Color? secondaryText,
    Color? placeholderText,
    Color? foregroundColor,
    Color? backgroundColor,
    Color? placeholderColor,
  }) {
    this.primaryText = primaryText ?? this.primaryText;
    this.regularText = regularText ?? this.regularText;
    this.secondaryText = secondaryText ?? this.secondaryText;
    this.placeholderText = placeholderText ?? this.placeholderText;

    // this.foregroundColor = foregroundColor ?? this.foregroundColor;
    this.backgroundColor = backgroundColor ?? this.backgroundColor;
    this.placeholderColor = placeholderColor ?? this.placeholderColor;
  }

  EColor();

  // void applyToTheme(ThemeData data) {
  //   data = data.copyWith(
  //     scaffoldBackgroundColor: backgroundColor,
  //     appBarTheme: AppBarTheme(
  //       foregroundColor: foregroundColor,
  //       backgroundColor: backgroundColor,
  //     ),
  //   );
  // }
}

class EColors {
  static EColor _light = EColor();
  static EColor _dark = EColor();
  static EColor get light => _light;
  static EColor get dark => _dark;
  static setColor({
    EColor? light,
    EColor? dark,
  }) {
    _light = light ?? _light;
    _dark = dark ?? _light;
  }

  static EColor of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? _dark : _light;
  }
}
