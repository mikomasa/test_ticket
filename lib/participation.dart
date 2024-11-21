class Participation {
  int userId;
  int companionId;
  DateTime participationDate;
  bool participationFlag;

  Participation({
    required this.userId,
    required this.companionId,
    required this.participationDate,
    required this.participationFlag,
  });

  // マップからParticipationインスタンスを作成
  factory Participation.fromMap(Map<String, dynamic> map) {
    return Participation(
      userId: map['USER_ID'],
      companionId: map['COMPANION_ID'],
      participationDate: map['PARTICIPATION_DATE'],
      participationFlag: map['PARTICIPATION_FLAG'],
    );
  }

  // Participationインスタンスをマップに変換
  Map<String, dynamic> toMap() {
    return {
      'USER_ID': userId,
      'COMPANION_ID': companionId,
      'PARTICIPATION_DATE': participationDate,
      'PARTICIPATION_FLAG': participationFlag,
    };
  }
}
