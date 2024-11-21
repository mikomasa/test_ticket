class Notification {
  int userId; // ユーザーID (外部キー)
  int sourceUserId; // ソースユーザーID (外部キー)
  int notificationNumber; // 通知番号
  DateTime notificationDate; // 通知日時
  DateTime notificationOpenDate; // 通知が開かれた日時

  Notification({
    required this.userId,
    required this.sourceUserId,
    required this.notificationNumber,
    required this.notificationDate,
    required this.notificationOpenDate,
  });

  // マップからNotificationインスタンスを作成するファクトリーメソッド
  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      userId: map['USER_ID'],
      sourceUserId: map['SOURCE_USER_ID'],
      notificationNumber: map['NOTIFICATION_NUMBER'],
      notificationDate: DateTime.parse(map['NOTIFICATION_DATE']),
      notificationOpenDate: DateTime.parse(map['NOTIFICATION_OPEN_DATE']),
    );
  }

  // Notificationインスタンスをマップに変換
  Map<String, dynamic> toMap() {
    return {
      'USER_ID': userId,
      'SOURCE_USER_ID': sourceUserId,
      'NOTIFICATION_NUMBER': notificationNumber,
      'NOTIFICATION_DATE': notificationDate.toIso8601String(),
      'NOTIFICATION_OPEN_DATE': notificationOpenDate.toIso8601String(),
    };
  }
}
