class Tag {
  int? tagId; // PRIMARY KEY, nullの可能性あり（新規作成時に自動採番されるため）
  String tagName; // タグ名
  DateTime tagDate; // タグ作成日

  Tag({
    this.tagId,
    required this.tagName,
    required this.tagDate,
  });

  // マップからTagインスタンスを作成するファクトリーメソッド
  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      tagId: map['TAG_ID'],
      tagName: map['TAG_NAME'],
      tagDate: DateTime.parse(map['TAG_DATE']),
    );
  }

  // Tagインスタンスをマップに変換
  Map<String, dynamic> toMap() {
    return {
      'TAG_ID': tagId,
      'TAG_NAME': tagName,
      'TAG_DATE': tagDate.toIso8601String(),
    };
  }
}
