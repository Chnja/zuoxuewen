# zuoxuewen

![author](https://img.shields.io/badge/Author-Chnja-blue.svg)
![Frame](https://img.shields.io/badge/Frame-Flutter-important.svg)
![license](https://img.shields.io/badge/License-GPLv3-brightgreen.svg)

一个面向武汉大学图书馆预约座位的程序，基于Flutter编写。

## 开始

如果你只是使用，并不进行二次开发，可以直接下载安装[Releases](https://github.com/Chnja/zuoxuewen/releases)中的```.apk```安装包。

### 二次开发

```shell
# 1. First, clone the repo, and start this project!
$ git clone https://github.com/Chnja/zuoxuewen.git
$ cd zuoxuewen

# 2. Run!
$ flutter pub get
$ flutter run

# 3. Write your code!

# 4. Build!
$ flutter build apk
```

## 项目结构

本项目中的绝大部分内容都位于```/lib```路径下

```shell
lib
│  about.dart # 页面：关于页("/about")
│  libin.dart # 页面：项目主页（"/libin"）
│  main.dart # 页面：登录页（"/login")
│  roomSelect.dart # 组件：“快速选座”功能中底部弹框
│  timeChange.dart # 组件：“变更时间”功能中底部弹框
│  zhlj.dart # 暂时未使用，为测试内建WebView时遗留
│
└─utils
        CCheckboxList.dart # 组件：类似于CheckboxListTile
        web.dart # 工具包：http请求类CWeb、自建页面栈Routes、部分共用函数等
```

## 目前实现的功能

* 取消预约：整合图书馆目前“取消预约”和“结束使用”两个类似的功能
* 快速选座：在指定的多个房间内快速选座（轮询）
* 变更时间：修改当前已预约座位的时间（先取消后重新预约）

## 写在最后

特定时间的预约抢座功能没有做也不会做，我觉得那是红线。其实快速选座和变更时间功能，在我读本科的时候，图书馆承诺后面会加上，后面就没有下文了

本项目主要是想解决图书馆座位预约中的痛点问题：

* 网页端：
  * 没有针对手机端做优化，使用体验不佳；
  * 通过“自选座位”选座，需要重复选择两次座位使用时间；
* 微信公众号端：
  * 没有按照时间进行筛选的功能
* 没有指定多的房间的快速选座
* 无法变更使用时间

其实不论通过哪种方案，爬虫访问图书馆网页终究不是长久之计。我有一个想法！要是图书馆能够开放API接口，开发者们通过SecretID和SecretKey进行身份认证获取接入权限，那该多好啊

## Acknowledgement

* [Flutter](https://flutter.cn/)
* [Android Studio](https://developer.android.google.cn/studio)
* [http](https://pub.dev/packages/http)
* [fluttertoast](https://pub.dev/packages/fluttertoast)
* [loading_animation_widget](https://pub.dev/packages/loading_animation_widget)
* [flutter_easyloading](https://pub.dev/packages/flutter_easyloading)
* [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview)
* [shared_preferences](https://pub.dev/packages/shared_preferences)
* [flutter_pickers](https://pub.dev/packages/flutter_pickers)
* [url_launcher](https://pub.dev/packages/url_launcher)

## Contact

chj1997@whu.edu.cn