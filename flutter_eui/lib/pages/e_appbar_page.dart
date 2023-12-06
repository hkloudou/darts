// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:math';

// import 'package:flutter/material.dart';

// extension _WidgetExtension on Widget {
//   Widget _refresh({Key? key, Future<void> Function()? onRefresh}) =>
//       onRefresh == null
//           ? this
//           : RefreshIndicator(
//               key: key,
//               onRefresh: onRefresh,
//               child: this,
//               // displacement: 0,
//               triggerMode: RefreshIndicatorTriggerMode.anywhere,
//             );
// }

// class RickRefreshControler {
//   final bool initialRefresh;
//   RickRefreshControler({this.initialRefresh = false});
//   void reset() {}
// }

// class _appbarBottom extends StatelessWidget implements PreferredSizeWidget {
//   final String title;
//   final double titleHeight;
//   final double current;
//   _appbarBottom({
//     Key? key,
//     required this.titleHeight,
//     required this.current,
//     required this.title,
//   }) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     var theme = Theme.of(context);
//     TextStyle? base = (theme.appBarTheme.automaticallyImplyLeading ?? true)
//         ? theme.appBarTheme.textTheme?.headline6 ??
//             theme.primaryTextTheme.headline6
//         : theme.appBarTheme.titleTextStyle ??
//             theme.textTheme.headline6
//                 ?.copyWith(color: theme.appBarTheme.foregroundColor);
//     base = base ??
//         TextStyle(
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//         );
//     base = base.copyWith(
//       fontSize: 24,
//       fontWeight: FontWeight.bold,
//     );
//     return ClipRect(
//       child: Align(
//         alignment: Alignment.bottomLeft,
//         heightFactor: current / titleHeight,
//         child: Container(
//           // color: Colors.red,
//           height: titleHeight,
//           alignment: Alignment.centerLeft,
//           child: Padding(
//             padding: EdgeInsets.only(left: 15),
//             child: Text(
//               title,
//               style: base,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   Size get preferredSize {
//     // print(current);
//     return new Size.fromHeight(current);
//   }
// }

// typedef OnRefreshArive<T> = void Function(List<T>, bool);
// typedef OnGetID<T> = dynamic Function(T last);

// class RichAppBarPage<T> extends StatefulWidget {
//   final double titleHeight;
//   final double titleHeightPos;
//   final Widget? bodyBottom;
//   final Widget? bodyTop;
//   final Widget? body;
//   final Widget? leading;
//   final String title;
//   // final SizedBox
//   final RickRefreshControler? controler;
//   final List<Widget>? actions;
//   final Future<void> Function()? onRefresh;
//   // final OnGetID<T> getID;

//   RichAppBarPage({
//     Key? key,
//     this.titleHeight = 50,
//     this.titleHeightPos = 30,
//     this.bodyTop,
//     this.bodyBottom,
//     this.leading,
//     this.title = "",
//     this.body,
//     this.onRefresh,
//     // this.onMore,
//     this.actions,
//     this.controler,
//     // required this.getID,
//   })  : assert(titleHeight > titleHeightPos),
//         super(key: key);
//   @override
//   State<RichAppBarPage<T>> createState() {
//     return _RichAppBarPageState<T>();
//   }
// }

// class _RichAppBarPageState<T> extends State<RichAppBarPage<T>> {
//   GlobalKey<RefreshIndicatorState>? _refreshKey =
//       GlobalKey<RefreshIndicatorState>();
//   ScrollController _scrollController = ScrollController();
//   double _op = 0;
//   late double _shouldHeight;
//   @override
//   void initState() {
//     super.initState();
//     _shouldHeight = widget.titleHeight;
//     // WidgetBuilder(
//     WidgetsBinding.instance?.addPostFrameCallback((_) {
//       if (widget.onRefresh != null &&
//           widget.controler?.initialRefresh == true) {
//         _refreshKey?.currentState?.show();
//       }
//       _scrollController
//         ..addListener(() {
//           var tmp = widget.titleHeight -
//               max(min(_scrollController.offset, widget.titleHeight), 0);
//           var tmp2 = (max(
//                   min(_scrollController.offset - widget.titleHeightPos,
//                       widget.titleHeight - widget.titleHeightPos),
//                   0) /
//               (widget.titleHeight - widget.titleHeightPos));
//           // print(_shouldHeight);
//           if (_shouldHeight != tmp || _op != tmp2) {
//             // print("h:$_shouldHeight op:$_op");
//             setState(() {
//               _shouldHeight = tmp;
//               _op = tmp2;
//             });
//           }
//         });
//     });
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: widget.leading,
//         actions: widget.actions,
//         title: Opacity(
//           opacity: _op,
//           child: Text(
//             widget.title,
//           ),
//         ),
//         elevation: 0,
//         bottom: _appbarBottom(
//           title: widget.title,
//           titleHeight: widget.titleHeight,
//           current: _shouldHeight,
//         ),
//         automaticallyImplyLeading: false,
//         // automaticallyImplyLeading: ,
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // _appbarBottom(
//           //   title: widget.title,
//           //   titleHeight: widget.titleHeight,
//           //   current: _shouldHeight,
//           // ),
//           widget.bodyTop != null ? widget.bodyTop! : Container(),
//           Expanded(
//             child: LayoutBuilder(
//               builder: (BuildContext context, BoxConstraints constraints) {
//                 return SingleChildScrollView(
//                   physics: AlwaysScrollableScrollPhysics(),
//                   controller: _scrollController,
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(
//                       minHeight: constraints.maxHeight + widget.titleHeight,
//                       maxHeight: double.infinity,
//                     ),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           height: widget.titleHeight - _shouldHeight,
//                         ),
//                         widget.body != null ? widget.body! : Container()
//                       ],
//                     ),
//                   ),
//                 )._refresh(key: _refreshKey, onRefresh: widget.onRefresh);
//               },
//             ),
//           ),
//           widget.bodyBottom != null ? widget.bodyBottom! : Container(),
//         ],
//       ),
//     );
//   }
// }
