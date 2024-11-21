class Message {
  int? messageId; // PRIMARY KEY, nullの可能性あり（新規作成時に自動採番されるため）
  int userId; // FOREIGN KEY: "USER".USER_ID
  int companionId; // FOREIGN KEY: COMPANION.COMPANION_ID
  String messageText; // メッセージ本文
  DateTime messageDate; // メッセージ送信日

  Message({
    this.messageId,
    required this.userId,
    required this.companionId,
    required this.messageText,
    required this.messageDate,
  });

  // マップからMessageインスタンスを作成するファクトリーメソッド
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      messageId: map['MESSAGE_ID'],
      userId: map['USER_ID'],
      companionId: map['COMPANION_ID'],
      messageText: map['MESSAGE_TEXT'],
      messageDate: DateTime.parse(map['MESSAGE_DATE']),
    );
  }

  // Messageインスタンスをマップに変換
  Map<String, dynamic> toMap() {
    return {
      'MESSAGE_ID': messageId,
      'USER_ID': userId,
      'COMPANION_ID': companionId,
      'MESSAGE_TEXT': messageText,
      'MESSAGE_DATE': messageDate.toIso8601String(),
    };
  }
}
