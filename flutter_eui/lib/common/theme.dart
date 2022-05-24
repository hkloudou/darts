// import 'package:flutter/material.dart';
// import './theme_interface.dart';
// class ETheme {
//   static late ThemeData _theme;
//   static late ThemeData _darkTheme;
//   static ThemeData get lightTheme => _theme;
//   static ThemeData get darkTheme => _darkTheme;
// }

// class EThemeAdapter extends StatefulWidget {
//   /// Represents the light theme for the app.
//   final ThemeData light;

//   /// Represents the dark theme for the app.
//   final ThemeData dark;

//   final Widget Function(ThemeData light, ThemeData dark) builder;

//   const EThemeAdapter({
//     super.key,
//     required this.light,
//     ThemeData? dark,
//     required this.builder,
//   }) : dark = dark ?? light;
//   // final Widget child;
//   @override
//   State<EThemeAdapter> createState() => _EThemeAdapterState();

//   /// Returns reference of the [AdaptiveThemeManager] which allows access of
//   /// the state object of [AdaptiveTheme] in a restrictive way.
//   static EThemeInterface of(BuildContext context) =>
//       context.findAncestorStateOfType<State<EThemeAdapter>>()!
//           as EThemeInterface;

//   /// Returns reference of the [AdaptiveThemeManager] which allows access of
//   /// the state object of [AdaptiveTheme] in a restrictive way.
//   /// This returns null if the state instance of [AdaptiveTheme] is not found.
//   static EThemeInterface? maybeOf(BuildContext context) {
//     final state = context.findAncestorStateOfType<State<EThemeAdapter>>();
//     if (state == null) return null;
//     return state as EThemeInterface;
//   }
// }

// class _EThemeAdapterState extends State<EThemeAdapter>
//     implements EThemeInterface {
//   @override
//   Widget build(BuildContext context) {}
// }
