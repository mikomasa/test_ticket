// import 'class.dart'; // class.dartのインポート

// void main() async {
//   final conn = await DatabaseHelper.connect(); // DB接続

//   // 必要な操作を呼び出し
//   // await DatabaseHelper.insertFriend(
//   //   conn: conn,
//   //   friendId: 1,
//   //   userId: 1,
//   //   friendUserId: 2,
//   //   requestType: 'send',
//   // );

//   await DatabaseHelper.insertEvent(
//     conn: conn,
//     userId: 2,
//     eventName: 'ばか',
//     unitName: 'ばか',
//     eventText: 'ばか',
//     eventPlace: 'ばか',
//     eventStatus: 1,
//   );

//   await DatabaseHelper.insertParticipation(
//     conn: conn,
//     userId: 2,
//     companionId: 1,
//     requestType: '募集者',
//   );

//   // 接続を閉じる
//   await conn.close();
//   print("正常に終了しました。");
// }
