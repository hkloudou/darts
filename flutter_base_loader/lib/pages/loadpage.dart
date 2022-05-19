import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:flutter_base/plugins/base_info.dart';
// import 'package:flutter_base/plugins/base_info.dart';
import '../plugins/loading.dart';

//https://docs.flutter.dev/development/tools/sdk/release-notes/release-notes-3.0.0
T? _ambiguate<T>(T? value) => value;

class BaseLoadingPage extends StatefulWidget {
  const BaseLoadingPage({
    Key? key,
    this.loading = const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    ),
    this.home = const Scaffold(),
    this.onPause,
    this.onResume,
  }) : super(key: key);

  final Widget loading;
  final Widget home;
  final void Function()? onPause;
  final void Function()? onResume;
  // final Future<void>? future;

  @override
  // ignore: library_private_types_in_public_api
  _BaseLoadingPageState createState() => _BaseLoadingPageState();
}

class _BaseLoadingPageState extends State<BaseLoadingPage>
    with WidgetsBindingObserver {
  // late Future<void> _futureBuilderFuture;

  @override
  void initState() {
    BaseLoading.instance.pageReady();
    super.initState();
    // https://docs.flutter.dev/development/tools/sdk/release-notes/release-notes-3.0.0
    // 3.0 and before support
    _ambiguate(WidgetsBinding.instance)!.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    // https://docs.flutter.dev/development/tools/sdk/release-notes/release-notes-3.0.0
    // 3.0 and before support
    _ambiguate(WidgetsBinding.instance)!.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      widget.onPause?.call();
    }
    if (state == AppLifecycleState.resumed) {
      widget.onResume?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: BaseLoading.instance.future,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            if (snapshot.hasError) {
              // print("err: ${snapshot.error.toString()}");
              // throw (snapshot.error);
              return const Scaffold(
                body: Center(
                  child: Text('error'),
                ),
              );
            }
            return widget.home;
          default:
            if (kDebugMode) {
              print('snapshot.connectionState:${snapshot.connectionState}');
            }
            return widget.loading;
        }
      },
    );
  }
}
