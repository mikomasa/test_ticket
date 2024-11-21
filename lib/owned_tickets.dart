class OwnedTickets {
  int? ownedTicketsId; // 自動生成されるPRIMARY KEY
  int userId; // ユーザーID (外部キー)
  int ticketId; // チケットID (外部キー)
  int ticketPurchasedSheet; // 購入したチケットの枚数
  DateTime ticketPurchaseDate; // チケット購入日
  DateTime ticketUserDate; // チケット使用日 (デフォルト値あり)

  OwnedTickets({
    this.ownedTicketsId,
    required this.userId,
    required this.ticketId,
    required this.ticketPurchasedSheet,
    required this.ticketPurchaseDate,
    required this.ticketUserDate,
  });

  // マップからOwnedTicketsインスタンスを作成するファクトリーメソッド
  factory OwnedTickets.fromMap(Map<String, dynamic> map) {
    return OwnedTickets(
      ownedTicketsId: map['OWNED_TICKETS_ID'],
      userId: map['USER_ID'],
      ticketId: map['TICKET_ID'],
      ticketPurchasedSheet: map['TICKET_PURCHASED_SHEET'],
      ticketPurchaseDate: DateTime.parse(map['TICKET_PURCHASE_DATE']),
      ticketUserDate: DateTime.parse(map['TICKET_USER_DATE']),
    );
  }

  // OwnedTicketsインスタンスをマップに変換
  Map<String, dynamic> toMap() {
    return {
      'OWNED_TICKETS_ID': ownedTicketsId,
      'USER_ID': userId,
      'TICKET_ID': ticketId,
      'TICKET_PURCHASED_SHEET': ticketPurchasedSheet,
      'TICKET_PURCHASE_DATE': ticketPurchaseDate.toIso8601String(),
      'TICKET_USER_DATE': ticketUserDate.toIso8601String(),
    };
  }
}
