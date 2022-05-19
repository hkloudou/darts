import 'package:flutter_uikits/flutter_uikits.dart';

// import './vertical_marquee_notification_model.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:date_format/date_format.dart' as dfmt;

class VerticalMarqueeNotificationWidgetPage extends StatelessWidget {
  // final VerticalMarqueeNotificationModel? model;
  final String group;
  const VerticalMarqueeNotificationWidgetPage({
    Key? key,
    // this.model,
    required this.group,
  }) : super(key: key);
  // CfgSimpleNotificationStatus
  @override
  Widget build(BuildContext context) {
    // MaterialLocalizations.of(context).moreButtonTooltip;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notice Center"),
      ),
      body: VerticalMarqueeNotificationWatcher.of(group).motion(
          builder: ((p0, p1) {
        if (p1.model == null) return Container();
        var a = p1.model!;
        var notices = a.items;
        if (!a.enable || a.items.isEmpty) return Container();
        return [
          ...notices
              .map((e) => [
                    [
                      Styled.text(
                          dfmt.formatDate(
                              DateTime.fromMillisecondsSinceEpoch(e.updatedAt),
                              [
                                dfmt.yyyy,
                                "-",
                                dfmt.mm,
                                "-",
                                dfmt.dd,
                                " ",
                                dfmt.HH,
                                ":",
                                dfmt.nn
                              ]),
                          style: const TextStyle(fontSize: 12)),
                      e.href.isEmpty
                          ? Container()
                          : Styled.text("Detail").fontSize(12),
                    ]
                        .toRow(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween)
                        .padding(all: 12, bottom: 0),
                    Styled.text(e.title, overflow: TextOverflow.ellipsis)
                        .fontSize(13)
                        .bold()
                        .alignment(Alignment.centerLeft)
                        .padding(all: 12),
                  ]
                      .toColumn()
                      .ripple()
                      .backgroundColor(Colors.white)
                      .clipRRect(all: 5) // clip ripple
                      .borderRadius(all: 5)
                      .elevation(
                        20,
                        borderRadius: BorderRadius.circular(25),
                        shadowColor: const Color(0x30000000),
                      )
                      .gestures(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            // WiseLaunchAdapter.go(
                            //   context,
                            //   e.href,
                            //   e.title,
                            //   openInBrowser: false,
                            // );
                          })
                      .padding(top: 16)
                      .animate(
                          const Duration(milliseconds: 150), Curves.easeOut))
              .toList()
        ].toColumn();
      })).scrollable(),
    );
  }
}
