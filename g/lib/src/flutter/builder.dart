import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///
/// Being used interally by GWidgetBuilders for eg [GTextBuilder]
///
abstract class GWidgetBuilder<T extends Widget> {
  T make({Key? key});
}

// abstract class GWidgetContextBuilder<T extends Widget> {
//   T make(BuildContext context, {Key? key});
// }

// abstract class GTextSpanBuilder<TextSpan> {
//   TextSpan make({Key? key});
// }
