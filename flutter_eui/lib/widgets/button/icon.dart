import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:flutter_eui/flutter_eui.dart';

// back
class EIconButtonCloseBack extends StatelessWidget {
  const EIconButtonCloseBack(
      {Key? key, this.color, this.onPressed, this.tooltip, this.padding})
      : super(key: key);
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return eActionIcon(
      context: context,
      name: "assets/actions/back.webp",
      package: "flutter_eui",
      color: color,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        } else {
          Navigator.maybePop(context);
        }
      },
    );
  }
}

//close
class EIconButtonClose extends StatelessWidget {
  const EIconButtonClose(
      {Key? key, this.color, this.onPressed, this.tooltip, this.padding})
      : super(key: key);
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return eActionIcon(
      context: context,
      name: "assets/actions/close.webp",
      package: "flutter_eui",
      color: color,
      tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
        } else {
          Navigator.maybePop(context);
        }
      },
    );
  }
}

//copy
class EIconButtonCopy extends StatelessWidget {
  const EIconButtonCopy(
      {Key? key, this.color, this.onPressed, this.tooltip, this.padding})
      : super(key: key);
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return eActionIcon(
      context: context,
      name: "assets/actions/copy.webp",
      package: "flutter_eui",
      color: color,
      tooltip: MaterialLocalizations.of(context).copyButtonLabel,
      onPressed: onPressed,
    );
  }
}

//refresh
class EIconButtonRefresh extends StatelessWidget {
  const EIconButtonRefresh(
      {Key? key, this.color, this.onPressed, this.tooltip, this.padding})
      : super(key: key);
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return eActionIcon(
      context: context,
      name: "assets/actions/refresh.webp",
      package: "flutter_eui",
      color: color,
      tooltip: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      onPressed: onPressed,
    );
  }
}

class EIconButtonHelp extends StatelessWidget {
  const EIconButtonHelp(
      {Key? key, this.color, this.onPressed, this.tooltip, this.padding})
      : super(key: key);
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return eActionIcon(
      context: context,
      name: "assets/actions/question.webp",
      package: "flutter_eui",
      color: color,
      onPressed: onPressed,
    );
  }
}

//search
class EIconButtonSearch extends StatelessWidget {
  const EIconButtonSearch(
      {Key? key, this.color, this.onPressed, this.tooltip, this.padding})
      : super(key: key);
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return eActionIcon(
      context: context,
      name: "assets/actions/search.webp",
      package: "flutter_eui",
      color: color,
      onPressed: onPressed,
    );
  }
}

//notice
class EIconButtonNotice extends StatelessWidget {
  const EIconButtonNotice(
      {Key? key, this.color, this.onPressed, this.tooltip, this.padding})
      : super(key: key);
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return eActionIcon(
      context: context,
      name: "assets/actions/notice.webp",
      package: "flutter_eui",
      color: color,
      onPressed: onPressed,
    );
  }
}

//filter
class EIconButtonFilter extends StatelessWidget {
  const EIconButtonFilter(
      {Key? key, this.color, this.onPressed, this.tooltip, this.padding})
      : super(key: key);
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return eActionIcon(
      context: context,
      name: "assets/actions/filter.webp",
      package: "flutter_eui",
      color: color,
      onPressed: onPressed,
    );
  }
}

//history
class EIconButtonHistory extends StatelessWidget {
  const EIconButtonHistory(
      {Key? key, this.color, this.onPressed, this.tooltip, this.padding})
      : super(key: key);
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return eActionIcon(
      context: context,
      name: "assets/actions/history.webp",
      package: "flutter_eui",
      tooltip: tooltip,
      color: color,
      onPressed: onPressed,
    );
  }
}

//swap
class EIconButtonSwap extends StatelessWidget {
  const EIconButtonSwap(
      {Key? key, this.color, this.onPressed, this.tooltip, this.padding})
      : super(key: key);
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return eActionIcon(
      context: context,
      name: "assets/actions/swap.webp",
      package: "flutter_eui",
      tooltip: tooltip,
      color: color,
      onPressed: onPressed,
    );
  }
}

class EIconButtonQrcode extends StatelessWidget {
  const EIconButtonQrcode(
      {Key? key, this.color, this.onPressed, this.tooltip, this.padding})
      : super(key: key);
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return eActionIcon(
      context: context,
      name: "assets/actions/qrcode.webp",
      package: "flutter_eui",
      color: color,
      onPressed: onPressed,
    );
  }
}

class EIconButtonPerson extends StatelessWidget {
  const EIconButtonPerson(
      {Key? key, this.color, this.onPressed, this.tooltip, this.padding})
      : super(key: key);
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final String? tooltip;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return eActionIcon(
      context: context,
      name: "assets/actions/person.webp",
      package: "flutter_eui",
      color: color,
      onPressed: onPressed,
    );
  }
}

Widget eActionIcon({
  required BuildContext context,
  required String name,
  String? package,
  String? tooltip,
  Color? color,
  double? size,
  EdgeInsetsGeometry? padding,
  VoidCallback? onPressed,
}) {
  var theme =
      AppBarTheme.of(context).actionsIconTheme ?? Theme.of(context).iconTheme;
  var result = Padding(
    padding: padding ?? const EdgeInsets.symmetric(horizontal: 4),
    child: Styled.widget(
        child: Image.asset(
      name,
      package: package,
      width: size ?? theme.size,
      height: size ?? theme.size,
      color: color ?? theme.color,
    )),
  )
      .gestures(
        behavior: HitTestBehavior.opaque,
        onTap: () => onPressed?.call(),
      )
      .cursor();
  if (tooltip != null) {
    result = Tooltip(
      message: tooltip,
      child: result,
    );
  }
  return result;
}
