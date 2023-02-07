import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/default_style.dart';
import "./utils/web.dart";

class timeChange extends StatefulWidget {
  const timeChange({
    super.key,
    required this.preStart,
    required this.preEnd,
    required this.w,
    required this.cancel,
    required this.seatId,
    required this.date,
    required this.onFresh,
  });

  final String preStart;
  final String preEnd;
  final cWeb w;
  final Function cancel;
  final String seatId;
  final String date;
  final Function onFresh;

  @override
  State<timeChange> createState() => _timeChangebody();
}

class _timeChangebody extends State<timeChange> {
  late final cWeb w;
  late final String preStart;
  late final String preEnd;
  late final Function cancel;
  late final String seatId;
  late final String date;
  late final Function onFresh;
  Map timeSwitch = {"start": "", "end": ""};

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
    List tmp1 = date.split("年");
    List tmp2 = tmp1[1].split("月");
    List tmp3 = tmp2[1].split("日");
    String dates = "${tmp1[0]}-${tmp2[0]}-${tmp3[0]}";
    List tmp = timeSwitch["start"].split(":");
    int timeStart = int.parse(tmp[0]) * 60 + int.parse(tmp[1]);
    tmp = timeSwitch["end"].split(":");
    int timeEnd = int.parse(tmp[0]) * 60 + int.parse(tmp[1]);
    await showDialog(
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
                      foregroundColor: MaterialStateProperty.all(Colors.grey)),
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
                    await bookSeat(dates, timeStart, timeEnd);
                    await onFresh();
                  },
                  child: const Text("确定变更"))
            ],
          );
        });
  }

  Future<bool> bookSeat(String date, int start, int end) async {
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
      EasyLoading.showSuccess('变更成功');
      EasyLoading.dismiss();
      return true;
    }
    EasyLoading.showError('变更失败');
    EasyLoading.dismiss();
    return false;
  }

  void selectTime() {
    Map multiData;
    List tmp = timeStartEnd();
    multiData = timeRange(tmp[0], tmp[1]);
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

  List timeStartEnd() {
    var now = DateTime.now();
    int nowStamp = now.hour * 60 + now.minute;
    List tmp = preStart.split(":");
    int preStartStamp = int.parse(tmp[0]) * 60 + int.parse(tmp[1]);
    int startStamp = (nowStamp < preStartStamp ? preStartStamp : nowStamp);
    int hour = startStamp ~/ 60;
    int minute = startStamp % 60;
    tmp = preEnd.split(":");
    int preEndStamp = int.parse(tmp[0]) * 60 + int.parse(tmp[1]);
    preEndStamp = preEndStamp - preEndStamp % 30;
    String endTime =
        "${preEndStamp ~/ 60}:${preEndStamp % 60 == 0 ? '00' : '30'}";

    double timeNum = hour + minute / 60;
    String startTime;
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
    if (startTime == endTime) {
      return ["无可用时间", "无可用时间"];
    } else {
      return [startTime, endTime];
    }
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

  @override
  void initState() {
    super.initState();
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.cubeGrid;
    EasyLoading.instance.maskType = EasyLoadingMaskType.clear;
    w = widget.w;
    preStart = widget.preStart;
    preEnd = widget.preEnd;
    List tse = timeStartEnd();
    setState(() {
      timeSwitch = {"start": tse[0], "end": tse[1]};
    });
    cancel = widget.cancel;
    seatId = widget.seatId;
    date = widget.date;
    onFresh = widget.onFresh;
  }
}
