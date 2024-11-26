import 'package:flutter/material.dart';
import 'companion_search.dart';

void main() => runApp(EventApp());

class EventApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CompanionSearchApp(), //最初に登録画面を表示
    );
  }
}
