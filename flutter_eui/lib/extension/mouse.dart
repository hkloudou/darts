import 'package:flutter/material.dart';

extension mouseExtension on Widget {
  Widget cursor({cursor = SystemMouseCursors.click}) {
    return MouseRegion(
      cursor: cursor,
      child: this,
    );
  }
}
