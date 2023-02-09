import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.fromLTRB(30, 60, 30, 40),
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Color(0x30012654),
                    offset: Offset(0, 0),
                    blurRadius: 20,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Image.asset("images/icon1.png"),
            ),
            const SizedBox(height: 30),
            RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                    style:
                        const TextStyle(color: Colors.black, letterSpacing: -1),
                    children: [
                      TextSpan(
                          text: add2006("　　座学问"),
                          style: const TextStyle(
                              color: Color(0xFF012654),
                              fontWeight: FontWeight.w900)),
                      TextSpan(text: add2006(" 是一个面向武汉大学学生的图书馆预约APP，其源自")),
                      TextSpan(
                          text: add2006("微信小程序·EI青年"),
                          style: const TextStyle(
                              color: Color(0xFF012654),
                              fontWeight: FontWeight.w900)),
                      TextSpan(
                          text: add2006(
                              "。小程序起步于2018年4月7日，获得了当年高校计算机大赛·微信小程序应用开发赛华中区一等奖，随后上线图书馆预约座位功能；2018年10月17日2.0.0版本大更；10月22日发布2.1.0版本图书馆预约座位功能回归，增加了第一版“快速选座”功能；10月30日发布2.1.3版本增加“常规选座”和“预约选座”功能；随后图书馆开始针对第三方程序的访问进行限制，对请求头中包含微信标识的一律拒绝；12月10日发布2.2.0版本，使用云端服务器转发请求并过滤微信标识，这总归也不是一个长久之计，很快云端服务器IP被封禁。微信小程序的故事到这里就告一段落了。")),
                    ])),
            Text(
                add2006(
                    "　　2019年10月，开始编写图书馆选座功能的独立APP，最开始选择的技术路线是Electron+Vue，感觉调试还是挺烦的，加上那段时间事情很多、图书馆选座Web也逐步后端渲染，整个项目就不了了之。"),
                textAlign: TextAlign.justify,
                style: const TextStyle(letterSpacing: -1)),
            Text(
                add2006(
                    "　　2023年1月25日凌晨1点，本项目使用Flutter重启...纪念一下，我不但来过，而且走下去了。多说一句，本APP仅与图书馆做交互，不需要后台服务器，也没有账号系统，同时代码全部开源。放心，你的数据很安全。"),
                textAlign: TextAlign.justify,
                style: const TextStyle(letterSpacing: -1)),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Chnja ❤️ Lrui from WHU",
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 5,
            ),
            InkWell(
                child: const Text('<访问Github>'),
                onTap: () => launchUrl(
                    Uri.parse('https://github.com/Chnja/zuoxuewen'),
                    mode: LaunchMode.externalApplication)),
            section(
                "亮点",
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    highlight("取消预约", "整合“取消预约”和“结束使用”两个类似的功能；"),
                    highlight("快速选座", "在指定的多个房间内快速选座；"),
                    highlight("变更时间", "修改当前已预约座位的时间。")
                  ],
                )),
            section(
                "Acknowledgement",
                const Text(
                  "Flutter\nAndroid Studio",
                  textAlign: TextAlign.center,
                ))
          ],
        ),
      ),
    ));
  }

  String add2006(String i) {
    return Characters(i).join('\u{2006}');
  }

  Widget section(String title, Widget child) {
    return Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        RichText(
          text: TextSpan(
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              children: [
                const TextSpan(text: "< "),
                TextSpan(
                    text: title, style: const TextStyle(color: Colors.black)),
                const TextSpan(text: " >")
              ]),
        ),
        const SizedBox(
          height: 8,
        ),
        child
      ],
    );
  }

  Widget highlight(String light, String des) {
    return RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
            style: const TextStyle(color: Colors.black, letterSpacing: -1),
            children: [
              TextSpan(
                  text: add2006("　　$light "),
                  style: const TextStyle(
                      color: Color(0xFF012654), fontWeight: FontWeight.bold)),
              TextSpan(text: add2006(des)),
            ]));
  }
}
