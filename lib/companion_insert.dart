//同行者募集登録

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // LengthLimitingTextInputFormatter に必要
import 'database_helper.dart';
import 'event_dao.dart';
import 'event.dart';
import 'companion.dart';
import 'companion_dao.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ja'), // 日本語ロケールを指定
      localizationsDelegates: [
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ja'), // 日本語をサポート
      ],
      home: const RegistrationScreen(),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  DateTime? selectedDate; // 選択された日付
  List<Event> suggestedEvents = []; // 検索結果リスト
  TextEditingController searchController = TextEditingController(); // イベント検索用
  TextEditingController titleController = TextEditingController(); // 募集タイトル入力用
  TextEditingController commentController =
      TextEditingController(); // 一言コメント入力用
  String? selectedNumberOfPeople; // 選択された人数
  String? selectedGeneration; // 選択された年代
  String? selectedGender; // 選択された性別
  int? selectedEventId; // 選択されたイベントID

  final List<String> numberOfPeopleOptions =
      List.generate(10, (index) => '${index + 1}人'); // 募集人数オプション
  final List<String> generations = [
    '～20代',
    '30代',
    '40代',
    '50代',
    '60代～',
    '指定なし',
  ]; // 募集年代オプション
  final List<String> genders = ['男性', '女性', '指定なし']; // 性別オプション

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('募集登録画面'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications), // 通知アイコン
            onPressed: () {},
          ),
          CircleAvatar(
            backgroundImage:
                NetworkImage('https://via.placeholder.com/150'), // 仮のプロフィール画像
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // イベント名
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'イベント名・アーティスト名・主催者名',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _searchEvents,
                  child: const Text('検索'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (suggestedEvents.isNotEmpty) ...[
              const Text(
                '検索結果:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: suggestedEvents.length,
                itemBuilder: (context, index) {
                  final event = suggestedEvents[index];
                  return ListTile(
                    title: Text(event.eventName),
                    subtitle: Text('${event.unitName} - ${event.eventPlace}'),
                    onTap: () {
                      setState(() {
                        searchController.text = event.eventName; // 検索フィールド更新
                        selectedEventId = event.eventId; // 選択イベントID保存
                        suggestedEvents = []; // 検索結果をクリア
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],

            // 募集タイトル
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '募集タイトル',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // 日付を選択
            TextField(
              controller: TextEditingController(
                text: selectedDate != null
                    ? '${selectedDate!.year}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.day.toString().padLeft(2, '0')}'
                    : '',
              ),
              decoration: const InputDecoration(
                labelText: '日付を選択',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                await _showDatePicker(context); // 日付選択ダイアログ
              },
            ),
            const SizedBox(height: 20),

            // 募集人数
            const Text(
              '募集人数',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: selectedNumberOfPeople,
              items: numberOfPeopleOptions.map((number) {
                return DropdownMenuItem(
                  value: number,
                  child: Text(number),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedNumberOfPeople = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // 募集年代
            const Text(
              '募集年代',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: selectedGeneration,
              items: generations.map((generation) {
                return DropdownMenuItem(
                  value: generation,
                  child: Text(generation),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGeneration = value; // 選択年代保存
                });
              },
            ),
            const SizedBox(height: 20),

            // 性別
            const Text(
              '性別',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              value: selectedGender,
              items: genders.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // 一言コメント
            const Text(
              '一言コメント',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: commentController, // 一言コメント入力用
              decoration: const InputDecoration(
                labelText: 'コメントを入力してください',
                border: OutlineInputBorder(),
                counterText: '', // カウンターを非表示
              ),
              maxLength: 1000, // 最大文字数
              inputFormatters: [
                LengthLimitingTextInputFormatter(1000), // 最大文字数制限
              ],
              maxLines: 3, // 最大3行の入力を許可
            ),
            const SizedBox(height: 20),

            // 登録ボタン
            Center(
              child: ElevatedButton(
                onPressed: _registerData,
                child: const Text('登録'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '同行者',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'チケット',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'レポート',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'チャット',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Future<void> _searchEvents() async {
    final searchText = searchController.text.trim();
    if (searchText.isEmpty) return;

    try {
      final connection = await DatabaseHelper.connect();
      final eventDAO = EventDAO(connection);
      final events = await eventDAO.getEventsBySearchCriteria(
        form: searchText,
      );

      setState(() {
        suggestedEvents = events;
      });

      await connection.close();
    } catch (e) {
      print("Error during event search: $e");
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
      locale: const Locale('ja'),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  void _registerData() async {
    if (selectedDate == null) {
      print("日付が設定されていません。");
      return;
    }
    if (selectedEventId == null) {
      print("イベントが選択されていません。");
      return;
    }

    Companion companion = Companion(
      userId: 1, // 仮のユーザーID
      eventId: selectedEventId!, // 選択イベントID
      recruitmentTitle: titleController.text,
      recruitmentMember:
          int.tryParse(selectedNumberOfPeople?.replaceAll('人', '') ?? '0') ?? 0,
      recruitmentLimit: DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
      ),
      recruitmentGender: genders.indexOf(selectedGender ?? ''),
      recruitmentAge: int.tryParse(selectedGeneration?.split(':')[0] ?? '6') ??
          6, // 年代インデックス
      recruitmentText: commentController.text, // 一言コメントをそのまま保存
    );

    try {
      final connection = await DatabaseHelper.connect();
      final companionDAO = CompanionDAO(connection);

      await companionDAO.insertCompanion(companion);
      await connection.close();

      print("データが正常に登録されました。");
    } catch (e) {
      print("登録中にエラーが発生しました: $e");
    }
  }
}
