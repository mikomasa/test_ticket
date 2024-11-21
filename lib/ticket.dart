class Ticket {
  int? ticketId; // PRIMARY KEY, nullの可能性あり（新規作成時に自動採番されるため）
  int userId; // FOREIGN KEY: "USER".USER_ID
  int eventId; // FOREIGN KEY: EVENT.EVENT_ID
  int price; // チケットの価格
  int commission; // 手数料
  int totalSheet; // 全体の枚数
  int ticketMax; // 1人あたりの最大枚数
  DateTime ticketLimit; // チケット販売期限
  DateTime ticketDate; // チケット登録日

  Ticket({
    this.ticketId,
    required this.userId,
    required this.eventId,
    required this.price,
    required this.commission,
    required this.totalSheet,
    required this.ticketMax,
    required this.ticketLimit,
    required this.ticketDate,
  });

  // マップからTicketインスタンスを作成するファクトリーメソッド
  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      ticketId: map['TICKET_ID'],
      userId: map['USER_ID'],
      eventId: map['EVENT_ID'],
      price: map['PRICE'],
      commission: map['COMMISSION'],
      totalSheet: map['TOTAL_SHEET'],
      ticketMax: map['TICKET_MAX'],
      ticketLimit: map['TICKET_LIMIT'],
      ticketDate: map['TICKET_DATE'],
    );
  }

  // Ticketインスタンスをマップに変換
  Map<String, dynamic> toMap() {
    return {
      'TICKET_ID': ticketId,
      'USER_ID': userId,
      'EVENT_ID': eventId,
      'PRICE': price,
      'COMMISSION': commission,
      'TOTAL_SHEET': totalSheet,
      'TICKET_MAX': ticketMax,
      'TICKET_LIMIT': ticketLimit,
      'TICKET_DATE': ticketDate,
    };
  }
}
