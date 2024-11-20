import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'class.dart'; // class.dartのインポート
import 'event_list.dart'; // イベント一覧画面のインポート
import 'package:intl/intl.dart'; // インポートを追加

class EventAddPage extends StatefulWidget {
  @override
  _EventAddPageState createState() => _EventAddPageState();
}

class _EventAddPageState extends State<EventAddPage> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController unitNameController = TextEditingController();
  final TextEditingController eventTextController = TextEditingController();
  final TextEditingController eventPlaceController = TextEditingController();
  int eventStatus = 1; // デフォルト値
  DateTime? eventDate; // イベント開催日
  TimeOfDay? eventTime; // イベント時間
  bool isFormValid = false; // フォームが有効かどうかの状態

  @override
  void initState() {
    super.initState();
    // 各フィールドのリスナーを設定
    eventNameController.addListener(_validateForm);
    unitNameController.addListener(_validateForm);
    eventTextController.addListener(_validateForm);
    eventPlaceController.addListener(_validateForm);
  }

  @override
  void dispose() {
    // コントローラーのリスナーを解放
    eventNameController.dispose();
    unitNameController.dispose();
    eventTextController.dispose();
    eventPlaceController.dispose();
    super.dispose();
  }

  // フォームのバリデーションをチェック
  void _validateForm() {
    setState(() {
      isFormValid = eventNameController.text.isNotEmpty &&
          unitNameController.text.isNotEmpty &&
          eventTextController.text.isNotEmpty &&
          eventPlaceController.text.isNotEmpty &&
          eventDate != null &&
          eventTime != null; // イベント日付と時間も必須
    });
  }

  // 日付選択
  Future<void> _pickEventDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2124),
    );
    if (pickedDate != null && pickedDate != eventDate) {
      setState(() {
        eventDate = pickedDate;
        _validateForm(); // 日付選択後にフォームを検証
      });
    }
  }

  // 時間選択
  Future<void> _pickEventTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != eventTime) {
      setState(() {
        eventTime = pickedTime;
        _validateForm(); // 時間選択後にフォームを検証
      });
    }
  }

  // 選択した日付と時間を統合
  DateTime? getCombinedDateTime() {
    if (eventDate != null && eventTime != null) {
      return DateTime(
        eventDate!.year,
        eventDate!.month,
        eventDate!.day,
        eventTime!.hour,
        eventTime!.minute,
      );
    }
    return null;
  }

  Future<void> _submitForm() async {
    final DateTime? combinedDateTime = getCombinedDateTime(); // 統合した日
    if (combinedDateTime == null) return;

    final conn = await DatabaseHelper.connect(); // DB接続
    try {
      await DatabaseHelper.insertEvent(
        conn: conn,
        userId: 1,
        eventName: eventNameController.text,
        unitName: unitNameController.text,
        eventDate: combinedDateTime, // 統合した日時を送信
        eventText: eventTextController.text,
        eventPlace: eventPlaceController.text,
        eventStatus: 1,
      );

      // 成功時に一覧画面に遷移
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EventListPage()),
      );
    } catch (e) {
      print("登録エラー: $e");
    } finally {
      await conn.close(); // 接続を閉じる
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('イベント登録'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: eventNameController,
                decoration: InputDecoration(labelText: 'イベント名'),
              ),
              TextField(
                controller: unitNameController,
                decoration: InputDecoration(labelText: 'ユニット名'),
              ),
              TextField(
                controller: eventPlaceController,
                decoration: InputDecoration(labelText: '開催場所'),
              ),
              TextField(
                controller: eventTextController,
                decoration: InputDecoration(labelText: '詳細'),
              ),
              SizedBox(height: 20),
              // 日付選択ボタンと選択した日付の表示
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    eventDate == null
                        ? '日付を選択してください'
                        : '開催日時: ${DateFormat('yyyy-MM-dd').format(eventDate!)}',
                  ),
                  ElevatedButton(
                    onPressed: _pickEventDate,
                    child: Text('日付選択'),
                  ),
                ],
              ),
              Divider(),
              SizedBox(height: 20),
              // 時間選択ボタンと選択した時間の表示
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    eventTime == null
                        ? '時間を選択してください'
                        : '開催時間: ${eventTime!.format(context)}',
                  ),
                  ElevatedButton(
                    onPressed: _pickEventTime,
                    child: Text('時間選択'),
                  ),
                ],
              ),
              Divider(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isFormValid ? _submitForm : null, // フォームが有効な場合のみ有効化
                child: Text('登録'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
