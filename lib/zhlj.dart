// import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
//
// class zhljLogin extends StatelessWidget {
//   const zhljLogin({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: '座学问',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: Scaffold(
//         body: zhljbody(),
//       ),
//     );
//   }
// }
//
// class zhljbody extends StatefulWidget {
//   const zhljbody({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<zhljbody> createState() => _zhljbody();
// }
//
// class _zhljbody extends State<zhljbody> {
//   @override
//   Widget build(BuildContext context) {
//     return InAppWebView(
//       initialUrlRequest: URLRequest(
//         url: Uri.parse(
//             "https://ehall.whu.edu.cn/new/index.html#/"),
//       ),
//       onLoadStop: (control, uri) {
//         print(uri);
//       },
//     );
//   }
// }
