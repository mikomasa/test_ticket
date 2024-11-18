import 'package:postgres/postgres.dart';

class DatabaseHelper {
  static final String host = '34.133.185.219';
  static final int port = 5432;
  static final String databaseName = 'ticket';
  static final String username = 'postgres';
  static final String password = 'testticket';

  // PostgreSQLの接続設定
  static Future<PostgreSQLConnection> connect() async {
    final conn = PostgreSQLConnection(
      host, 
      port, 
      databaseName, 
      username: username, 
      password: password,
    );
    
    // データベースへの接続を開く
    await conn.open();
    print("Connection established successfully!");
    return conn;
  }

  // FRIENDテーブルにデータを挿入するメソッド(フレンド申請、承認、拒否、ブロック)
  static Future<void> insertFriend({
    required PostgreSQLConnection conn,
    required int friendId,
    required int userId,
    required int friendUserId,
    String? requestType, // リクエストタイプ ('send', 'approve', 'reject')
  }) async {
    // 現在の日付を取得
    final currentDate = DateTime.now();
    // デフォルトの日付を設定（2000年1月1日）
    final defaultDate = DateTime(2000, 1, 1);

    // リクエスト送信日、承認日、拒否日をデフォルト値で初期化
    DateTime requestSendDate = defaultDate;
    DateTime requestApprovalDate = defaultDate;
    DateTime requestRejectionDate = defaultDate;
    DateTime brockDate = defaultDate; // ブロック日もデフォルト値

    // 送られてきたリクエストタイプに応じて、日付を変更
    if (requestType == 'send') {
      requestSendDate = currentDate;
    } else if (requestType == 'approve') {
      requestApprovalDate = currentDate;
    } else if (requestType == 'reject') {
      requestRejectionDate = currentDate;
    }

    // SQL文の挿入処理
    await conn.query('''
      INSERT INTO FRIEND (
        FRIEND_ID,
        USER_ID,
        FRIENDUSER_ID,
        REQUEST_SEND,
        REQUEST_APPROVAL,
        REQUEST_REJECTION,
        BROCK_DATE
      ) VALUES (
        @friendId,
        @userId,
        @friendUserId,
        @requestSendDate,
        @requestApprovalDate,
        @requestRejectionDate,
        @brockDate
      )
    ''', substitutionValues: {
      'friendId': friendId,
      'userId': userId,
      'friendUserId': friendUserId,
      'requestSendDate': requestSendDate,
      'requestApprovalDate': requestApprovalDate,
      'requestRejectionDate': requestRejectionDate,
      'brockDate': brockDate,
    });

    print("Data inserted into FRIEND table successfully.");
  }

  // イベントテーブルにデータを挿入するメソッド(チケット販売、レポート作成、同行者募集)
  static Future<void> insertEvent({
    required PostgreSQLConnection conn,
    required int userId,
    required String eventName,
    required String unitName,
    required String eventText,
    required String eventPlace,
    required int eventStatus,
    String? requestType, // 「販売」か「」か
  }) async {
    // 参加日時を現在日時で初期化
    DateTime eventDate = DateTime.now();

    // 募集者フラグを設定
    bool saleFlag = requestType == "販売";

    // SQL文の挿入処理
    await conn.query('''
    INSERT INTO EVENT (
      USER_ID,
      EVENT_NAME,
      UNIT_NAME,
      EVENT_TEXT,
      EVENT_PLACE,
      EVENT_DATE,
      SALE_FLAG
    ) VALUES (
      @userId,
      @eventName,
      @unitName,
      @eventText,
      @eventPlace,
      @eventDate,
      @saleFlag
    )
    ''', substitutionValues: {
      'userId': userId,
      'eventName': eventName,
      'unitName': unitName,
      'eventText': eventText,
      'eventPlace': eventPlace,
      'eventDate': eventDate,
      'saleFlag': saleFlag,
    });

    print("Data inserted into EVENT table successfully.");
  }

  // 募集参加テーブルにデータを挿入するメソッド(同行者募集、同行者申請)
  static Future<void> insertParticipation({
    required PostgreSQLConnection conn,
    required int userId,
    required int companionId,
    String? requestType, // 募集者か参加者か
  }) async {
    // 参加日時を現在日時で初期化
    DateTime participationDate = DateTime.now();

    // 募集者フラグを設定
    bool participationFlag = requestType == "募集者";

    // SQL文の挿入処理
    await conn.query('''
      INSERT INTO PARTICIPATION (
        USER_ID,
        COMPANION_ID,
        PARTICIPATION_DATE,
        PARTICIPATION_FLAG
      ) VALUES (
        @userId,
        @companionId,
        @participationDate,
        @participationFlag
      )
    ''', substitutionValues: {
      'userId': userId,
      'companionId': companionId,
      'participationDate': participationDate,
      'participationFlag': participationFlag,
    });

    print("Data inserted into PARTICIPATION table successfully.");
  }
}
