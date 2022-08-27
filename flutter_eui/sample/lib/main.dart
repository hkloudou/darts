// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:flutter_eui/flutter_eui.dart';

var base = const Color.fromRGBO(246, 203, 61, 1);

// const seed = Color(0xFF6750A4);
var seed = Colors.yellow;

// var lightColorScheme = ColorScheme.fromSeed(
//   seedColor: seed,
//   brightness: Brightness.light,
//   // surface: Colors.red,
//   // onSurface: Colors.white,
//   // surfaceTint: Colors.black,
// );

// primaryText: Color.fromRGBO(32, 38, 48, 1), //Primary Text    主灰
// regularText: Color.fromRGBO(132, 142, 156, 1), //Regular Text 常规灰，文字
// secondaryText: Color.fromRGBO(146, 155, 165, 1),
// placeholderText: Color.fromRGBO(181, 189, 199, 1),

// scaffoldBackgroundColor: Color.fromRGBO(244, 245, 246, 1),
// backgroundColor: Color.fromRGBO(254, 255, 255, 1),
var lightColorScheme = const ColorScheme(
  brightness: Brightness.light,
  primary: Colors.yellow,
  onPrimary: Colors.white,
  secondary: Colors.white,
  onSecondary: Colors.green,
  error: Colors.red,
  onError: Colors.pink,
  background: Color.fromRGBO(244, 245, 246, 1),
  onBackground: Color.fromRGBO(32, 38, 48, 1),
  surface: Color.fromRGBO(254, 255, 255, 1),
  // onSurface: Color.fromRGBO(132, 142, 156, 1),
  onSurface: Color.fromRGBO(132, 142, 156, 1),
);

// primaryText: Color.fromRGBO(234, 236, 239, 1), //E6E8EB
// regularText: Color.fromRGBO(132, 142, 156, 1),
// secondaryText: Color.fromRGBO(111, 122, 138, 1),
// placeholderText: Color.fromRGBO(51, 59, 70, 1),

// // placeholder: Color.fromRGBO(41, 49, 61, 1),
// // background: Color.fromRGBO(32, 38, 48, 1),
// // borderBase: Color.fromRGBO(51, 59, 70, 1), //#333B46
// // dividerColor:
// backgroundColor: Color.fromRGBO(30, 38, 48, 1),
// scaffoldBackgroundColor: Color.fromRGBO(22, 31, 38, 1),
const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Colors.yellow,
  onPrimary: Colors.white,
  secondary: Colors.white,
  onSecondary: Colors.green,
  error: Colors.red,
  onError: Colors.pink,
  background: Color.fromRGBO(22, 31, 38, 1),
  onBackground: Color.fromRGBO(234, 236, 239, 1),
  surface: Color.fromRGBO(30, 38, 48, 1),
  onSurface: Color.fromRGBO(132, 142, 156, 1),
);
void main() async {
  // Card()
  // ThemeData.from(color)
  // surfaceVariant
  // var p = CorePalette.of(Colors.yellow.shade50.value);
  // print(p.primary.get(1));
  EColors.light.mergaWith(
    primaryText: const Color.fromRGBO(32, 38, 48, 1), //Primary Text    主灰
    regularText: const Color.fromRGBO(132, 142, 156, 1), //Regular Text 常规灰，文字
    secondaryText: const Color.fromRGBO(146, 155, 165, 1),
    placeholderText: const Color.fromRGBO(181, 189, 199, 1),
    scaffoldBackgroundColor: const Color.fromRGBO(244, 245, 246, 1),
    backgroundColor: const Color.fromRGBO(254, 255, 255, 1),
    // placeholderColor: Color.fromRGBO(254, 255, 255, 1),
    // backgroundColor: Color.fromRGBO(244, 245, 246, 1),
  );
  EColors.dark.mergaWith(
    primaryText: const Color.fromRGBO(234, 236, 239, 1), //E6E8EB
    regularText: const Color.fromRGBO(132, 142, 156, 1),
    secondaryText: const Color.fromRGBO(111, 122, 138, 1),
    placeholderText: const Color.fromRGBO(51, 59, 70, 1),

    // placeholder: Color.fromRGBO(41, 49, 61, 1),
    // background: Color.fromRGBO(32, 38, 48, 1),
    // borderBase: Color.fromRGBO(51, 59, 70, 1), //#333B46
    // dividerColor:
    backgroundColor: const Color.fromRGBO(30, 38, 48, 1),
    scaffoldBackgroundColor: const Color.fromRGBO(22, 31, 38, 1),
  );
  WidgetsFlutterBinding.ensureInitialized();
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  runApp(MyApp(savedThemeMode: savedThemeMode));
}

class MyApp extends StatelessWidget {
  final AdaptiveThemeMode? savedThemeMode;
  const MyApp({Key? key, this.savedThemeMode}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Divider()
    return AdaptiveTheme(
      light: ThemeData.from(
        useMaterial3: true,
        // colorScheme: ColorScheme.fromSeed(
        //   seedColor: base,
        //   brightness: Brightness.light,
        // ),
        colorScheme: lightColorScheme,
      ).copyWith(
        appBarTheme: AppBarTheme(
          // surfaceTintColor: null,
          scrolledUnderElevation: 50,
          surfaceTintColor: Theme.of(context).colorScheme.surface,
          // backwardsCompatibility: false,
        ),
      ),
      dark: ThemeData.from(
        useMaterial3: true,
        // colorScheme: ColorScheme.fromSeed(
        //   seedColor: base,
        //   brightness: Brightness.dark,
        // ),
        colorScheme: darkColorScheme,
      ),
      initial: savedThemeMode ?? AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: theme,
        darkTheme: darkTheme,
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  bool sw = true;

  void _incrementCounter() {
    setState(() {
      // Colors.red.shade100;
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  // Widget hctWidget(int i) {
  //   var p = CorePalette.of(base.value);
  //   return [
  //     Styled.text(i.toString()).width(50),
  //     Styled.text(p.primary.get(i).toString()).width(100),
  //     Styled.text(
  //             "${Color(p.primary.get(i)).red.toString()},${Color(p.primary.get(i)).green.toString()},${Color(p.primary.get(i)).blue.toString()}")
  //         .width(100),
  //     Container(width: 100, height: 30, color: Color(p.primary.get(i)))
  //   ].toRow();
  // }

  // Widget hctsecWidget(int i) {
  //   var p = CorePalette.of(base.value);
  //   return [
  //     Styled.text(i.toString()).width(50),
  //     Styled.text(p.secondary.get(i).toString()).width(100),
  //     Styled.text(
  //             "${Color(p.secondary.get(i)).red.toString()},${Color(p.secondary.get(i)).green.toString()},${Color(p.secondary.get(i)).blue.toString()}")
  //         .width(100),
  //     Container(width: 100, height: 30, color: Color(p.secondary.get(i)))
  //   ].toRow();
  // }

  // Widget hctthrWidget(int i) {
  //   var p = CorePalette.of(base.value);
  //   return [
  //     Styled.text(i.toString()).width(50),
  //     Styled.text(p.tertiary.get(i).toString()).width(100),
  //     Styled.text(
  //             "${Color(p.tertiary.get(i)).red.toString()},${Color(p.tertiary.get(i)).green.toString()},${Color(p.tertiary.get(i)).blue.toString()}")
  //         .width(100),
  //     Container(width: 100, height: 30, color: Color(p.tertiary.get(i)))
  //   ].toRow();
  // }

  // Widget mixWidget(int i) {
  //   // var p = CorePalette.of(base.value);

  //   if (i < 51) {
  //     var c = Color.alphaBlend(base.withOpacity((1 / 50 * i)), Colors.white);
  //     return [
  //       Styled.text(i.toString()).width(50),
  //       Styled.text(c.value.toString()).width(100),
  //       Styled.text(
  //               "${c.red.toString()},${c.green.toString()},${c.blue.toString()}")
  //           .width(100),
  //       Container(width: 100, height: 30, color: c)
  //     ].toRow();
  //   } else {
  //     var c = Color.alphaBlend(
  //         base.withOpacity((1 / 50 * (100 - i))), Colors.black);
  //     return [
  //       Styled.text(i.toString()).width(50),
  //       Styled.text(c.value.toString()).width(100),
  //       Styled.text(
  //               "${c.red.toString()},${c.green.toString()},${c.blue.toString()}")
  //           .width(100),
  //       Container(width: 100, height: 30, color: c)
  //     ].toRow();
  //   }
  // }

  // Widget hslWidget(int i) {
  //   var c = HSLColor.fromColor(base).withLightness(i / 100).toColor();
  //   return [
  //     Styled.text(i.toString()).width(50),
  //     Styled.text(c.value.toString()).width(100),
  //     Styled.text(
  //             "${c.red.toString()},${c.green.toString()},${c.blue.toString()}")
  //         .width(100),
  //     Container(width: 100, height: 30, color: c)
  //   ].toRow();
  // }

  // Widget hsvWidget(int i) {
  //   var c = HSVColor.fromColor(base).withSaturation(i / 100).toColor();
  //   return [
  //     Styled.text(i.toString()).width(50),
  //     Styled.text(c.value.toString()).width(100),
  //     Styled.text(
  //             "${c.red.toString()},${c.green.toString()},${c.blue.toString()}")
  //         .width(100),
  //     Container(width: 100, height: 30, color: c)
  //   ].toRow();
  // }

  Widget colorCard(Color c) => Styled.text(
          "${c.red.toString()},${c.green.toString()},${c.blue.toString()}")
      .fontSize(12)
      .textColor(c.computeLuminance() < 0.5 ? Colors.white : Colors.black)
      .center()
      .width(100)
      .height(30)
      .backgroundColor(c);
  Widget colorGroup(String text, Color c) => [
        Styled.text(text)
            .fontSize(12)
            .alignment(Alignment.centerRight)
            .width(100)
            .padding(right: 10),
        colorCard(c)
      ].toRow();
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
// ColorScheme.light()
// IconButton(onPressed: onPressed, icon: icon)
    // Divider();
    // Theme.of(context).textTheme.displayMedium
    //  title
    //
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          EActionThemeSwith(
            light: EColors.light.scaffoldBackgroundColor,
            dark: EColors.dark.scaffoldBackgroundColor,
          ),
          const CloseButton()
        ],
      ),
      body: [
        Switch(
          value: sw,
          onChanged: (val) => setState(
            () {
              sw = val;
            },
          ),
        ),

        Card(
          child: Styled.text("ss").padding(all: 50),
        ).gestures(
          onTap: () => showAboutDialog(
            applicationName: "name",
            applicationIcon: const Icon(Icons.abc_outlined),
            applicationVersion: "1.0.0",
            applicationLegalese: "this is a document about our system",
            context: context,
          ),
        ),
        Card(
          child: Styled.text("ss").padding(all: 50),
        ).gestures(
            // onTap: () => showGeneralDialog(
            //   context: context,
            // ),
            ),
        [Chip(label: Styled.text("xx"))].toRow(),
        colorGroup("primary", EColors.light.primaryText),
        colorGroup("regular", EColors.light.regularText),
        colorGroup("secondary", EColors.light.secondaryText),
        colorGroup("placeholder", EColors.light.placeholderText),
        Styled.text("displayLarge",
            style: Theme.of(context).textTheme.displayLarge),
        Styled.text("displayMedium",
            style: Theme.of(context).textTheme.displayMedium),
        Styled.text("displaySmall",
            style: Theme.of(context).textTheme.displaySmall),

        Styled.text("headlineLarge",
            style: Theme.of(context).textTheme.headlineLarge),
        Styled.text("headlineMedium",
            style: Theme.of(context).textTheme.headlineMedium),
        Styled.text("headlineSmall",
            style: Theme.of(context).textTheme.headlineSmall),

        Styled.text("titleLarge",
            style: Theme.of(context).textTheme.titleLarge),
        Styled.text("titleMedium",
            style: Theme.of(context).textTheme.titleMedium),
        Styled.text("titleSmall",
            style: Theme.of(context).textTheme.titleSmall),

        Styled.text("bodyLarge", style: Theme.of(context).textTheme.bodyLarge),
        Styled.text("bodyMedium",
            style: Theme.of(context).textTheme.bodyMedium),
        Styled.text("bodySmall", style: Theme.of(context).textTheme.bodySmall),
        // Card
        // Theme
        // Styled.widget(),

        // ...List.generate(101, ((index) => index)).map(
        //   (i) => [
        //     // mixWidget(i),
        //     // const SizedBox(width: 50),
        //     // hslWidget(i),
        //     // const SizedBox(width: 50),
        //     // hsvWidget(i),
        //     // // Text("xx"),
        //     // const SizedBox(width: 50),
        //     // hctsecWidget(i),
        //     // const SizedBox(width: 50),
        //     // hctthrWidget(i),
        //   ].toRow(),
        // )
      ].toColumn().scrollable(),

      // body: Center(
      //   // Center is a layout widget. It takes a single child and positions it
      //   // in the middle of the parent.
      //   child: Column(
      //     // Column is also a layout widget. It takes a list of children and
      //     // arranges them vertically. By default, it sizes itself to fit its
      //     // children horizontally, and tries to be as tall as its parent.
      //     //
      //     // Invoke "debug painting" (press "p" in the console, choose the
      //     // "Toggle Debug Paint" action from the Flutter Inspector in Android
      //     // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
      //     // to see the wireframe for each widget.
      //     //
      //     // Column has various properties to control how it sizes itself and
      //     // how it positions its children. Here we use mainAxisAlignment to
      //     // center the children vertically; the main axis here is the vertical
      //     // axis because Columns are vertical (the cross axis would be
      //     // horizontal).
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: <Widget>[
      //       const Text(
      //         'You have pushed the button this many times:',
      //       ),
      //       Text(
      //         '$_counter',
      //         style: Theme.of(context).textTheme.headline4,
      //       ),
      //     ],
      //   ),
      // ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    ).parent(({required child}) => AnimatedTheme(
          data: Theme.of(context),
          child: child,
          // duration: Duration(milliseconds: 200),
        ));
  }
}
