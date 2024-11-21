// event.dart

class Event {
  int? eventId;
  int userId;
  String eventName;
  String unitName;
  String eventText;
  DateTime eventDate;
  String eventPlace;
  bool saleFlag;
  int eventStatus;

  Event({
    this.eventId,
    required this.userId,
    required this.eventName,
    required this.unitName,
    required this.eventText,
    required this.eventDate,
    required this.eventPlace,
    this.saleFlag = false,
    this.eventStatus = 1,
  });

  // マップからEventインスタンスを作成するファクトリーメソッド
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      eventId: map['EVENT_ID'],
      userId: map['USER_ID'],
      eventName: map['EVENT_NAME'],
      unitName: map['UNIT_NAME'],
      eventText: map['EVENT_TEXT'],
      eventDate: map['EVENT_DATE'],
      eventPlace: map['EVENT_PLACE'],
      saleFlag: map['SALE_FLAG'],
      eventStatus: map['EVENT_STATUS'],
    );
  }

  // Eventインスタンスをマップに変換
  Map<String, dynamic> toMap() {
    return {
      'EVENT_ID': eventId,
      'USER_ID': userId,
      'EVENT_NAME': eventName,
      'UNIT_NAME': unitName,
      'EVENT_TEXT': eventText,
      'EVENT_DATE': eventDate,
      'EVENT_PLACE': eventPlace,
      'SALE_FLAG': saleFlag,
      'EVENT_STATUS': eventStatus,
    };
  }
}
