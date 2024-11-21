class Friend {
  int? friendId; // 自動生成されるPRIMARY KEY
  int userId; // ユーザーID (外部キー)
  int friendUserId; // 友達のユーザーID (外部キー)
  DateTime requestSend; // リクエスト送信日時
  DateTime requestApproval; // リクエスト承認日時
  DateTime requestRejection; // リクエスト拒否日時
  DateTime brockDate; // ブロック日時

  Friend({
    this.friendId,
    required this.userId,
    required this.friendUserId,
    required this.requestSend,
    required this.requestApproval,
    required this.requestRejection,
    required this.brockDate,
  });

  // マップからFriendインスタンスを作成するファクトリーメソッド
  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      friendId: map['FRIEND_ID'],
      userId: map['USER_ID'],
      friendUserId: map['FRIEND_USER_ID'],
      requestSend: DateTime.parse(map['REQUEST_SEND']),
      requestApproval: DateTime.parse(map['REQUEST_APPROVAL']),
      requestRejection: DateTime.parse(map['REQUEST_REJECTION']),
      brockDate: DateTime.parse(map['BROCK_DATE']),
    );
  }

  // Friendインスタンスをマップに変換
  Map<String, dynamic> toMap() {
    return {
      'FRIEND_ID': friendId,
      'USER_ID': userId,
      'FRIEND_USER_ID': friendUserId,
      'REQUEST_SEND': requestSend.toIso8601String(),
      'REQUEST_APPROVAL': requestApproval.toIso8601String(),
      'REQUEST_REJECTION': requestRejection.toIso8601String(),
      'BROCK_DATE': brockDate.toIso8601String(),
    };
  }
}
