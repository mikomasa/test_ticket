import 'package:postgres/postgres.dart';
import 'event.dart';

class EventDAO {
  final PostgreSQLConnection conn;

  EventDAO(this.conn);

  // イベントの登録
  Future<void> insertEvent(Event event) async {
    await conn.query('''
      INSERT INTO event (
        USER_ID,
        EVENT_NAME,
        UNIT_NAME,
        EVENT_TEXT,
        EVENT_DATE,
        EVENT_PLACE,
        SALE_FLAG,
        EVENT_STATUS
      ) VALUES (
        @userId,
        @eventName,
        @unitName,
        @eventText,
        @eventDate,
        @eventPlace,
        @saleFlag,
        @eventStatus
      )
    ''', substitutionValues: {
      'userId': event.userId,
      'eventName': event.eventName,
      'unitName': event.unitName,
      'eventText': event.eventText,
      'eventDate': event.eventDate,
      'eventPlace': event.eventPlace,
      'saleFlag': event.saleFlag,
      'eventStatus': event.eventStatus,
    });

    print("Event inserted successfully.");
  }

  // イベント名、アーティスト名、主催者名で部分一致検索
  Future<List<Event>> getEventsBySearchCriteria({
    String? form, // 検索用の引数 form
  }) async {
    if (form == null || form.isEmpty) return []; // formが空の場合は空のリストを返す

    // 部分一致検索用のSQLクエリ
    String query = '''
    SELECT e.* FROM event e
    WHERE
      e.EVENT_NAME LIKE @form
      OR e.UNIT_NAME LIKE @form
      OR e.EVENT_TEXT LIKE @form
  ''';

    final results = await conn.query(query, substitutionValues: {
      'form': '%$form%', // formに渡された値で部分一致検索
    });

    return results.map((row) {
      return Event.fromMap({
        'EVENT_ID': row[0],
        'USER_ID': row[1],
        'EVENT_NAME': row[2],
        'UNIT_NAME': row[3],
        'EVENT_TEXT': row[4],
        'EVENT_DATE': row[5],
        'EVENT_PLACE': row[6],
        'SALE_FLAG': row[7],
        'EVENT_STATUS': row[8],
      });
    }).toList();
  }
}
