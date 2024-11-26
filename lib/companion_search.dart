import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:intl/intl.dart';

void main() => runApp(CompanionSearchApp());

class CompanionSearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CompanionSearchPage(),
    );
  }
}

class CompanionSearchPage extends StatefulWidget {
  @override
  _CompanionSearchPageState createState() => _CompanionSearchPageState();
}

class _CompanionSearchPageState extends State<CompanionSearchPage> {
  final TextEditingController keyNameController = TextEditingController();
  DateTimeRange? dateRange;

  List<Map<String, dynamic>> companions = [];

  // DB接続設定
  static const String host = '34.133.243.227';
  static const int port = 5432;
  static const String databaseName = 'ticket';
  static const String username = 'postgres';
  static const String password = 'testticket';

  Future<PostgreSQLConnection> connect() async {
    final conn = PostgreSQLConnection(
      host,
      port,
      databaseName,
      username: username,
      password: password,
    );
    try {
      await conn.open();
      return conn;
    } catch (e) {
      print("Connection failed: $e");
      rethrow;
    }
  }

  String formatDateWithWeekday(DateTime date) {
    final weekDays = ['日', '月', '火', '水', '木', '金', '土'];
    String formattedDate = DateFormat('MM/dd').format(date);
    String weekDay = weekDays[date.weekday % 7];
    return '$formattedDate($weekDay)';
  }

  Future<void> fetchCompanions() async {
    final conn = await connect();

    String query = '''
      SELECT C.recruitment_title, C.recruitment_member, C.recruitment_limit, C.recruitment_text,
          U.USER_NAME, 
          E.EVENT_NAME, E.EVENT_DATE
      FROM COMPANION C
      JOIN EVENT E ON C.EVENT_ID = E.EVENT_ID
      JOIN "USER" U ON C.USER_ID = U.USER_ID -- テーブル名をダブルクォートで囲む
    WHERE (C.recruitment_title LIKE @keyName OR E.EVENT_NAME LIKE @keyName)
      AND E.EVENT_DATE BETWEEN @startDate AND @endDate
    ORDER BY E.EVENT_DATE ASC;
    ''';

    DateTime startDate = dateRange?.start ?? DateTime.now();
    DateTime endDate = dateRange?.end ?? DateTime.now().add(Duration(days: 365));

    try {
      final results = await conn.query(query, substitutionValues: {
        'keyName': '%${keyNameController.text}%',
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      });

      setState(() {
        companions = results
            .map((row) => {
                  'RECRUIMENT_TITLE': row[0],
                  'RECRUIMENT_MEMBER': row[1],
                  'RECRUIMENT_LIMIT': row[2]?.toString(),
                  'RECRUIMENT_TEXT': row[3],
                  'USER_NAME': row[4],
                  'EVENT_NAME': row[5],
                  'EVENT_DATE': row[6]?.toString(),
                })
            .toList();
      });
    } catch (e) {
      print("Failed to fetch companions: $e");
    } finally {
      await conn.close();
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2124),
      initialDateRange: dateRange,
    );
    if (picked != null && picked != dateRange) {
      setState(() {
        dateRange = picked;
      });
    }
  }

  void showCompanionDetails(BuildContext context, Map<String, dynamic> companion) {
    String formattedDate = companion['EVENT_DATE'] != null
        ? formatDateWithWeekday(DateTime.parse(companion['EVENT_DATE']))
        : 'N/A';
    String limitDate = companion['RECRUIMENT_LIMIT'] != null
        ? formatDateWithWeekday(DateTime.parse(companion['RECRUIMENT_LIMIT']))
        : 'N/A';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(companion['RECRUIMENT_TITLE'] ?? 'N/A'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('イベント名: ${companion['EVENT_NAME'] ?? 'N/A'}'),
              Text('開催日: $formattedDate'),
              Text('募集メンバー: ${companion['RECRUIMENT_MEMBER']}'),
              Text('募集者: ${companion['USER_NAME'] ?? 'N/A'}'),
              Text('募集期限: $limitDate'),
              Text('詳細: ${companion['RECRUIMENT_TEXT'] ?? 'N/A'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('この募集に参加する'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('閉じる'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCompanions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("同行者検索"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: keyNameController,
              decoration: InputDecoration(
                labelText: 'キーワードを入力してください',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateRange == null
                      ? '日付を指定してください'
                      : '${formatDateWithWeekday(dateRange!.start)} - ${formatDateWithWeekday(dateRange!.end)}',
                ),
                ElevatedButton(
                  onPressed: () => _selectDateRange(context),
                  child: Text('範囲指定'),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchCompanions,
              child: Text('検索'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: companions.length,
                itemBuilder: (context, index) {
                  var companion = companions[index];
                  String formattedDate = companion['EVENT_DATE'] != null
                      ? formatDateWithWeekday(DateTime.parse(companion['EVENT_DATE']))
                      : 'N/A';
                  return Card(
                    child: ListTile(
                      title: Text(companion['RECRUIMENT_TITLE'] ?? 'N/A'),
                      subtitle: Text(companion['EVENT_NAME'] ?? 'N/A'),
                      trailing: Text(formattedDate),
                      onTap: () => showCompanionDetails(context, companion),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
