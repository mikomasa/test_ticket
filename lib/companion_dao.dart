import 'package:postgres/postgres.dart';
import 'companion.dart';

class CompanionDAO {
  final PostgreSQLConnection conn;

  CompanionDAO(this.conn);

  // COMPANIONテーブルにデータを挿入する
  Future<void> insertCompanion(Companion companion) async {
    await conn.query('''
      INSERT INTO companion (
        companion_id, -- 自動生成されるため省略可能
        user_id,
        event_id,
        recruitment_title,
        recruitment_member,
        recruitment_limit,
        recruitment_gender,
        recruitment_age,
        recruitment_text
      ) VALUES (
        DEFAULT, -- SERIAL カラムは自動生成
        @userId,
        @eventId,
        @recruitmentTitle,
        @recruitmentMember,
        @recruitmentLimit,
        @recruitmentGender,
        @recruitmentAge,
        @recruitmentText
      )
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

    print("データがCOMPANIONテーブルに正常に登録されました。");
  }

  // COMPANIONテーブルからデータを取得する
  Future<List<Companion>> getAllCompanions() async {
    final results = await conn.query('SELECT * FROM COMPANION');

    return results.map((row) {
      return Companion.fromMap({
        'COMPANION_ID': row[0],
        'USER_ID': row[1],
        'EVENT_ID': row[2],
        'RECRUITMENT_TITLE': row[3],
        'RECRUITMENT_MEMBER': row[4],
        'RECRUITMENT_LIMIT': row[5].toString(),
        'RECRUITMENT_GENDER': row[6],
        'RECRUITMENT_AGE': row[7],
        'RECRUITMENT_TEXT': row[8],
      });
    }).toList();
  }

  // 特定の条件でデータを検索する (例: ユーザーIDで検索)
  Future<List<Companion>> getCompanionsByUserId(int userId) async {
    final results = await conn.query('''
      SELECT * FROM COMPANION
      WHERE USER_ID = @userId
    ''', substitutionValues: {'userId': userId});

    return results.map((row) {
      return Companion.fromMap({
        'COMPANION_ID': row[0],
        'USER_ID': row[1],
        'EVENT_ID': row[2],
        'RECRUITMENT_TITLE': row[3],
        'RECRUITMENT_MEMBER': row[4],
        'RECRUITMENT_LIMIT': row[5].toString(),
        'RECRUITMENT_GENDER': row[6],
        'RECRUITMENT_AGE': row[7],
        'RECRUITMENT_TEXT': row[8],
      });
    }).toList();
  }

  // データを更新する
  Future<void> updateCompanion(Companion companion) async {
    await conn.query('''
      UPDATE COMPANION
      SET
        USER_ID = @userId,
        EVENT_ID = @eventId,
        RECRUITMENT_TITLE = @recruitmentTitle,
        RECRUITMENT_MEMBER = @recruitmentMember,
        RECRUITMENT_LIMIT = @recruitmentLimit,
        RECRUITMENT_GENDER = @recruitmentGender,
        RECRUITMENT_AGE = @recruitmentAge,
        RECRUITMENT_TEXT = @recruitmentText
      WHERE COMPANION_ID = @companionId
    ''', substitutionValues: companion.toMap());

    print("COMPANIONテーブルのデータを更新しました。");
  }

  // データを削除する
  Future<void> deleteCompanion(int companionId) async {
    await conn.query('''
      DELETE FROM COMPANION
      WHERE COMPANION_ID = @companionId
    ''', substitutionValues: {'companionId': companionId});

    print("COMPANIONテーブルのデータを削除しました。");
  }
}
