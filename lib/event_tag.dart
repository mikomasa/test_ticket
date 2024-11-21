class EventTag {
  int eventId; // イベントID (PRIMARY KEYの一部)
  int tagId; // タグID (PRIMARY KEYの一部)
  DateTime eventTagDate; // 関連付けが行われた日時

  EventTag({
    required this.eventId,
    required this.tagId,
    required this.eventTagDate,
  });

  // マップからEventTagインスタンスを作成するファクトリーメソッド
  factory EventTag.fromMap(Map<String, dynamic> map) {
    return EventTag(
      eventId: map['EVENT_ID'],
      tagId: map['TAG_ID'],
      eventTagDate: DateTime.parse(map['EVENT_TAG_DATE']),
    );
  }

  // EventTagインスタンスをマップに変換
  Map<String, dynamic> toMap() {
    return {
      'EVENT_ID': eventId,
      'TAG_ID': tagId,
      'EVENT_TAG_DATE': eventTagDate.toIso8601String(),
    };
  }
}
