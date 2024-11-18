import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '募集登録画面',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const EventRegistrationPage(),
    );
  }
}

class EventRegistrationPage extends StatefulWidget {
  const EventRegistrationPage({super.key});

  @override
  State<EventRegistrationPage> createState() => _EventRegistrationPageState();
}

class _EventRegistrationPageState extends State<EventRegistrationPage> {
  DateTime? _selectedDate;

  // 日付選択の関数
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('募集登録画面'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
          const CircleAvatar(
            backgroundImage: NetworkImage(
              'https://t4.ftcdn.net/jpg/08/06/04/79/360_F_806047935_iuOOKCJXQVFl2MrSfMhXNPDOK9T8yNjn.jpg', // プロフィール画像の URL
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTextField('イベント名'),
              const SizedBox(height: 16),
              buildTextField('アーティスト'),
              const SizedBox(height: 16),
              buildTextField('主催者'),
              const SizedBox(height: 16),
              const Text('イベント開催日:'),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: _selectedDate == null
                          ? '年/月/日'
                          : '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}',
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('時間:'),
              DropdownButtonFormField<String>(
                items: ['時間を選択'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {},
                decoration: const InputDecoration(
                  hintText: '時間を選択',
                ),
              ),
              const SizedBox(height: 16),
              const Text('タグ:'),
              DropdownButtonFormField<String>(
                items: ['タグを選択する'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {},
                decoration: const InputDecoration(
                  hintText: 'タグを選択する',
                ),
              ),
              const SizedBox(height: 16),
              buildTextField('会場名'),
              const SizedBox(height: 16),
              const Text('イベント詳細:'),
              TextField(
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'イベントの詳細を入力',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                  ),
                  child: const Text('登録'),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: '同行者',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.airplane_ticket),
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

  Widget buildTextField(String labelText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$labelText :'),
        const SizedBox(height: 8),
        TextField(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
