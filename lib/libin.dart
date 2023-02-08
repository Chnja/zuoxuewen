import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import "./utils/web.dart";
import './roomSelect.dart';
import "./timeChange.dart";

class LibIn extends StatelessWidget {
  const LibIn({
    Key? key,
    required this.w,
  }) : super(key: key);
  final CWeb w;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '座学问',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          body: libinbody(w: w),
        ),
        builder: EasyLoading.init());
  }
}

class libinbody extends StatefulWidget {
  const libinbody({
    Key? key,
    required this.w,
  }) : super(key: key);
  final CWeb w;

  @override
  State<libinbody> createState() => _libinbody();
}

class _libinbody extends State<libinbody> {
  late final CWeb w;
  List bookshow = [
    {"value": "pz", "name": "凭证号"},
    {"value": "date", "name": "日　期"},
    {"value": "time", "name": "时　间"},
    {"value": "loc", "name": "位　置"},
    {"value": "num", "name": "座位号"},
    {"value": "status", "name": "状　态"}
  ];
  final ValueNotifier<Map> _bookStatus = ValueNotifier<Map>({"loading": true});
  final ValueNotifier<bool> _bookButtonShow = ValueNotifier<bool>(false);
  final ValueNotifier<Map> _cloudStatus = ValueNotifier<Map>({"status": 0});
  var lastPopTime;

  // bool bookButtonShow = true;

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
            ValueListenableBuilder(
                valueListenable: _bookStatus, builder: _buildforbook),
            ValueListenableBuilder(
                valueListenable: _bookButtonShow, builder: _buildforbookbutton),
            ValueListenableBuilder(
                valueListenable: _cloudStatus, builder: _buildforcloud),
          ],
        ));
  }

  Future<void> bindBook() async {
    final prefs = await SharedPreferences.getInstance();
    String? tmp = prefs.getString("libList");
    List showRoomId = [];
    if (tmp != null) {
      Map tmpj = json.decode(tmp);
      List libList = tmpj["libList"];
      // building = libList.length;
      for (var i in libList) {
        showRoomId.add({"name": i["name"], 'id': i["id"], "room": []});
        int index = 0;
        for (var x in i["floor"]) {
          var tmp = x["name"].replaceAll(RegExp(i["name"]), "");
          for (var y in x["room"]) {
            // showRoomId[showRoomId.length - 1]["room"]
            //     .add({"name": '$tmp-${y["name"]}', "id": y["id"]});
            showRoomId[showRoomId.length - 1]["room"].add({
              "name": '${y["name"]}',
              "id": y["id"],
              "floor": tmp,
              "checked": 0,
              "seats": y["seat"].length,
              "index": index
            });
            index++;
          }
        }
      }
    } else {
      return;
    }
    showRoomId.removeWhere((e) => e["room"].length == 0);
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        barrierColor: Colors.black26,
        backgroundColor: Colors.transparent,
        builder: (context) {
          // return ValueListenableBuilder(
          //     valueListenable: _showRoomId, builder: _buildforroom);
          return roomSelect(
            showRoomId: showRoomId,
            w: w,
            onFresh: refresh,
          );
        });
  }

  Widget _buildforbook(BuildContext context, Map value, Widget? child) {
    // GlobalKey _globalKey = GlobalKey();
    return Container(
      // key:_globalKey,
      margin: const EdgeInsets.fromLTRB(30, 60, 30, 20),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 15),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 0),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      // height: _globalKey.currentContext?.size?.height,
      child: AnimatedSize(
        alignment: Alignment.topCenter,
        duration: const Duration(milliseconds: 300),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 3, color: Colors.yellow),
                    ),
                  ),
                  child: const Text(
                    "我的座位",
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.black26,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                ElevatedButton(
                    onPressed: refresh,
                    style: ButtonStyle(
                        elevation: MaterialStateProperty.all(0),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)))),
                    child: Row(
                      children: const [
                        Icon(Icons.refresh),
                        SizedBox(width: 5),
                        Text("刷新"),
                      ],
                    ))
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            !value["loading"]
                ? (value["status"] != "0"
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: bookshow
                                .map((e) => Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 3),
                                    child: Text.rich(TextSpan(children: [
                                      TextSpan(
                                        text: "${e['name']}：",
                                        style: const TextStyle(
                                          color: Colors.black45,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "${value[e['value']]}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ]))))
                                .toList(),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                  onPressed: bindchange,
                                  style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(0),
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.orange.shade50),
                                    foregroundColor: MaterialStateProperty.all(
                                        Colors.orange),
                                    // shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                    //     borderRadius: BorderRadius.circular(5)))
                                  ),
                                  child: const Text("变更时间")),
                              ElevatedButton(
                                onPressed: () async {
                                  await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          content: const Text("确定要取消预约吗?"),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                style: ButtonStyle(
                                                    overlayColor:
                                                        MaterialStateProperty
                                                            .all(Colors
                                                                .grey.shade50),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.grey)),
                                                child: const Text("点错了")),
                                            TextButton(
                                                style: ButtonStyle(
                                                    overlayColor:
                                                        MaterialStateProperty
                                                            .all(Colors
                                                                .red.shade50),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.red)),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  bindcancel();
                                                },
                                                child: const Text("确定取消"))
                                          ],
                                        );
                                      });
                                },
                                style: ButtonStyle(
                                  elevation: MaterialStateProperty.all(0),
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.grey.shade200),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.red),
                                  // shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                  //     borderRadius: BorderRadius.circular(5)))
                                ),
                                child: const Text("取消预约"),
                              )
                            ],
                          )
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Icon(Icons.sentiment_dissatisfied_rounded, size: 16),
                          SizedBox(width: 2),
                          Text("当前没有预约")
                        ],
                      ))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(width: 2),
                      LoadingAnimationWidget.inkDrop(
                        size: 16,
                        color: Colors.black38,
                      ),
                      const SizedBox(width: 8),
                      const Text("加载中...")
                    ],
                  )
          ],
        ),
      ),
    );
  }

  void bindchange() {
    List tmp = _bookStatus.value["time"].split("-");
    showModalBottomSheet(
        context: context,
        // isScrollControlled: true,
        barrierColor: Colors.black26,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return timeChange(
            w: w,
            cancel: bindcancel,
            bookStatus: {
              "date": _bookStatus.value["date"],
              "start": tmp[0],
              "end": tmp[1]
            },
            onFresh: refresh,
          );
        });
  }

  Widget _buildforbookbutton(BuildContext context, bool value, Widget? child) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      alignment: Alignment.topCenter,
      child: value
          ? Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.symmetric(horizontal: 30),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: bindBook,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.green),
                ),
                child: const Text(
                  "快速选座",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            )
          : Container(
              height: 8,
            ),
    );
  }

  void checkBookButton() {
    if (_bookStatus.value["status"] == "0" &&
        _cloudStatus.value["status"] == 2) {
      _bookButtonShow.value = true;
    } else {
      _bookButtonShow.value = false;
    }
    // print(_bookButtonShow.value);
  }

  Widget _buildforcloud(BuildContext context, Map value, Widget? child) {
    return Container(
        margin: const EdgeInsets.fromLTRB(30, 0, 30, 20),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 0),
              blurRadius: 20,
              spreadRadius: 1,
            ),
          ],
        ),
        child: AnimatedSize(
            alignment: Alignment.topCenter,
            duration: const Duration(milliseconds: 300),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "本地数据",
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                    ),
                    value["status"] == 0
                        ? const Text("本地无数据",
                            style: TextStyle(color: Colors.black26))
                        : (value["status"] == 2
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${value["cloudTime"]}",
                                      style: const TextStyle(
                                          color: Colors.black26)),
                                  Text(
                                      "${value["building"]}×场馆 ${value["floor"]}×楼层 ${value["room"]}×房间 ${value["seat"]}×座位"),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  value["loadingShow"].length == 0
                                      ? Row(
                                          children: [
                                            LoadingAnimationWidget
                                                .threeArchedCircle(
                                              size: 14,
                                              color: Colors.black38,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text("加载中...")
                                          ],
                                        )
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: value["loadingShow"]
                                              .map<Widget>((e) => Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 3),
                                                  child: Row(
                                                    children: [
                                                      e["status"] == 0
                                                          ? const Icon(
                                                              Icons.more_horiz,
                                                              size: 14,
                                                            )
                                                          : (e["status"] == 1
                                                              ? LoadingAnimationWidget
                                                                  .threeArchedCircle(
                                                                  size: 14,
                                                                  color: Colors
                                                                      .black38,
                                                                )
                                                              : const Icon(
                                                                  Icons.check,
                                                                  size: 14,
                                                                )),
                                                      const SizedBox(width: 8),
                                                      Text.rich(TextSpan(
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .black26),
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  "${e['name']}  ",
                                                              style: const TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                            e["status"] == 0
                                                                ? const TextSpan()
                                                                : (e["status"] ==
                                                                        1
                                                                    ? TextSpan(
                                                                        text:
                                                                            "${e['floornow'] + 1}/${e['floors']}层 ${e['roomnow']}/${e['rooms']}房间")
                                                                    : (e["status"] ==
                                                                            2
                                                                        ? TextSpan(
                                                                            text:
                                                                                "${e['floors']}层 ${e['rooms']}房间")
                                                                        : const TextSpan()))
                                                          ])),
                                                    ],
                                                  )))
                                              .toList(),
                                        )
                                ],
                              ))
                  ],
                ),
                value["status"] != 1
                    ? ElevatedButton(
                        onPressed: cloudFresh,
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(0),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue.shade50),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.blue),
                          // shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          //     borderRadius: BorderRadius.circular(5)))
                        ),
                        child: const Text("更新"))
                    : Container(),
              ],
            )));
  }

  Future<void> refresh() async {
    Map bookStatusTemp = {"loading": true};
    _bookStatus.value = bookStatusTemp;
    bookStatusTemp = {"loading": false};
    var resp = await w.get("history");
    // print(resp.body);
    RegExp match = RegExp(r'<dl>([^]*?)</dl>');
    var historys = match.allMatches(resp.body);
    List<String?> hs = historys.map((h) => h.group(1)).toList();
    for (String? hr in hs) {
      match = RegExp(r'已预约');
      if (match.hasMatch(hr!)) {
        match = RegExp(r'<form([^]*?)</form>');
        var matchres = match.firstMatch(hr);
        String? bookNow = matchres?.group(1);
        match = RegExp(r'TOKEN" value="([^]*?)"');
        matchres = match.firstMatch(bookNow!);
        bookStatusTemp["token"] = matchres?.group(1);
        match = RegExp(r'id" value="([^]*?)"');
        matchres = match.firstMatch(bookNow!);
        bookStatusTemp["id"] = matchres?.group(1);
        // print(bookStatus);
        resp = await w.get("view", {"id": bookStatusTemp["id"]});
        match = RegExp(r'</em>([^]*?)</dd>');
        var matchress = match.allMatches(resp.body);
        List<String?> matchResults = matchress.map((e) => e.group(1)).toList();
        // print(matchress(0));
        bookStatusTemp["pz"] = matchResults[0];
        bookStatusTemp["date"] = matchResults[1]?.replaceAll(RegExp(r' '), "");
        bookStatusTemp["time"] = matchResults[2]?.replaceAll(RegExp(r' '), "");
        bookStatusTemp["loc"] = matchResults[3]?.split('，座位号')[0];
        bookStatusTemp["num"] = matchResults[3]?.split('，座位号')[1];
        bookStatusTemp["status"] = matchResults[4];
        // print(bookStatusTemp);
        _bookStatus.value = bookStatusTemp;
        checkBookButton();
        return;
      }
      match = RegExp(r'使用中');
      RegExp match2 = RegExp(r'已暂时离开');
      if (match.hasMatch(hr!) || match2.hasMatch(hr!)) {
        match = RegExp(r'id=([^]*?)&');
        var matchres = match.firstMatch(hr!);
        bookStatusTemp["id"] = matchres?.group(1);
        // print(bookStatus);
        resp = await w.get("view", {"id": bookStatusTemp["id"]});
        match = RegExp(r'</em>([^]*?)</dd>');
        var matchress = match.allMatches(resp.body);
        List<String?> matchResults = matchress.map((e) => e.group(1)).toList();
        bookStatusTemp["pz"] = matchResults[0];
        bookStatusTemp["date"] = matchResults[1]?.replaceAll(RegExp(r' '), "");
        bookStatusTemp["time"] = matchResults[2]?.replaceAll(RegExp(r' '), "");
        bookStatusTemp["loc"] = matchResults[3]?.split('，座位号')[0];
        bookStatusTemp["num"] = matchResults[3]?.split('，座位号')[1];
        bookStatusTemp["status"] = matchResults[4];
        _bookStatus.value = bookStatusTemp;
        checkBookButton();
        return;
      }
    }
    bookStatusTemp["status"] = "0";
    _bookStatus.value = bookStatusTemp;
    checkBookButton();
    return;
  }

  Future<void> bindcancel() async {
    EasyLoading.show(status: '刷新中...');
    await refresh();
    if (_bookStatus.value["status"] != "0") {
      if (_bookStatus.value["token"] == null) {
        await stop();
      } else {
        await cancel();
      }
      await refresh();
    } else {
      EasyLoading.showError('失败');
      EasyLoading.dismiss();
    }
  }

  Future<void> cancel() async {
    EasyLoading.show(status: '取消中...');
    var resp = await w.post("reservation/cancel", {
      "SYNCHRONIZER_TOKEN": _bookStatus.value["token"],
      "SYNCHRONIZER_URI": "/history",
      "id": _bookStatus.value["id"]
    });
    if (resp.statusCode == 302) {
      EasyLoading.showSuccess('取消成功');
      EasyLoading.dismiss();
    } else {
      EasyLoading.showError('取消失败');
      EasyLoading.dismiss();
    }
    return;
  }

  Future<void> stop() async {
    EasyLoading.show(status: '结束中...');
    var resp = await w.get("user/stopUsing");
    var body = json.decode(resp.body);
    if (body["status"] == "success") {
      EasyLoading.showSuccess('结束成功');
      EasyLoading.dismiss();
    } else {
      EasyLoading.showError('结束失败');
      EasyLoading.dismiss();
    }
    return;
  }

  Future<void> cloudFresh() async {
    _cloudStatus.value = {"status": 1, "loadingShow": []};
    checkBookButton();
    var now = DateTime.now();
    String date = "${now.year}-${now.month}-${now.day}";
    var resp = await w.get("map");
    RegExp match = RegExp(r"<p id='options_building'>([^]*?)</p>");
    var matchres = match.firstMatch(resp.body);
    String buildingbody = matchres?.group(1) ?? "";
    match = RegExp(r"value='([^]*?)<");
    var matchress = match.allMatches(buildingbody);
    var loadingShow = [];
    List libList = matchress.map((e) {
      var tmp = e?.group(1)?.split("'>");
      loadingShow.add({"status": 0, "name": tmp?[1]});
      return {"id": tmp?[0], "name": tmp?[1], "floor": []};
    }).toList();
    _cloudStatus.value["loadingShow"] = loadingShow;
    var loadingBuilding = 0;
    for (var i in libList) {
      _cloudStatus.value["loadingShow"][loadingBuilding] = {
        "name": _cloudStatus.value["loadingShow"][loadingBuilding]["name"],
        "status": 1,
        "rooms": 0,
        "roomnow": 0,
        "floors": 0,
        "floornow": 0
      };
      // _cloudStatus.value["loadingShow"][loadingBuilding]["status"] = 1;
      _cloudStatus.value = json.decode(json.encode(_cloudStatus.value));
      resp = await w.get("mapBook/ajaxGetFloor", {"id": i["id"]});
      match = RegExp(r'value="([^]*?)<');
      matchress = match.allMatches(resp.body);
      List floorList = matchress.map((e) {
        var tmp = e?.group(1)?.split('">');
        return {"id": tmp?[0], "name": tmp?[1], "room": []};
      }).toList();
      _cloudStatus.value["loadingShow"][loadingBuilding]["floors"] =
          floorList.length;
      var loadingFloor = 0;
      var loadingRoom = 0;
      // _cloudStatus.value["loadingShow"][loadingBuilding]["rooms"] = 0;
      for (var x in floorList) {
        _cloudStatus.value["loadingShow"][loadingBuilding]["floornow"] =
            loadingFloor;
        _cloudStatus.value = json.decode(json.encode(_cloudStatus.value));
        resp = await w.get("mapBook/ajaxGetRooms",
            {"building": i["id"], "floor": x["id"], "onDate": date});
        // print(x);
        var res = json.decode(resp.body);
        var roomList = [];
        if (res["rooms"] == null) {
          roomList = [];
        } else {
          roomList = res["rooms"];
        }
        _cloudStatus.value["loadingShow"][loadingBuilding]["rooms"] +=
            roomList.length;
        for (var y in roomList) {
          _cloudStatus.value["loadingShow"][loadingBuilding]["roomnow"] =
              loadingRoom;
          _cloudStatus.value = json.decode(json.encode(_cloudStatus.value));
          resp = await w.get(
              "mapBook/getSeatsByRoom", {"room": '${y["id"]}', "onDate": date});
          await Future.delayed(const Duration(milliseconds: 500), () {});
          // print(y);
          match = RegExp(r'<li id([^]*?)</li>');
          matchress = match.allMatches(resp.body);
          List seatList = matchress.map((e) {
            var tmp = e?.group(1);
            var tmpid = RegExp(r'seat_([^]*?)"');
            var tmpname = RegExp(r'seatNum">([^]*?)<');
            return {
              "id": tmpid.firstMatch(tmp ?? "")?.group(1),
              "name": tmpname.firstMatch(tmp ?? "")?.group(1),
            };
          }).toList();
          // print(seatList.length);
          y["seat"] = seatList;
          loadingRoom += 1;
        }
        x["room"] = roomList;
        loadingFloor += 1;
        // print(resp.body["rooms"]);
      }
      i["floor"] = floorList;
      _cloudStatus.value["loadingShow"][loadingBuilding]["status"] = 2;
      _cloudStatus.value = json.decode(json.encode(_cloudStatus.value));
      loadingBuilding += 1;
    }
    // print(libList);
    String cloudTime =
        "${now.year}/${now.month}/${now.day} ${now.hour}:${now.minute}";
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        "libList", json.encode({"cloudTime": cloudTime, "libList": libList}));
    cloudLoad();
    return;
  }

  Future<void> cloudLoad() async {
    final prefs = await SharedPreferences.getInstance();
    String? tmp = prefs.getString("libList");
    if (tmp != null) {
      Map tmpj = json.decode(tmp);
      List libList = tmpj["libList"];
      num building = 0;
      num floor = 0;
      num room = 0;
      num seat = 0;
      building = libList.length;
      for (var i in libList) {
        floor += i["floor"].length;
        for (var x in i["floor"]) {
          room += x["room"].length;
          for (var y in x["room"]) {
            seat += y["seat"].length;
          }
        }
      }
      _cloudStatus.value = {
        "status": 2,
        "cloudTime": tmpj["cloudTime"],
        "building": building,
        "floor": floor,
        "room": room,
        "seat": seat
      };
    }
    checkBookButton();
    return;
  }

  @override
  void initState() {
    super.initState();
    w = widget.w;
    // print("init");
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.cubeGrid;
    EasyLoading.instance.maskType = EasyLoadingMaskType.clear;
    refresh();
    cloudLoad();
  }
}
