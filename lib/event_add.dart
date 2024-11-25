import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'header.dart';
import 'footer.dart';
import 'event_list.dart';
import 'event.dart';
import 'event_dao.dart';
import 'database_helper.dart';

class EventAddPage extends StatefulWidget {
  @override
  _EventAddPageState createState() => _EventAddPageState();
}

class _EventAddPageState extends State<EventAddPage> {
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController unitNameController = TextEditingController();
  final TextEditingController eventTextController = TextEditingController();
  final TextEditingController eventPlaceController = TextEditingController();
  final TextEditingController organizerNameController =TextEditingController();
  int eventStatus = 1; // デフォルト値
  DateTime? eventDate;
  TimeOfDay? eventTime;
  bool isFormValid = false;

  @override
  void initState() {
    super.initState();
    eventNameController.addListener(_validateForm);
    unitNameController.addListener(_validateForm);
    eventTextController.addListener(_validateForm);
    eventPlaceController.addListener(_validateForm);
    organizerNameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    eventNameController.dispose();
    unitNameController.dispose();
    eventTextController.dispose();
    eventPlaceController.dispose();
    organizerNameController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      isFormValid = eventNameController.text.isNotEmpty &&
          unitNameController.text.isNotEmpty &&
          eventTextController.text.isNotEmpty &&
          eventPlaceController.text.isNotEmpty &&
          eventDate != null &&
          eventTime != null &&
          organizerNameController.text.isNotEmpty;
    });
  }

  Future<void> _pickEventDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2124),
      locale: Locale('ja'), // 日本語ロケールを設定
    );
    if (pickedDate != null && pickedDate != eventDate) {
      setState(() {
        eventDate = pickedDate;
        _validateForm();
      });
    }
  }

  Future<void> _showTimePicker(BuildContext context) async {
    Duration initialTimer = Duration(
      hours: eventTime?.hour ?? 0,
      minutes: eventTime?.minute ?? 0,
    );

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                '時間を選択してください',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: CupertinoTimerPicker(
                mode: CupertinoTimerPickerMode.hm,
                initialTimerDuration: initialTimer,
                onTimerDurationChanged: (Duration newDuration) {
                  setState(() {
                    eventTime = TimeOfDay(
                      hour: newDuration.inHours,
                      minute: newDuration.inMinutes % 60,
                    );
                    _validateForm();
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('決定'),
            ),
          ],
        ),
      ),
    );
  }

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
    final DateTime? combinedDateTime = getCombinedDateTime();
    if (combinedDateTime == null) return;

    final conn = await DatabaseHelper.connect();
    final eventDAO = EventDAO(conn);

    final event = Event(
      userId: 1, // 仮のユーザーID
      eventName: eventNameController.text,
      unitName: unitNameController.text,
      eventDate: combinedDateTime,
      eventText: eventTextController.text,
      eventPlace: eventPlaceController.text,
      organizerName: organizerNameController.text,
    );

    try {
      await eventDAO.insertEvent(event);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => EventListPage()),
      );
    } catch (e) {
      print("登録エラー: $e");
    } finally {
      await conn.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(title: '新規イベント追加'),
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
                controller: organizerNameController,
                decoration: InputDecoration(labelText: '主催者名'),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    eventDate == null
                        ? '日付を選択してください'
                        : '開催日時: ${DateFormat('yyyy年MM月dd日', 'ja').format(eventDate!)}',
                  ),
                  ElevatedButton(
                    onPressed: _pickEventDate,
                    child: Icon(Icons.calendar_today),
                  ),
                ],
              ),
              Divider(),
              SizedBox(height: 20),
              Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    Text(
      eventTime == null
          ? '時間を選択してください'
          : '${eventTime!.hour.toString()}時 ${eventTime!.minute.toString()}分',
    ),
    ElevatedButton(
      onPressed: () async {
        await _showTimePicker(context);
      },
      child: Icon(Icons.access_time),
    ),
  ],
),

              Divider(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isFormValid ? _submitForm : null,
                child: Text('登録'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppFooter(), // フッターの追加
    );
  }
}
