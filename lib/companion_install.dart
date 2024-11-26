import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_ticket/event_list.dart';
import 'header.dart';
import 'footer.dart';
import 'database_helper.dart';
import 'event.dart';
import 'event_dao.dart';
import 'companion.dart';
import 'companion_dao.dart';

class CompanionInsert extends StatefulWidget {
  @override
  _CompanionInsertState createState() => _CompanionInsertState();
}

class _CompanionInsertState extends State<CompanionInsert> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  DateTime? selectedDate;
  String? selectedNumberOfPeople;
  String? selectedGeneration;
  String? selectedGender;
  int? selectedEventId;

  List<Event> suggestedEvents = [];
  bool isFormValid = false;

  final List<String> numberOfPeopleOptions =
      List.generate(10, (index) => '${index + 1}人');
  final List<String> generations = [
    '～20代',
    '30代',
    '40代',
    '50代',
    '60代～',
    '指定なし'
  ];
  final List<String> genders = ['男性', '女性', 'その他','指定なし'];

  @override
  void initState() {
    super.initState();
    _updateFormState();
  }

  void _updateFormState() {
    setState(() {
      isFormValid = selectedDate != null &&
          selectedEventId != null &&
          titleController.text.isNotEmpty &&
          selectedNumberOfPeople != null &&
          selectedGeneration != null &&
          selectedGender != null &&
          commentController.text.isNotEmpty;
    });
  }

  Future<void> _searchEvents() async {
    final searchText = searchController.text.trim();
    if (searchText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('検索キーワードを入力してください')),
      );
      return;
    }

    try {
      final connection = await DatabaseHelper.connect();
      final eventDAO = EventDAO(connection);

      // 検索結果を取得
      final events = await eventDAO.getEventsSearch(form: searchText);

      // 検索結果を確認
      print("検索結果数: ${events.length}");
      events.forEach((event) {
        print("イベント名: ${event.eventName}");
      });

      setState(() {
        suggestedEvents = events; // 検索結果を更新
      });

      await connection.close();
    } catch (e) {
      print("エラーが発生しました: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('イベント検索中にエラーが発生しました。')),
      );
    }
  }

  Future<void> _showDatePicker() async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      locale: const Locale('ja', 'JP'),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        _updateFormState();
      });
    }
  }

  void _registerData() async {
    if (!isFormValid) return;

    try {
      final companion = Companion(
        userId: 1,
        eventId: selectedEventId!,
        recruitmentTitle: titleController.text,
        recruitmentMember:
            int.tryParse(selectedNumberOfPeople!.replaceAll('人', '') ?? '0') ??
                0,
        recruitmentLimit: selectedDate!,
        recruitmentGender: genders.indexOf(selectedGender!),
        recruitmentAge: generations.indexOf(selectedGeneration!),
        recruitmentText: commentController.text,
      );

      final connection = await DatabaseHelper.connect();
      final companionDAO = CompanionDAO(connection);
      await companionDAO.insertCompanion(companion);

      await connection.close();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('募集が正常に登録されました。')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登録中にエラーが発生しました。')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: "募集登録"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // イベント検索フィールド
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'イベント名・アーティスト名・主催者名',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => _updateFormState(),
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

            // 検索結果表示
            if (suggestedEvents.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        subtitle:
                            Text('${event.unitName} - ${event.eventPlace}'),
                        onTap: () {
                          setState(() {
                            searchController.text = event.eventName;
                            selectedEventId = event.eventId;
                            suggestedEvents = [];
                            _updateFormState();
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // すべてのイベントを表示ボタン
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EventListApp()),
                        );
                      },
                      child: const Text('すべてのイベントを表示'),
                    ),
                  ),
                ],
              ),

            // その他入力フィールド
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: '募集タイトル',
              ),
              onChanged: (_) => _updateFormState(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? '募集期限を選択してください'
                      : '開催日時: ${DateFormat('yyyy年MM月dd日', 'ja').format(selectedDate!)}',
                ),
                ElevatedButton(
                  onPressed: _showDatePicker,
                  child: Icon(Icons.calendar_today),
                ),
              ],
            ),
            Divider(),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '募集人数',
              ),
              value: selectedNumberOfPeople,
              items: numberOfPeopleOptions.map((number) {
                return DropdownMenuItem(value: number, child: Text(number));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedNumberOfPeople = value;
                  _updateFormState();
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '募集年代',
              ),
              value: selectedGeneration,
              items: generations.map((generation) {
                return DropdownMenuItem(
                    value: generation, child: Text(generation));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGeneration = value;
                  _updateFormState();
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '性別',
              ),
              value: selectedGender,
              items: genders.map((gender) {
                return DropdownMenuItem(value: gender, child: Text(gender));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGender = value;
                  _updateFormState();
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: '一言コメント',
              ),
              maxLines: 3,
              onChanged: (_) => _updateFormState(),
            ),
            const SizedBox(height: 20),

            // 登録ボタン
            Center(
              child: ElevatedButton(
                onPressed: isFormValid ? _registerData : null,
                child: const Text('登録'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppFooter(),
    );
  }
}