// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_wise_markdown/LaunchAdapter.dart';
// import 'package:flutter_wise_markdown/MarkDownPage.dart';
// import 'package:robot/pages/router.dart';
// import 'package:robot/uikit/MarkDownPage.dart';
// import 'package:url_launcher/url_launcher.dart';
part of flutter_wise_markdown;

// var onDataRefresh = FunctionFuture<String>()
// typedef Future<String> Function({CancelToken? cancelToken});
class WiseLaunchAdapter {
  static Future<String> Function(
      {String url,
      CancelToken? cancelToken,
      GlobalKey<RefreshIndicatorState>? refreshKey}) onUrlFetchRequest = (
          {CancelToken? cancelToken,
          String url = "",
          GlobalKey<RefreshIndicatorState>? refreshKey}) =>
      Future.error("界面未实现OnRefresh");
  static String htmlEncode(String text) {
    var url = text.replaceAll(r"\/", "<傻wf逼sdf义1>");
    url = url.replaceAll(r"\;", "<傻wf逼sdf义2>");
    url = url.replaceAll(r"\:", "<傻wf逼sdf义3>");
    return url;
  }

  static String htmlDecode(String text) {
    var url = text.replaceAll("<傻wf逼sdf义1>", r"/");
    url = url.replaceAll("<傻wf逼sdf义2>", r";");
    url = url.replaceAll("<傻wf逼sdf义3>", r":");
    return url;
  }

  static Map<String, String> getMdQuery(String url) {
    if (url.isEmpty) {
      return {};
    }
    var enco = htmlEncode(url);
    if (!enco.startsWith("<md>")) {
      return {};
    }

    enco = enco.substring(4);
    var endwith = enco.indexOf("</md>");
    if (endwith < 0) {
      return {};
    }
    Map<String, String> tmp = {};
    var pa = enco.substring(0, endwith);
    var content = enco.substring(endwith + 5);
    pa.split(";").forEach((element) {
      var kv = element.split(":");
      if (kv.length > 2) {
        return;
      }
      if (!htmlDecode(kv[0]).startsWith("s.md.")) {
        tmp["s.md.${htmlDecode(kv[0])}"] = htmlDecode(kv[1]);
      } else {
        tmp[htmlDecode(kv[0])] = htmlDecode(kv[1]);
      }
    });
    if (!tmp.containsKey("s.md.content")) {
      tmp["s.md.content"] = htmlDecode(content);
    }
    tmp["s.md"] = "true";
    return tmp;
  }

  static Future<void> go(BuildContext context, String url, String title,
      {required bool openInBrowser, bool? replace}) async {
    //md://s.md.replace:1
    if (url.isEmpty) {
      return;
    }
    Map<String, String>? parame = {};
    var u = Uri.tryParse(url);

    if (url.startsWith("<md>")) {
      parame = getMdQuery(url);
    } else if (url.indexOf("\n") > -1) {
      parame["s.md.content"] = url;
    } else if (u != null) {
      parame = u.queryParameters;
    }
    if (parame.containsKey("s.md.replace") &&
        (parame["s.md.replace"]!.toLowerCase() == "true" ||
            parame["s.md.replace"]!.toLowerCase() == "1" ||
            parame["s.md.replace"]!.toLowerCase() == "yes")) {
      if (replace == null) {
        replace = true;
      } //通过inline 的方式强制设置设置替换页面的方式打开
      //强制替换页面
    }

    int? exitmillSecound;
    if (parame.containsKey("s.md.exit")) {
      exitmillSecound = int.tryParse(parame["s.md.exit"]!);
    }

    //system.markdown.title
    if (parame.containsKey("s.md.title")) {
      title = parame["s.md.title"]!; //通过inline 的方式强制设置设置替换页面的方式打开
      //强制替换页面
    }

    //inbro 参数，强制指定是否在浏览器显示
    //system.urlLaunch.inbro
    if (parame.containsKey("s.u.inbro") &&
        (parame["s.u.inbro"]!.toLowerCase() == "true" ||
            parame["s.u.inbro"]!.toLowerCase() == "1" ||
            parame["s.u.inbro"]!.toLowerCase() == "yes")) {
      openInBrowser = true;
    } else if (parame.containsKey("s.u.inbro") &&
        (parame["s.u.inbro"]!.toLowerCase() == "false" ||
            parame["s.u.inbro"]!.toLowerCase() == "0" ||
            parame["s.u.inbro"]!.toLowerCase() == "no")) {
      openInBrowser = false;
    }

    //system.usemarkdown
    if (parame.containsKey("s.md.content")) {
      showAnimatePage(
        context,
        MarkDownPage(title: title, content: parame["s.md.content"] ?? ""),
        replace: replace ?? false,
        fullscreenDialog: false,
      );
    } else if (parame.containsKey("s.md") &&
        (parame["s.md"]!.toLowerCase() == "true" ||
            parame["s.md"]!.toLowerCase() == "1" ||
            parame["s.md"]!.toLowerCase() == "yes")) {
      //强制使用markdown协议解析网址
      showAnimatePage(
        context,
        MarkDownPage(title: title, content: "", url: url),
        replace: replace ?? false,
        fullscreenDialog: false,
      );
    } else if ((u?.path ?? "").endsWith(".md") || url.endsWith(".md")) {
      //针对md结尾的，或者path以md结尾的，也强制转换了算球
      showAnimatePage(
        context,
        MarkDownPage(title: title, content: "", url: url),
        replace: replace ?? false,
        fullscreenDialog: false,
      );
    } else {
      LaunchAdapter.go(url, openInBrowser: openInBrowser);
    }

    if (exitmillSecound != null) {
      Future.delayed(Duration(milliseconds: exitmillSecound), () {
        exit(0);
      });
    }
  }
}
