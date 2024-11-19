import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:intl/intl.dart';

void main() => runApp(EventListApp());

class EventListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: EventListPage(),
    );
  }
}

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController unitNameController = TextEditingController();
  DateTimeRange? dateRange;

  List<Map<String, dynamic>> events = [];

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

  // 日付フォーマット関数
  String formatDateWithWeekday(DateTime date) {
    final weekDays = ['日', '月', '火', '水', '木', '金', '土'];
    String formattedDate = DateFormat('MM/dd').format(date);
    String weekDay = weekDays[date.weekday % 7];
    return '$formattedDate($weekDay)';
  }

  // EVENTテーブルから全件取得
  Future<void> fetchEvents() async {
    final conn = await connect();

    String query = '''
      SELECT EVENT_ID, EVENT_NAME, UNIT_NAME, EVENT_TEXT, EVENT_DATE, EVENT_PLACE
      FROM EVENT
      WHERE EVENT_NAME LIKE @eventName
        AND UNIT_NAME LIKE @unitName
        AND EVENT_DATE BETWEEN @startDate AND @endDate
      ORDER BY EVENT_DATE ASC -- イベント日で昇順ソート
    ''';

    //今日から１年間を始めに表示する
    DateTime startDate = dateRange?.start ?? DateTime.now();
    DateTime endDate = dateRange?.end ?? DateTime.now().add(Duration(days: 365));


    try {
      final results = await conn.query(query, substitutionValues: {
        'eventName': '%${eventNameController.text}%',
        'unitName': '%${unitNameController.text}%',
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      });

      setState(() {
        events = results
            .map((row) => {
                  'EVENT_NAME': row[1],
                  'UNIT_NAME': row[2],
                  'EVENT_TEXT': row[3],
                  'EVENT_DATE': row[4].toString(),
                  'EVENT_PLACE': row[5],
                })
            .toList();
      });
    } catch (e) {
      print("Failed to fetch events: $e");
    } finally {
      await conn.close();
    }
  }


  // 日付範囲ピッカー
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

  // ポップアップダイアログを表示
  void showEventDetails(BuildContext context, Map<String, dynamic> event) {
    String formattedDate = event['EVENT_DATE'] != null
        ? formatDateWithWeekday(DateTime.parse(event['EVENT_DATE']))
        : 'N/A';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event['EVENT_NAME'] ?? 'N/A'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ユニット名: ${event['UNIT_NAME'] ?? 'N/A'}'),
              Text('開催日: $formattedDate'),
              Text('開催場所: ${event['EVENT_PLACE'] ?? 'N/A'}'),
              Text('詳細: ${event['EVENT_TEXT'] ?? 'N/A'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 決定ボタンの処理（後で実装）
                print('決定ボタンが押されました');
                Navigator.of(context).pop();
              },
              child: Text('決定'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('戻る'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchEvents(); // 初期表示時にデータを取得
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("イベント一覧"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 検索バー
            TextField(
              controller: eventNameController,
              decoration: InputDecoration(
                labelText: 'イベント名を入力してください',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: unitNameController,
              decoration: InputDecoration(
                labelText: 'ユニット名を入力してください',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            // 日付範囲選択
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
            // 検索ボタン
            ElevatedButton(
              onPressed: fetchEvents,
              child: Text('検索'),
            ),
            SizedBox(height: 16),
            // イベント一覧表示
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  var event = events[index];
                  String formattedDate = event['EVENT_DATE'] != null
                      ? formatDateWithWeekday(DateTime.parse(event['EVENT_DATE']))
                      : 'N/A';
                  return Card(
                    child: ListTile(
                      title: Text(event['EVENT_NAME'] ?? 'N/A'),
                      subtitle: Text(event['UNIT_NAME'] ?? 'N/A'),
                      trailing: Text(formattedDate),
                      onTap: () => showEventDetails(context, event), // タップ時にポップアップを表示
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
