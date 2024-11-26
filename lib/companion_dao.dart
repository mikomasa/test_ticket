import 'package:postgres/postgres.dart';
import 'companion.dart';

class CompanionDAO {
  final PostgreSQLConnection conn;

  CompanionDAO(this.conn);

  // データをインサートする機能
  Future<int> insertCompanion(Companion companion) async {
    final result = await conn.query('''
      INSERT INTO COMPANION (USER_ID, EVENT_ID, RECRUITMENT_TITLE, RECRUITMENT_MEMBER,
        RECRUITMENT_LIMIT, RECRUITMENT_GENDER, RECRUITMENT_AGE, RECRUITMENT_TEXT)
      VALUES (@userId, @eventId, @recruitmentTitle, @recruitmentMember,
        @recruitmentLimit, @recruitmentGender, @recruitmentAge, @recruitmentText)
      RETURNING COMPANION_ID;
    ''', substitutionValues: {
      'userId': companion.userId,
      'eventId': companion.eventId,
      'recruitmentTitle': companion.recruitmentTitle,
      'recruitmentMember': companion.recruitmentMember,
      'recruitmentLimit': companion.recruitmentLimit.toIso8601String(),
      'recruitmentGender': companion.recruitmentGender,
      'recruitmentAge': companion.recruitmentAge,
      'recruitmentText': companion.recruitmentText,
    });

    return result.first[0] as int; // 挿入されたCOMPANION_IDを返す
  }

  // キーワードと日付範囲で同行者を検索する機能（修正した）
  Future<List<Map<String, dynamic>>> searchCompanions({
    required String keyName,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    String query = '''
      SELECT 
          C.recruitment_title, 
          C.recruitment_member, 
          C.recruitment_limit, 
          C.recruitment_text,
          C.ticket_available,
          U.USER_NAME, 
          E.EVENT_NAME, 
          E.EVENT_DATE
      FROM COMPANION C
      JOIN EVENT E ON C.EVENT_ID = E.EVENT_ID
      JOIN "USER" U ON C.USER_ID = U.USER_ID
      WHERE (C.recruitment_title LIKE @keyName OR E.EVENT_NAME LIKE @keyName)
        AND E.EVENT_DATE BETWEEN @startDate AND @endDate
      ORDER BY E.EVENT_DATE ASC;
    ''';

    final results = await conn.query(query, substitutionValues: {
      'keyName': '%$keyName%',
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    });

    return results.map((row) {
      return {
        'RECRUIMENT_TITLE': row[0],
        'RECRUIMENT_MEMBER': row[1],
        'RECRUIMENT_LIMIT': row[2]?.toString(),
        'RECRUIMENT_TEXT': row[3],
        'TICKET_AVAILABLE': row[4]?.toString(),
        'USER_NAME': row[5],
        'EVENT_NAME': row[6],
        'EVENT_DATE': row[7]?.toString(),
      };
    }).toList();
  }

  //タグを取得する機能
}
