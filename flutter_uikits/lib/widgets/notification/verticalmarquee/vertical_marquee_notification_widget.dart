// import 'package:flutter_uikits/widgets/notification/verticalmarquee/vertical_marquee_notification_page.dart';

import './vertical_marquee_notification_model.dart';
import 'package:flutter/material.dart';
import 'marquee.dart';
import 'package:styled_widget/styled_widget.dart';

class VerticalMarqueeNotificationWidget extends StatelessWidget {
  final VerticalMarqueeNotificationModel? model;

  final Color? iconColor;
  final Color? textColor;
  final double? iconSize;
  final double? textSize;
  const VerticalMarqueeNotificationWidget({
    Key? key,
    this.model,
    this.iconColor,
    this.textColor,
    this.iconSize,
    this.textSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // context.findAncestorStateOfType().setState(() {

    // });
    if (model == null) return Container();
    var a = model!;
    var notices = a.items;
    if (!a.enable || a.items.isEmpty) return Container();
    var controller = MarqueeController();
    List<String> str = notices.map((e) => e.title).toList();
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(
            Icons.campaign,
            size: iconSize ?? a.iconSize,
            color: iconColor ?? a.iconColor,
          ),
        ),
        Expanded(
          child: SizedBox(
            height: 36,
            child: Marquee(
              textList:
                  str, // List<Text>, textList and textSpanList can only have one of code.
              // textSpanList: str,
              fontSize: textSize ?? a.textSize, // text size
              scrollDuration:
                  const Duration(seconds: 1), // every scroll duration
              stopDuration: const Duration(seconds: 3), //every stop duration
              tapToNext: false, // tap to next
              textColor: textColor ?? a.textColor, // text color
              controller: controller, // the controller can get the position
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(13, 3, 3, 3),
          child: Icon(
            Icons.menu,
            size: iconSize ?? a.iconSize,
            color: iconColor ?? a.iconColor,
          ),
        ).gestures(
            // onTap: () => Navigator.of(context, rootNavigator: true).push(
            //   MaterialPageRoute(
            //     builder: (context) =>
            //         VerticalMarqueeNotificationWidgetPage(group: group),
            //   ),
            // ),
            ),
      ],
    );
  }
}
