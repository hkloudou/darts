import 'package:flutter/material.dart';
import 'package:lottie/src/model/content/shape_group.dart' show ShapeGroup;
import 'package:lottie/src/model/content/shape_fill.dart';
import 'package:lottie/src/value/keyframe.dart';
import 'package:flutter_eui/flutter_eui.dart';
// import 'dart:developer' as dev;

class EActionThemeSwith extends StatefulWidget {
  const EActionThemeSwith({Key? key, this.width = 50, this.light, this.dark})
      : super(key: key);
  final double width;
  final Color? light;
  final Color? dark;
  @override
  State<EActionThemeSwith> createState() => _EActionThemeSwithState();
}

class _EActionThemeSwithState extends State<EActionThemeSwith>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Keyframe<Color> _copy(
    LottieComposition composition,
    Keyframe<Color> source, {
    Color? startValue,
    Color? endValue,
  }) {
    return Keyframe<Color>(
      composition,
      startValue: startValue ?? source.startValue,
      endValue: endValue ?? source.endValue,
      interpolator: source.interpolator,
      xInterpolator: source.xInterpolator,
      yInterpolator: source.yInterpolator,
      startFrame: source.startFrame,
      endFrame: source.endFrame,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var mode =
            AdaptiveTheme.maybeOf(context)?.mode ?? AdaptiveThemeMode.system;
        var brightness =
            AdaptiveTheme.maybeOf(context)?.brightness ?? Brightness.light;
        // if (mode == null) return;
        // print("mode: $mode bri:$brightness");
        if ((mode.isSystem && brightness == Brightness.light) || mode.isLight) {
          _controller.forward();
          AdaptiveTheme.maybeOf(context)?.setDark();
        } else {
          _controller.reverse();
          AdaptiveTheme.maybeOf(context)?.setLight();
        }
      },
      child: Lottie.asset(
        'assets/lotties/eui_theme_switch.json',
        package: "flutter_eui",
        width: widget.width,
        controller: _controller,
        // filterQuality: FilterQuality.,
        options: LottieOptions(enableMergePaths: true),
        onLoaded: (composition) {
          _controller.duration = composition.duration;
          var mode =
              AdaptiveTheme.maybeOf(context)?.mode ?? AdaptiveThemeMode.system;
          var brightness =
              AdaptiveTheme.maybeOf(context)?.brightness ?? Brightness.light;
          if ((mode.isSystem && brightness == Brightness.light) ||
              mode.isLight) {
            // _controller.value = composition.startFrame;
          } else {
            _controller.value = composition.endFrame;
          }
          var sp =
              ((composition.getPrecomps("comp_1")![1].shapes[0] as ShapeGroup)
                      .items[1] as ShapeFill)
                  .color!;

          sp.keyframes[0] = _copy(composition, sp.keyframes[0],
              startValue: widget.light ?? sp.keyframes[0].startValue,
              endValue: widget.dark ?? sp.keyframes[0].endValue);
        },
      ),
    ).cursor();
  }
}
