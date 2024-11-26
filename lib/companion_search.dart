import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl_standalone.dart'; // initializeDateFormatting 用
import 'package:intl/date_symbol_data_local.dart';
import 'database_helper.dart';
import 'header.dart';
import 'footer.dart';
import 'companion_dao.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ja', null); // 日本ロケールの初期化
  runApp(CompanionSearchApp());
}

class CompanionSearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CompanionSearchPage(),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [Locale('ja')], // 日本語対応
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

  late final CompanionDAO companionDAO;

  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  Future<void> initDatabase() async {
    try {
      final conn = await DatabaseHelper.connect();
      companionDAO = CompanionDAO(conn);
      fetchCompanions(); // 初期データの取得
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('データベース初期化エラー: $e')),
      );
    }
  }

  String formatDateWithWeekday(DateTime date) {
    final formatter = DateFormat('MM月dd日(E)', 'ja');
    return formatter.format(date);
  }

  Future<void> fetchCompanions() async {
    DateTime startDate = dateRange?.start ?? DateTime.now();
    
    DateTime endDate =
        dateRange?.end ?? DateTime.now().add(Duration(days: 365));
print(startDate);
    try {
      final results = await companionDAO.searchCompanions(
        keyName: keyNameController.text,
        
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        companions = results;
      });
      // 検索結果を確認
      print("検索結果数: ${companions.length}");
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('募集データ取得エラー: $e')),
      );
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime(2124),
      locale: Locale('ja'),
      initialDateRange: dateRange,
    );
    if (picked != null && picked != dateRange) {
      setState(() {
        dateRange = picked;
      });
    }
  }

  void showCompanionDetails(
      BuildContext context, Map<String, dynamic> companion) {
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
              Text('募集人数: ${companion['RECRUIMENT_MEMBER']}'),
              Text('募集者: ${companion['USER_NAME'] ?? 'N/A'}'),
              Text('募集期限: $limitDate'),
              Text('詳細: ${companion['RECRUIMENT_TEXT'] ?? 'N/A'}'),
              Text(
                'チケット: ${companion['TICKET_AVAILABLE'] == true ? 'あり' : 'なし'}',
              ),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: '同行者検索'),
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
                      ? formatDateWithWeekday(
                          DateTime.parse(companion['EVENT_DATE']))
                      : 'N/A';
                  return Card(
                    child: ListTile(
                      title: Text(companion['RECRUIMENT_TITLE'] ?? 'N/A'),
                      subtitle: Row(
                        children: [
                          Expanded(
                              child: Text(companion['EVENT_NAME'] ?? 'N/A')),
                          if (companion['TICKET_AVAILABLE'] == true)
                            Icon(Icons.confirmation_number,
                                color: Colors.blue), // チケットアイコン
                        ],
                      ),
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
      bottomNavigationBar: AppFooter(),
    );
  }
}
