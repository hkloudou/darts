// import 'package:robot/status/AuthStatus.dart';

part of flutter_wise_markdown;
class LaunchAdapter {
  static Future<void> go(String url,
      {required  bool openInBrowser}) async {
    if (url.isEmpty) {
      return;
    }

    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: !openInBrowser,
        forceWebView: !openInBrowser,
        enableJavaScript: true,
        enableDomStorage: true,
        // headers: <String, String>{'token': ""},
        webOnlyWindowName: "_self",
      );
    } else {
      throw 'Could not launch $url';
    }
  }
}
