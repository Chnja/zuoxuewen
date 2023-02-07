// import 'dart:convert';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/default_style.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import "./utils/CCheckboxList.dart";
import "./utils/web.dart";

class roomSelect extends StatefulWidget {
  const roomSelect({
    super.key,
    required this.showRoomId,
    required this.w,
    required this.onFresh,
  });

  final List showRoomId;
  final cWeb w;
  final Function onFresh;

  @override
  State<roomSelect> createState() => _roomSelectbody();
}

class _roomSelectbody extends State<roomSelect> {
  late final List showRoomId;
  late final cWeb w;
  late final Function onFresh;
  late Size Msize;
  Map timeSwitch = {};
  int barIndex = 0;
  List selectRooms = [];
  Map booking = {"status": 0, "msg": ""};
  Map moreSwitch = {"window": 2, "power": 1, "round": false};
  Map windowpower = {
    "window": ["不靠窗", "靠窗", "不限靠窗"],
    "power": ["无电源", "有电源", "不限电源"]
  };

  @override
  Widget build(BuildContext context) {
    Msize = MediaQuery.of(context).size;
    return Container(
      // height: 600,
      height: Msize.height * 5 / 6,
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: DefaultTabController(
          length: showRoomId.length,
          child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(200),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                              onPressed: selectTime,
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(0),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.green.shade50),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.black),
                              ),
                              child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  width: 120,
                                  child: Column(
                                    children: [
                                      const Text("开始时间"),
                                      Text(
                                        "${timeSwitch['start']}",
                                        style: const TextStyle(fontSize: 18),
                                      )
                                    ],
                                  ))),
                          const Icon(
                            Icons.keyboard_double_arrow_right,
                            color: Colors.green,
                          ),
                          ElevatedButton(
                              onPressed: selectTime,
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(0),
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.green.shade50),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.black),
                              ),
                              child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  width: 120,
                                  child: Column(
                                    children: [
                                      const Text("结束时间"),
                                      Text(
                                        "${timeSwitch['end']}",
                                        style: const TextStyle(fontSize: 18),
                                      )
                                    ],
                                  ))),
                        ],
                      ),
                      const SizedBox(height: 5),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: booking["status"] != 0
                            ? Container()
                            : TabBar(
                                labelColor: Colors.black,
                                isScrollable: true,
                                tabs: showRoomId
                                    .map((e) => Tab(text: e["name"]))
                                    .toList()),
                      )
                    ],
                  )),
              body: Builder(builder: (BuildContext context) {
                var controller = DefaultTabController.of(context);
                controller?.addListener(() {
                  if (controller.index == controller.animation?.value) {
                    barIndex = controller.index;
                    checkboxChange(showRoomId);
                    // print(controller.index);
                  }
                });
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: booking["status"] != 0
                      ? Center(
                          child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LoadingAnimationWidget.staggeredDotsWave(
                              size: 60,
                              color: Colors.green.shade300,
                            ),
                            const SizedBox(height: 10),
                            Text("${booking["msg"]}")
                          ],
                        ))
                      : TabBarView(
                          children: showRoomId
                              .map((e) => CustomScrollView(
                                  slivers: e["room"]
                                      .map<Widget>((x) => SliverList(
                                              delegate:
                                                  SliverChildListDelegate([
                                            CCheckbox(
                                              order: x["checked"],
                                              title: "${x["name"]}",
                                              subtitle:
                                                  "${x['floor']} / 共${x['seats']}座位",
                                              value: (x["checked"] > 0),
                                              onChanged: (value) {
                                                x["checked"] = value ? 100 : 0;
                                                checkboxChange(showRoomId);
                                              },
                                            )
                                          ])))
                                      .toList()))
                              .toList()),
                );
              }),
              bottomNavigationBar: AnimatedSize(
                alignment: Alignment.bottomCenter,
                duration: const Duration(milliseconds: 300),
                child: booking["status"] != 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: bindBookButton,
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red),
                          ),
                          child: const Text(
                            "取消",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SwitchListTile(
                            value: timeSwitch["switch"],
                            onChanged: (value) {
                              if (value) {
                                setState(() {
                                  timeSwitch = {
                                    "switch": value,
                                    "start": "8:00",
                                    "end": "22:30"
                                  };
                                });
                              } else {
                                List tse = timeStartEnd();
                                setState(() {
                                  timeSwitch = {
                                    "switch": value,
                                    "start": tse[0],
                                    "end": tse[1]
                                  };
                                });
                              }
                            },
                            title: const Text("预约明日"),
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                        elevation: MaterialStateProperty.all(0),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.orange.shade50),
                                        foregroundColor:
                                            MaterialStateProperty.all(
                                                Colors.orange),
                                      ),
                                      onPressed: () {
                                        selectMore("window");
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.sensor_window),
                                          Text(
                                              "${windowpower['window'][moreSwitch['window']]}")
                                        ],
                                      ))),
                              const SizedBox(width: 10),
                              Expanded(
                                  flex: 1,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                        elevation: MaterialStateProperty.all(0),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.orange.shade50),
                                        foregroundColor:
                                            MaterialStateProperty.all(
                                                Colors.orange),
                                      ),
                                      onPressed: () {
                                        selectMore("power");
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.power),
                                          Text(
                                              "${windowpower['power'][moreSwitch['power']]}")
                                        ],
                                      ))),
                              const SizedBox(width: 10),
                              Expanded(
                                  flex: 1,
                                  child: ElevatedButton(
                                      style: ButtonStyle(
                                        elevation: MaterialStateProperty.all(0),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.orange.shade50),
                                        foregroundColor:
                                            MaterialStateProperty.all(
                                                Colors.orange),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          moreSwitch['round'] =
                                              !moreSwitch['round'];
                                        });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.table_bar),
                                          Text(
                                              "${moreSwitch['round'] ? '不限' : '非'}圆桌")
                                        ],
                                      ))),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.only(bottom: 10),
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (selectRooms.isNotEmpty &&
                                      timeSwitch["start"] != "无可用时间")
                                  ? bindBookButton
                                  : null,
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.white),
                                backgroundColor:
                                    MaterialStateProperty.resolveWith<Color>(
                                        (states) {
                                  if (states.contains(MaterialState.disabled)) {
                                    return Colors.green.shade100;
                                  }
                                  return Colors.green;
                                }),
                              ),
                              child: Text(
                                selectRooms.isNotEmpty
                                    ? '选座（已选择${selectRooms.length}个房间）'
                                    : '选择房间',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
              ))),
    );
  }

  void selectTime() {
    Map multiData;
    if (timeSwitch["switch"]) {
      multiData = timeRange("8:00", "22:30");
    } else {
      List tmp = timeStartEnd();
      multiData = timeRange(tmp[0], tmp[1]);
    }
    Pickers.showMultiLinkPicker(context,
        selectData: [timeSwitch["start"], timeSwitch["end"]],
        data: multiData,
        columeNum: 2,
        pickerStyle: DefaultPickerStyle(haveRadius: true),
        onConfirm: (timeList, _) {
      setState(() {
        timeSwitch = {
          "start": timeList[0],
          "end": timeList[1],
          "switch": timeSwitch["switch"]
        };
      });
    });
  }

  void checkboxChange(showRoomId) {
    List selectRoom = [];
    for (var r in showRoomId[barIndex]["room"]) {
      if (r["checked"] > 0) {
        selectRoom.add(r);
      }
    }
    selectRoom.sort((a, b) {
      return a["checked"] - b["checked"];
    });
    int checked = 1;
    for (var r in selectRoom) {
      r["checked"] = checked;
      showRoomId[barIndex]["room"][r["index"]]["checked"] = checked;
      checked++;
    }
    setState(() {
      selectRooms = selectRoom;
    });
  }

  List timeStartEnd() {
    var now = DateTime.now();
    num hour = now.hour;
    num minute = now.minute;
    double timeNum = hour + minute / 60;
    String startTime;
    String endTime = "22:30";
    if (timeNum < 8) {
      startTime = "8:00";
    } else if (timeNum >= 22) {
      startTime = "无可用时间";
      endTime = "无可用时间";
    } else if (minute < 30) {
      startTime = "$hour:30";
    } else {
      startTime = "${hour + 1}:00";
    }
    return [startTime, endTime];
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

  void bindBookButton() {
    if (booking["status"] == 0) {
      setState(() {
        booking = {"status": 1, "msg": "开始快速选座"};
      });
      List tmp = timeSwitch["start"].split(":");
      int timeStart = int.parse(tmp[0]) * 60 + int.parse(tmp[1]);
      tmp = timeSwitch["end"].split(":");
      int timeEnd = int.parse(tmp[0]) * 60 + int.parse(tmp[1]);
      DateTime today = DateTime.now();
      if (timeSwitch["switch"]) {
        today.add(const Duration(days: 1));
      }
      String date = "${today.year}-${today.month}-${today.day}";
      searchRoom(date, timeStart, timeEnd, 0);
    } else if (booking["status"] == 1) {
      setState(() {
        booking = {"status": 2, "msg": "取消中"};
      });
    }
  }

  void selectMore(String more) {
    Pickers.showSinglePicker(context,
        selectData: windowpower[more][moreSwitch[more]],
        data: windowpower[more],
        pickerStyle: DefaultPickerStyle(haveRadius: true),
        onConfirm: (_, switchList) {
      setState(() {
        moreSwitch[more] = switchList;
      });
    });
  }

  Future<void> searchRoom(String date, int start, int end, int index) async {
    if (booking["status"] == 2) {
      setState(() {
        booking = {"status": 0, "msg": ""};
      });
      return;
    }
    if (index >= selectRooms.length) {
      index = 0;
    }
    setState(() {
      booking = {
        "status": 1,
        "msg":
            "${index + 1}/${selectRooms.length}：${selectRooms[index]["name"]}"
      };
    });
    var resp = await w.get("freeBook/ajaxSearch", {
      "onDate": date,
      "startMin": "$start",
      "endMin": "$end",
      "room": "${selectRooms[index]["id"]}",
      "window": (moreSwitch["window"] == 2 ? null : '${moreSwitch["window"]}'),
      "power": (moreSwitch["power"] == 2 ? null : '${moreSwitch["power"]}')
    });
    String seatStr = json.decode(resp.body)["seatStr"];
    RegExp match = RegExp(r'<li([^]*?)</li>');
    var res = match.allMatches(seatStr);
    if (res.isEmpty) {
      await Future.delayed(const Duration(seconds: 1));
      await searchRoom(date, start, end, index + 1);
    } else {
      match = RegExp(r'seat_([^]*?)"');
      RegExp matchRound = RegExp(r'圆桌');
      for (var r in res) {
        if (!moreSwitch["round"] && matchRound.hasMatch(r.group(1) ?? "")) {
          continue;
        }
        var sid = match.firstMatch(r.group(1) ?? "");
        String id = sid?.group(1) ?? "";
        bool tmp = await bookSeat(date, start, end, id);
        if (tmp) {
          setState(() {
            booking = {"status": 1, "msg": "已约到座位！"};
          });
          Navigator.of(context).pop();
          onFresh();
          return;
        }
      }
    }
  }

  Future<bool> bookSeat(String date, int start, int end, String id) async {
    var resp = await w.get("self");
    RegExp match = RegExp(r'_TOKEN" value="([^]*?)"');
    var res = match.firstMatch(resp.body);
    String TOKEN = res?.group(1) ?? "";
    resp = await w.post("selfRes", {
      "SYNCHRONIZER_TOKEN": TOKEN,
      "SYNCHRONIZER_URI": "/self",
      "date": date,
      "start": "$start",
      "end": "$end",
      "seat": id
    });
    // print(resp.body);系统已经为您预定好了
    match = RegExp(r'系统已经为您预定好了');
    if (match.hasMatch(resp.body)) {
      return true;
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    showRoomId = widget.showRoomId;
    List tse = timeStartEnd();
    setState(() {
      timeSwitch = {"start": tse[0], "end": tse[1], "switch": false};
    });
    w = widget.w;
    onFresh = widget.onFresh;
  }
}
