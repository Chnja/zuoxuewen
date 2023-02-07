import 'dart:async';
import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class cWeb {
  var client;
  static String baseurl = "seat.lib.whu.edu.cn";
  String Cookie = "";

  cWeb() {
    client = http.Client();
    // TODO: 针对失效情况和系统维护状态的响应及提示
  }

  void _setCookie(http.Response response) async {
    String rawCookie = response.headers['set-cookie'] ?? "";
    if (rawCookie != "" && rawCookie.substring(0, 10) == "JSESSIONID") {
      Cookie = rawCookie;
    }
  }

  get(url, [Map<String, dynamic>? queryParameters = const {}]) async {
    var urls = Uri.https(baseurl, url, queryParameters);
    try {
      var response = await client.get(urls,
          headers: {"cookie": Cookie}).timeout(const Duration(seconds: 10));
      _setCookie(response);
      RegExp match = RegExp(r'<');
      if (match.hasMatch(response.body)) {
        match = RegExp(r'首页');
        if (match.hasMatch(response.body) && url != "login") {
          Fluttertoast.showToast(
            msg: "登录失效",
            timeInSecForIosWeb: 2,
          );
        }
        return response;
      }
      json.decode(response.body);
      return response;
    } on TimeoutException catch (_) {
      Fluttertoast.showToast(
        msg: "请求超时",
        timeInSecForIosWeb: 2,
      );
    } on FormatException catch (_) {
      Fluttertoast.showToast(
        msg: "系统错误",
        timeInSecForIosWeb: 2,
      );
    }
  }

  post(url, data) async {
    var urls = Uri.https(baseurl, url);
    var response =
        await client.post(urls, body: data, headers: {"cookie": Cookie});
    _setCookie(response);
    return response;
  }
}
