import 'database_helper.dart'; // `database_helper.dart`のパスを正確に
import 'event_dao.dart'; // 同上
import 'event.dart'; // 同上

Future<void> main() async {
  // 1. データベース接続
  final connection = await DatabaseHelper.connect();
  final eventDAO = EventDAO(connection);

  // 2. テスト用データの作成
  final testEvent = Event(
    userId: 1,
    eventName: "テストイベント",
    unitName: "テストアーティスト",
    eventText: "テスト主催者",
    eventDate: DateTime.now(),
    eventPlace: "東京",
  );

  // 3. データ挿入のテスト
  try {
    await eventDAO.insertEvent(testEvent);
    print("データ挿入完了: ${testEvent.eventName}");
  } catch (e) {
    print("データ挿入エラー: $e");
  }
}
