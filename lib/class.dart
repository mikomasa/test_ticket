import 'package:postgres/postgres.dart';
 
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  late PostgreSQLConnection conn;
 
  // シングルトンインスタンスを返すファクトリコンストラクタ
  factory DatabaseHelper() {
    return _instance;
  }
 
  // プライベートコンストラクタ
  DatabaseHelper._internal() {
    _initializeConnection();
  }
 
  // PostgreSQLデータベースの初期化メソッド
  Future<void> _initializeConnection() async {
    conn = PostgreSQLConnection(
      host:'34.133.185.219', // ホスト名
      database:'ticket',         // データベース名
      username: 'postgres', // ユーザー名
      password: 'testticket', // パスワード
    );
    await conn.open(); // 接続の確立
  }
 
  // FRIENDテーブルにデータを挿入するメソッド
  Future<void> insertFriend({
    required int friendId,
    required int userId,
    required int friendUserId,
    String? requestType, // リクエストのタイプ（'send', 'approve', 'reject'）
  }) async {
    final currentDate = DateTime.now();
    final defaultDate = DateTime(2000, 1, 1);
 
    DateTime requestSendDate = defaultDate;
    DateTime requestApprovalDate = defaultDate;
    DateTime requestRejectionDate = defaultDate;
    DateTime brockDate = defaultDate;
 
    if (requestType == 'send') {
      requestSendDate = currentDate;
    } else if (requestType == 'approve') {
      requestApprovalDate = currentDate;
    } else if (requestType == 'reject') {
      requestRejectionDate = currentDate;
    }
 
    await conn.query(
      '''
      INSERT INTO FRIEND (
        FRIEND_ID, USER_ID, FRIENDUSER_ID, REQUEST_SEND, REQUEST_APPROVAL, REQUEST_REJECTION, BROCK_DATE
      ) VALUES (@friendId, @userId, @friendUserId, @requestSendDate, @requestApprovalDate, @requestRejectionDate, @brockDate)
      ON CONFLICT (FRIEND_ID) DO UPDATE
      SET USER_ID = @userId, FRIENDUSER_ID = @friendUserId, REQUEST_SEND = @requestSendDate,
          REQUEST_APPROVAL = @requestApprovalDate, REQUEST_REJECTION = @requestRejectionDate, BROCK_DATE = @brockDate
      ''',
      substitutionValues: {
        'friendId': friendId,
        'userId': userId,
        'friendUserId': friendUserId,
        'requestSendDate': requestSendDate.toIso8601String(),
        'requestApprovalDate': requestApprovalDate.toIso8601String(),
        'requestRejectionDate': requestRejectionDate.toIso8601String(),
        'brockDate': brockDate.toIso8601String(),
      },
    );
  }
 
  // EVENTテーブルにデータを挿入するメソッド
  Future<void> insertEvent({
    required int userId,
    required String eventName,
    required String eventText,
    required String eventPlace,
    required int eventStatus,
    bool saleFlag = false,
    String? sponsoreName,
    String? artistName,
  }) async {
    final currentDate = DateTime.now();
 
    await conn.query(
      '''
      INSERT INTO EVENT (
        USER_ID, EVENT_NAME, SPONSORE_NAME, EVENT_TEXT, EVENT_DATE, EVENT_PRACE, SALE_FLAG, EVENT_STATUS, ARTIST_NAME
      ) VALUES (@userId, @eventName, @sponsoreName, @eventText, @currentDate, @eventPlace, @saleFlag, @eventStatus, @artistName)
      ON CONFLICT (EVENT_ID) DO UPDATE
      SET USER_ID = @userId, EVENT_NAME = @eventName, SPONSORE_NAME = @sponsoreName, EVENT_TEXT = @eventText,
          EVENT_DATE = @currentDate, EVENT_PRACE = @eventPlace, SALE_FLAG = @saleFlag, EVENT_STATUS = @eventStatus,
          ARTIST_NAME = @artistName
      ''',
      substitutionValues: {
        'userId': userId,
        'eventName': eventName,
        'sponsoreName': sponsoreName ?? '',
        'eventText': eventText,
        'currentDate': currentDate.toIso8601String(),
        'eventPlace': eventPlace,
        'saleFlag': saleFlag ? 1 : 0,
        'eventStatus': eventStatus,
        'artistName': artistName ?? '',
      },
    );
  }
 
  // NOTIFICATIONテーブルにデータを挿入するメソッド
  Future<void> insertNotification({
    required int userId,
    required int sourceUserId,
    required int notificationNumber,
    required DateTime notificationDate,
    required DateTime notificationOpenDate,
  }) async {
    await conn.query(
      '''
      INSERT INTO NOTIFICATION (
        USER_ID, SOURCE_USER_ID, NOTIFICATION_NUMBER, NOTIFICATION_DATE, NOTIFICATION_OPEN_DATE
      ) VALUES (@userId, @sourceUserId, @notificationNumber, @notificationDate, @notificationOpenDate)
      ON CONFLICT (USER_ID, SOURCE_USER_ID) DO UPDATE
      SET NOTIFICATION_NUMBER = @notificationNumber, NOTIFICATION_DATE = @notificationDate, NOTIFICATION_OPEN_DATE = @notificationOpenDate
      ''',
      substitutionValues: {
        'userId': userId,
        'sourceUserId': sourceUserId,
        'notificationNumber': notificationNumber,
        'notificationDate': notificationDate.toIso8601String(),
        'notificationOpenDate': notificationOpenDate.toIso8601String(),
      },
    );
  }
}