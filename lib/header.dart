import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;

  final String title; // タイトルを受け取る変数

  AppHeader({Key? key, required this.title}) // コンストラクタでtitleを受け取る
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title), // 渡されたtitleを表示
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {
            // 通知ボタンが押された時の処理
          },
        ),
        const CircleAvatar(
          backgroundImage: NetworkImage(
            'https://haratetsuo.com/wp/wp-content/uploads/2023/02/bonoron.jpg', // ユーザーアイコンのURL
          ),
        ),
        const SizedBox(width: 16), // アイコン間のスペース
      ],
    );
  }
}
