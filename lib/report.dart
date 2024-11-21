class Report {
  int? reportId; // PRIMARY KEY, nullの可能性あり（新規作成時に自動採番されるため）
  int userId; // FOREIGN KEY: "USER".USER_ID
  int eventId; // FOREIGN KEY: EVENT.EVENT_ID
  String reportImageUrl; // レポート画像URL
  String reportText; // レポート本文

  Report({
    this.reportId,
    required this.userId,
    required this.eventId,
    this.reportImageUrl = '',
    required this.reportText,
  });

  // マップからReportインスタンスを作成するファクトリーメソッド
  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      reportId: map['REPORT_ID'],
      userId: map['USER_ID'],
      eventId: map['EVENT_ID'],
      reportImageUrl: map['REPORT_IMAGE_URL'] ?? '',
      reportText: map['REPORT_TEXT'],
    );
  }

  // Reportインスタンスをマップに変換
  Map<String, dynamic> toMap() {
    return {
      'REPORT_ID': reportId,
      'USER_ID': userId,
      'EVENT_ID': eventId,
      'REPORT_IMAGE_URL': reportImageUrl,
      'REPORT_TEXT': reportText,
    };
  }
}
