``` dart
import 'package:flutter/material.dart';
import 'package:flutter_base_loader/flutter_base_loader.dart';

void main() {
  BaseLoading.instance.onReady.then((_) => BaseLoading.instance.complete());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: BaseLoadingPage(
        home: Scaffold(
          appBar: AppBar(
            title: const Text("titile"),
          ),
          body: const Text("body"),
        ),
      ),
    );
  }
}

```