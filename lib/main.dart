import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import "./utils/web.dart";
import 'package:fluttertoast/fluttertoast.dart';
import "./libin.dart";
// import "./zhlj.dart";

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark));
  runApp(const zxwApp());
}

class zxwApp extends StatelessWidget {
  const zxwApp({super.key});

  @override
  Widget build(BuildContext context) {
    late DateTime lastPopTime;
    return MaterialApp(
      title: '座学问',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        Routes.home: (context) => const LogIn(),
        "/libin": (context) => const LibIn()
        // Routes.toLoginPage: (context) => const LogIn()
      },
      initialRoute: Routes.home,
      navigatorKey: Routes.navigatorKey,
    );
  }
}

class LogIn extends StatelessWidget {
  const LogIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            margin: const EdgeInsets.fromLTRB(60, 100, 60, 20),
            child: Column(mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      margin: const EdgeInsets.only(bottom: 50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "images/chair.png",
                            width: 60,
                            height: 60,
                          ),
                          Container(
                              margin: const EdgeInsets.only(left: 10),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      width: 3, color: Colors.yellow),
                                ),
                              ),
                              child: const Text("座学问",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                  )))
                        ],
                      )),
                  const loginbody()
                ])));
  }
}

class loginbody extends StatefulWidget {
  const loginbody({super.key});

  @override
  State<loginbody> createState() => _loginbody();
}

class _loginbody extends State<loginbody> {
  TextEditingController idController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController capController = TextEditingController();
  final ValueNotifier<bool> _canLogin = ValueNotifier<bool>(false);
  final ValueNotifier<String> _Cap = ValueNotifier<String>("");
  String capid = "";
  String SToken = "";
  CWeb w = CWeb();

  void idlisten([String? value]) {
    _canLogin.value = (idController.text.length == 13 &&
        pwdController.text != "" &&
        capController.text.length == 4);
    // _canLogin.value = (capController.text.length == 4);
  }

  void fresh() {
    // print("fresh");
    capController.clear();
    _Cap.value = "";
    idlisten();
    w.get('login').then((resp) {
      // print(resp.headers);
      RegExp match = RegExp(r'SYNCHRONIZER_TOKEN" value="([^]*?)"');
      var matchres = match.firstMatch(resp.body);
      SToken = matchres?.group(1) ?? "";
      w.get('auth/createCaptcha').then((resp) {
        var res = json.decode(resp.body);
        capid = res["captchaId"];
        var CaptchaCode = res["captchaImage"].split(',')[1];
        _Cap.value = CaptchaCode;
      });
    });
  }

  void login() {
    w.post("auth/signIn", {
      "SYNCHRONIZER_TOKEN": SToken,
      "SYNCHRONIZER_URI": "/login",
      "username": idController.text,
      "password": pwdController.text,
      "captchaId": capid,
      "answer": capController.text,
      "authid": "-1"
    }).then((resp) {
      var loc = resp.headers["location"];
      if (loc != null) {
        if (loc.contains("username")) {
          Fluttertoast.showToast(
            msg: "学号或密码错误",
            timeInSecForIosWeb: 2,
          );
          fresh();
        } else if (loc.contains("auth")) {
          Fluttertoast.showToast(
            msg: "验证码错误",
            timeInSecForIosWeb: 2,
          );
          fresh();
        } else if (loc == "https://seat.lib.whu.edu.cn/") {
          SharedPreferences.getInstance().then((prefs) {
            if (saveID) {
              prefs.setString(
                  "saveID",
                  json.encode(
                      {"id": idController.text, "pwd": pwdController.text}));
            } else {
              prefs.remove("saveID");
            }
          });
          Fluttertoast.showToast(
            msg: "登录成功",
            timeInSecForIosWeb: 2,
          );
          Routes.pushReset("/libin");
        }
      } else {
        Fluttertoast.showToast(
          msg: "系统错误",
          timeInSecForIosWeb: 2,
        );
        fresh();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fresh();
    SharedPreferences.getInstance().then((prefs) {
      var tmp = prefs.getString("saveID");
      if (tmp != null) {
        Map tmpj = json.decode(tmp);
        idController.text = tmpj["id"];
        pwdController.text = tmpj["pwd"];
        setState(() {
          saveID = true;
        });
        FocusScope.of(context).requestFocus(_capFocus);
      }
    });
  }

  var lastPopTime;
  bool saveID = false;
  final FocusNode _capFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (lastPopTime == null ||
              DateTime.now().difference(lastPopTime) >
                  const Duration(seconds: 2)) {
            lastPopTime = DateTime.now();
            Fluttertoast.showToast(
              msg: "再按一次退出",
              timeInSecForIosWeb: 2,
            );
            return false;
          } else {
            return true;
          }
        },
        child: Column(
          children: [
            TextField(
                autofocus: true,
                controller: idController,
                keyboardType: TextInputType.number,
                onChanged: idlisten,
                decoration: const InputDecoration(
                  hintText: "学号",
                )),
            const SizedBox(
              height: 20,
            ),
            TextField(
              decoration: const InputDecoration(hintText: "密码"),
              obscureText: true,
              controller: pwdController,
              onChanged: idlisten,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.only(right: 15),
                    child: TextField(
                      focusNode: _capFocus,
                      controller: capController,
                      onChanged: idlisten,
                      decoration: const InputDecoration(hintText: "验证码"),
                      // controller: pwdController,
                    ),
                  ),
                ),
                Expanded(
                    flex: 0,
                    child: GestureDetector(
                        onTap: fresh,
                        child: SizedBox(
                            height: 48,
                            width: 100,
                            child: ValueListenableBuilder<String>(
                              builder: _buildforcap,
                              valueListenable: _Cap,
                            ))))
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                      height: 20,
                      width: 25,
                      child: Checkbox(
                          value: saveID,
                          onChanged: (value) {
                            setState(() {
                              saveID = value!;
                            });
                          })),
                  const Text("保存用户名和密码",
                      style: TextStyle(color: Colors.black45))
                ],
              ),
              SizedBox(
                  width: 70,
                  height: 70,
                  child: ValueListenableBuilder<bool>(
                    builder: _buildforlogin,
                    valueListenable: _canLogin,
                  ))
            ])
          ],
        ));
  }

  Widget _buildforcap(BuildContext context, String value, Widget? child) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: value == ""
          ? Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                size: 25,
                color: Colors.black38,
              ),
            )
          : Image.memory(
              base64Decode(value),
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.white,
                );
              },
            ),
    );
  }

  Widget _buildforlogin(BuildContext context, bool value, Widget? child) {
    if (value) {
      return ElevatedButton(
        onPressed: login,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.blue),
          foregroundColor: MaterialStateProperty.all(Colors.white),
          shape: MaterialStateProperty.all(const CircleBorder()),
        ),
        child: const Icon(Icons.keyboard_arrow_right),
      );
    } else {
      return Container();
    }
  }
}
