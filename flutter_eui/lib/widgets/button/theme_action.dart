import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EActionThemeSwith extends StatefulWidget {
  const EActionThemeSwith({Key? key, this.width = 50}) : super(key: key);
  final double width;
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var brightness = AdaptiveTheme.maybeOf(context)?.brightness;
        if (brightness == null) return;
        if (brightness == Brightness.dark) {
          _controller.reverse();
          AdaptiveTheme.maybeOf(context)?.setLight();
        } else {
          _controller.forward();
          AdaptiveTheme.maybeOf(context)?.setDark();
        }
      },
      child: Lottie.asset(
        'assets/lotties/eui_theme_switch.json',
        package: "flutter_eui",
        width: widget.width,
        controller: _controller,
        onLoaded: (composition) {
          _controller.duration = composition.duration;
          if (AdaptiveTheme.of(context).brightness == Brightness.dark) {
            _controller.value = composition.endFrame;
          }
        },
      ),
    );
  }
}
