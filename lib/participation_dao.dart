import 'package:postgres/postgres.dart';
import 'participation.dart';

class ParticipationDAO {
  final PostgreSQLConnection conn;

  ParticipationDAO(this.conn);

  // フラグをtrueにして挿入
  Future<void> insertWithTrueFlag(Participation participation) async {
    await conn.query('''
      INSERT INTO participation (
        USER_ID,
        COMPANION_ID,
        PARTICIPATION_DATE,
        PARTICIPATION_FLAG
      ) VALUES (
        @userId,
        @companionId,
        @participationDate,
        true
      )
    ''', substitutionValues: {
      'userId': participation.userId,
      'companionId': participation.companionId,
      'participationDate': participation.participationDate,
    });

    print("Participation inserted with flag true.");
  }

  // フラグをfalseにして挿入
  Future<void> insertWithFalseFlag(Participation participation) async {
    await conn.query('''
      INSERT INTO participation (
        USER_ID,
        COMPANION_ID,
        PARTICIPATION_DATE,
        PARTICIPATION_FLAG
      ) VALUES (
        @userId,
        @companionId,
        @participationDate,
        false
      )
    ''', substitutionValues: {
      'userId': participation.userId,
      'companionId': participation.companionId,
      'participationDate': participation.participationDate,
    });

    print("Participation inserted with flag false.");
  }

  // フラグで検索
  Future<List<Participation>> getParticipationsByFlag(bool flag) async {
    final results = await conn.query('''
      SELECT * FROM participation
      WHERE PARTICIPATION_FLAG = @flag
    ''', substitutionValues: {
      'flag': flag,
    });

    return results.map((row) {
      return Participation.fromMap({
        'USER_ID': row[0],
        'COMPANION_ID': row[1],
        'PARTICIPATION_DATE': row[2],
        'PARTICIPATION_FLAG': row[3],
      });
    }).toList();
  }
}
