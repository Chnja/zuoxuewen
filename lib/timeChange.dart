import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/default_style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import "./utils/web.dart";

class timeChange extends StatefulWidget {
  const timeChange({
    super.key,
    required this.cancel,
    required this.onFresh,
    required this.bookStatus,
  });

  final Function cancel;
  final Function onFresh;
  final Map bookStatus;

  @override
  State<timeChange> createState() => _timeChangebody();
}

class _timeChangebody extends State<timeChange> {
  CWeb w = CWeb();
  late final Function cancel;
  late final Function onFresh;
  late final Map bookStatus;

  Map timeSwitch = {"start": "", "end": ""};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
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
                    backgroundColor:
                        MaterialStateProperty.all(Colors.orange.shade50),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
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
                color: Colors.orange,
              ),
              ElevatedButton(
                  onPressed: selectTime,
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(0),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.orange.shade50),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                  ),
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
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
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: timeSwitch["start"] == "无可用时间" ? null : bindchange,
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(Colors.white),
                backgroundColor:
                    MaterialStateProperty.resolveWith<Color>((states) {
                  if (states.contains(MaterialState.disabled)) {
                    return Colors.orange.shade100;
                  }
                  return Colors.orange;
                }),
              ),
              child: const Text(
                '变更时间',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> bindchange() async {
    String dates = bookStatus["date"]
        .replaceFirst(RegExp(r'年'), "-")
        .replaceFirst(RegExp(r'月'), "-")
        .replaceFirst(RegExp(r'日'), "");
    List tmp = timeSwitch["start"].split(":");
    int timeStart = int.parse(tmp[0]) * 60 + int.parse(tmp[1]);
    tmp = timeSwitch["end"].split(":");
    int timeEnd = int.parse(tmp[0]) * 60 + int.parse(tmp[1]);

    final prefs = await SharedPreferences.getInstance();
    String? tmp2 = prefs.getString("libList");
    String seatId = "";
    if (tmp2 != null) {
      Map tmpj = json.decode(tmp2);
      List libList = tmpj["libList"];
      for (Map building in libList) {
        for (Map floor in building["floor"]) {
          if (bookStatus["loc"].startsWith(floor["name"])) {
            for (Map room in floor["room"]) {
              if (bookStatus["loc"].endsWith(room["name"])) {
                for (Map seat in room["seat"]) {
                  if (bookStatus["num"] == seat["name"]) {
                    seatId = seat["id"];
                    break;
                  }
                }
                break;
              }
            }
            break;
          }
        }
      }
    } else {
      EasyLoading.showInfo('变更时间需本地数据支持，\n请更新本地数据！',
          duration: const Duration(seconds: 2));
    }
    if (seatId == "") {
      EasyLoading.showInfo('本地数据中未找到该座位，\n无法自动变更，\n请更新本地数据！',
          duration: const Duration(seconds: 2));
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: const Text("变更时间有丢失座位风险，确认继续吗?"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ButtonStyle(
                        overlayColor:
                            MaterialStateProperty.all(Colors.grey.shade50),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.grey)),
                    child: const Text("点错了")),
                TextButton(
                    style: ButtonStyle(
                        overlayColor:
                            MaterialStateProperty.all(Colors.orange.shade50),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.orange)),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await cancel();
                      await bookSeat(dates, timeStart, timeEnd, seatId);
                      await onFresh();
                    },
                    child: const Text("确定变更"))
              ],
            );
          });
    }
  }

  Future<bool> bookSeat(String date, int start, int end, String seatId) async {
    Navigator.of(context).pop();
    EasyLoading.show(status: '选座中...');
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
      "seat": seatId
    });
    match = RegExp(r'系统已经为您预定好了');
    if (match.hasMatch(resp.body)) {
      EasyLoading.showSuccess('变更成功', duration: const Duration(seconds: 1));
      return true;
    }
    EasyLoading.showError('变更失败', duration: const Duration(seconds: 1));
    return false;
  }

  void selectTime() {
    Map multiData;
    RegExp match = RegExp(r'月([^]*?)日');
    var matchres = match.firstMatch(bookStatus["date"]);
    if (int.parse(matchres?.group(1) ?? "") != DateTime.now().day) {
      multiData = timeRange(bookStatus["start"], bookStatus["end"]);
    } else {
      List tmp = timeStartEnd(bookStatus["start"], bookStatus["end"]);
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
        };
      });
    });
  }

  @override
  void initState() {
    super.initState();
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.cubeGrid;
    EasyLoading.instance.maskType = EasyLoadingMaskType.clear;
    bookStatus = widget.bookStatus;
    List tse = timeStartEnd(bookStatus["start"], bookStatus["end"]);
    setState(() {
      timeSwitch = {"start": tse[0], "end": tse[1]};
    });
    cancel = widget.cancel;
    onFresh = widget.onFresh;
  }
}
