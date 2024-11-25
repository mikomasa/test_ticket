import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'header.dart';
import 'footer.dart';
import 'event.dart';
import 'event_dao.dart';
import 'event_add.dart';
import 'database_helper.dart';

void main() => runApp(EventListApp());

class EventListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ja', ''), // 日本語をサポート
      ],
      locale: Locale('ja', ''), // デフォルトを日本語に設定
      home: EventListPage(),
    );
  }
}

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final TextEditingController keyNameController = TextEditingController();
  DateTimeRange? dateRange;
  List<Event> events = [];
  late EventDAO eventDAO;

  @override
  void initState() {
    super.initState();
    _initializeDB();
  }

  // DB接続の初期化
  Future<void> _initializeDB() async {
    final conn = await DatabaseHelper.connect();
    eventDAO = EventDAO(conn);
    fetchEvents();
  }

  String formatDateWithWeekday(DateTime date) {
    final formatter = DateFormat('MM月dd日(E)', 'ja'); // 日本語形式に変更
    return formatter.format(date);
  }

  // イベントデータの取得
  Future<void> fetchEvents() async {
    try {
      DateTime startDate = dateRange?.start ?? DateTime.now();
      DateTime endDate =
          dateRange?.end ?? DateTime.now().add(Duration(days: 365));
      final fetchedEvents = await eventDAO.getEventsBySearchCriteria(
        form: keyNameController.text,
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        events = fetchedEvents;
      });
    } catch (e) {
      print("Failed to fetch events: $e");
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2124),
      locale: Locale('ja'), // 日本語を明示
      initialDateRange: dateRange,
    );
    if (picked != null && picked != dateRange) {
      setState(() {
        dateRange = picked;
      });
    }
  }

  void showEventDetails(BuildContext context, Event event) {
    String formattedDate = formatDateWithWeekday(event.eventDate);
    String formattedTime = DateFormat('HH:mm').format(event.eventDate);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event.eventName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ユニット名: ${event.unitName}'),
              Text('開催日: $formattedDate'),
              Text('開催時間: $formattedTime'),
              Text('開催場所: ${event.eventPlace}'),
              Text('詳細: ${event.eventText}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: 'イベント一覧'),
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
                  child: Icon(Icons.calendar_today),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchEvents,
              child: Text('検索'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  var event = events[index];
                  String formattedDate = formatDateWithWeekday(event.eventDate);
                  return Card(
                    child: ListTile(
                      title: Text(event.eventName),
                      subtitle: Text(event.unitName),
                      trailing: Text(formattedDate),
                      onTap: () => showEventDetails(context, event),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EventAddPage()),
          );
        },
        child: Icon(Icons.add),
        tooltip: '新規イベント作成',
      ),
      bottomNavigationBar: AppFooter(), // フッターの追加
    );
  }
}
