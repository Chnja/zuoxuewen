import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class CWeb {
  static const String baseurl = "seat.lib.whu.edu.cn";
  static String Cookie = "";
  late http.Client client;

  CWeb() {
    client = http.Client();
  }

  void _setCookie(http.Response response) async {
    String rawCookie = response.headers['set-cookie'] ?? "";
    if (rawCookie != "" && rawCookie.substring(0, 10) == "JSESSIONID") {
      Cookie = rawCookie;
    }
  }

  get(String url, [Map<String, dynamic>? queryParameters]) async {
    var urls = Uri.https(baseurl, url, queryParameters);
    try {
      var response = await client.get(urls,
          headers: {"cookie": Cookie}).timeout(const Duration(seconds: 10));
      if (respHandle(response)) {
        _setCookie(response);
        return response;
      }
    } on TimeoutException catch (_) {
      Fluttertoast.showToast(
        msg: "请求超时",
        timeInSecForIosWeb: 2,
      );
    }
  }

  post(String url, Map data) async {
    var urls = Uri.https(baseurl, url);
    try {
      var response = await client.post(urls,
          body: data,
          headers: {"cookie": Cookie}).timeout(const Duration(seconds: 10));
      if (respHandle(response)) {
        _setCookie(response);
        return response;
      }
    } on TimeoutException catch (_) {
      Fluttertoast.showToast(
        msg: "请求超时",
        timeInSecForIosWeb: 2,
      );
    }
  }

  bool respHandle(http.Response response) {
    if (Routes.history.length == 1 && Routes.history[0] == Routes.home) {
      return true;
    }
    if (response.statusCode == 302) {
      return true;
    }
    RegExp match = RegExp(r'<');
    if (match.hasMatch(response.body)) {
      match = RegExp(r'首页');
      if (match.hasMatch(response.body)) {
        Fluttertoast.showToast(
          msg: "登录失效",
          timeInSecForIosWeb: 2,
        );
        Routes.pushReset(Routes.home);
        return false;
      }
      return true;
    }
    try {
      json.decode(response.body);
      return true;
    } on FormatException catch (_) {
      Fluttertoast.showToast(
        msg: "系统错误",
        timeInSecForIosWeb: 2,
      );
      Routes.pushReset(Routes.home);
      return false;
    }
  }
}

class Routes {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  static NavigatorState navigation = navigatorKey.currentState!;
  static const String home = "/login";
  static List<String> history = [home];

  static Future pushReset(String name) {
    history = [name];
    return navigation.pushNamedAndRemoveUntil(name, (route) => false);
  }
}

List timeStartEnd([String baseStart = "8:00", String baseEnd = "22:30"]) {
  List tmp = baseStart.split(":");
  int baseStartStamp = int.parse(tmp[0]) * 60 + int.parse(tmp[1]);
  tmp = baseEnd.split(":");
  int endStamp = int.parse(tmp[0]) * 60 + int.parse(tmp[1]);
  DateTime now = DateTime.now();
  int nowStamp = now.hour * 60 + now.minute;

  int startStamp = (nowStamp < baseStartStamp ? baseStartStamp : nowStamp);

  int hour = startStamp ~/ 60;
  int minute = startStamp % 60;
  String timeStart = "";
  if (minute >= 31) {
    timeStart = "${hour + 1}:00";
    startStamp = (hour + 1) * 60;
  } else if (minute >= 1) {
    timeStart = "$hour:30";
    startStamp = hour * 60 + 30;
  } else {
    timeStart = "$hour:00";
    startStamp = hour * 60;
  }

  hour = endStamp ~/ 60;
  minute = endStamp % 60;
  String timeEnd = "";
  if (minute >= 30) {
    timeEnd = "$hour:30";
    endStamp = hour * 60 + 30;
  } else {
    timeEnd = "$hour:00";
    endStamp = hour * 60;
  }

  if (startStamp >= endStamp) {
    return ["无可用时间", "无可用时间"];
  }
  return [timeStart, timeEnd];
}

Map timeRange(startTime, endTime) {
  if (startTime == "无可用时间") {
    return {"无可用时间": "无可用时间"};
  } else {
    var startT = startTime.split(":");
    startT = [double.parse(startT[0]), double.parse(startT[1])];
    var endT = endTime.split(":");
    endT = [double.parse(endT[0]), double.parse(endT[1])];
    double startNum = 0;
    double endNum = 0;
    if (startT[1] == 0) {
      startNum = startT[0];
    } else if (startT[1] <= 30) {
      startNum = startT[0] + 0.5;
    } else {
      startNum = startT[0] + 1;
    }
    if (endT[1] == 30) {
      endNum = endT[0] + 0.5;
    } else {
      endNum = endT[0];
    }
    Map multiData = {};
    for (double x = startNum; x < endNum; x += 0.5) {
      String tmp1 = "${x.truncate()}:${x > x.truncate() ? '30' : '00'}";
      multiData[tmp1] = [];
      for (double y = x + 0.5; y <= endNum; y += 0.5) {
        String tmp2 = "${y.truncate()}:${y > y.truncate() ? '30' : '00'}";
        multiData[tmp1].add(tmp2);
      }
    }
    return multiData;
  }
}
