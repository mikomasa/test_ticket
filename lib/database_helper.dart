import 'package:postgres/postgres.dart'; // postgres パッケージのインポート

class DatabaseHelper {
  static final String host = '34.133.243.227';
  static final int port = 5432; // デフォルトのPostgreSQLポート
  static final String databaseName = 'ticket';
  static final String username = 'postgres';
  static final String password = 'testticket';

  // PostgreSQLへの接続メソッド
  static Future<PostgreSQLConnection> connect() async {
    final conn = PostgreSQLConnection(
      host,
      port,
      databaseName,
      username: username,
      password: password,
    );

    // データベースに接続
    await conn.open();
    print("データベースに接続しました。");
    return conn;
  }
}
