import 'package:postgres/postgres.dart';
import 'user.dart'; // Userクラスを定義したファイル

class UserDAO {
  final PostgreSQLConnection conn;

  UserDAO(this.conn);

  // 新規登録
  Future<void> registerUser(User user) async {
    await conn.query('''
      INSERT INTO "USER" (
        USER_NAME,
        EMAIL_ADDRESS,
        PASSWORD,
        ICON_IMAGE_URL,
        COMMENT,
        RESIDENCE,
        SUBSCRIPTION,
        GENDER,
        AGE,
        WITHDRAWAL_FLAG
      ) VALUES (
        @userName,
        @emailAddress,
        @password,
        @iconImageUrl,
        @comment,
        @residence,
        @subscription,
        @gender,
        @age,
        @withdrawalFlag
      )
    ''', substitutionValues: {
      'userName': user.userName,
      'emailAddress': user.emailAddress,
      'password': user.password,
      'iconImageUrl': user.iconImageUrl,
      'comment': user.comment,
      'residence': user.residence,
      'subscription': user.subscription.toIso8601String(),
      'gender': user.gender,
      'age': user.age,
      'withdrawalFlag': user.withdrawalFlag,
    });

    print("User registered successfully.");
  }

  // IDとパスワードでデータ取得
  Future<User?> getUserByIdAndPassword(int userId, String password) async {
    final result = await conn.query('''
      SELECT * FROM "USER"
      WHERE USER_ID = @userId AND PASSWORD = @password
    ''', substitutionValues: {
      'userId': userId,
      'password': password,
    });

    if (result.isEmpty) return null;

    return User.fromMap(result.first.toColumnMap());
  }

  // パスワード更新
  Future<void> updatePassword(int userId, String newPassword) async {
    await conn.query('''
      UPDATE "USER"
      SET PASSWORD = @newPassword
      WHERE USER_ID = @userId
    ''', substitutionValues: {
      'userId': userId,
      'newPassword': newPassword,
    });

    print("Password updated successfully.");
  }

  // ユーザーデータ取得
  Future<User?> getUserById(int userId) async {
    final result = await conn.query('''
      SELECT * FROM "USER"
      WHERE USER_ID = @userId
    ''', substitutionValues: {
      'userId': userId,
    });

    if (result.isEmpty) return null;

    return User.fromMap(result.first.toColumnMap());
  }

  // フラグをtrueに更新
  Future<void> updateWithdrawalFlag(int userId) async {
    await conn.query('''
      UPDATE "USER"
      SET WITHDRAWAL_FLAG = TRUE
      WHERE USER_ID = @userId
    ''', substitutionValues: {
      'userId': userId,
    });

    print("Withdrawal flag updated to true.");
  }

  // SUBSCRIPTIONを更新
  Future<void> updateSubscriptionDate(
      int userId, DateTime newSubscription) async {
    await conn.query('''
      UPDATE "USER"
      SET SUBSCRIPTION = @newSubscription
      WHERE USER_ID = @userId
    ''', substitutionValues: {
      'userId': userId,
      'newSubscription': newSubscription.toIso8601String(),
    });

    print("Subscription date updated.");
  }
}
