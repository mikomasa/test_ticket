import 'package:postgres/postgres.dart';
import 'message.dart'; // Messageクラスを定義したファイル

class MessageDAO {
  final PostgreSQLConnection conn;

  MessageDAO(this.conn);

  /// メッセージを挿入する
  Future<void> insertMessage(Message message) async {
    await conn.query('''
      INSERT INTO message (
        USER_ID,
        COMPANION_ID,
        MESSAGE_TEXT,
        MESSAGE_DATE
      ) VALUES (
        @userId,
        @companionId,
        @messageText,
        @messageDate
      )
    ''', substitutionValues: {
      'userId': message.userId,
      'companionId': message.companionId,
      'messageText': message.messageText,
      'messageDate': message.messageDate,
    });

    print("Message inserted successfully.");
  }

  /// 募集ID (COMPANION_ID) でメッセージを全件取得
  Future<List<Message>> getMessagesByCompanionId(int companionId) async {
    final results = await conn.query('''
      SELECT MESSAGE_ID, USER_ID, COMPANION_ID, MESSAGE_TEXT, MESSAGE_DATE
      FROM message
      WHERE COMPANION_ID = @companionId
      ORDER BY MESSAGE_DATE ASC
    ''', substitutionValues: {
      'companionId': companionId,
    });

    return results.map((row) {
      return Message.fromMap({
        'MESSAGE_ID': row[0],
        'USER_ID': row[1],
        'COMPANION_ID': row[2],
        'MESSAGE_TEXT': row[3],
        'MESSAGE_DATE': row[4],
      });
    }).toList();
  }
}
