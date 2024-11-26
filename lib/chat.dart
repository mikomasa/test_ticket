import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_core/firebase_core.dart';

class ChatRoomApp extends StatelessWidget {
  const ChatRoomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Room'),
      ),
      body: const ChatRoom(),
    );
  }
}

class ChatRoom extends StatefulWidget {
  const ChatRoom({super.key});

  @override
  ChatRoomState createState() => ChatRoomState();
}

// 相手
class ChatRoomState extends State<ChatRoom> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: '1', firstName: 'User');
  final _other = const types.User(
    id: '2',
    firstName: "テスト",
    lastName: "太郎",
    imageUrl:
        "https://pbs.twimg.com/profile_images/1335856760972689408/Zeyo7jdq_bigger.jpg",
  );
  void createTestMessage() async {
  await FirestoreService().saveMessage(
    userId: 2, // 相手のID
    companion: 1, // 自分のID
    messageText: "テストメッセージ",
    messageDate: DateTime.now(),
  );
}

  @override
  void initState() {
    super.initState();
    _loadMessages(); // Firestoreからメッセージをロード
  }

  // Firestoreからメッセージをロード
  Future<void> _loadMessages() async {
    final messages = await FirestoreService().fetchMessages();

    for (var msg in messages) {
      final newMessage = types.TextMessage(
        author: msg['user_id'] == 1 ? _user : _other, // ユーザーを動的に判定
        createdAt: (msg['message_date'] as Timestamp).toDate().millisecondsSinceEpoch,
        id: randomString(),
        text: msg['message_text'],
      );

      _addMessage(newMessage);
    }
  }

  // メッセージ送信
  void _handleSendPressed(types.PartialText message) async {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: randomString(),
      text: message.text,
    );

    // Firestoreにメッセージを保存
    await FirestoreService().saveMessage(
      userId: int.parse(_user.id),
      companion: 123, // 募集IDを適切に設定
      messageText: message.text,
      messageDate: DateTime.now(),
    );
    

    _addMessage(textMessage);
  }
  

  // ランダムなIDを生成する関数
  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  // メッセージをリストに追加する関数
  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);// 新しいメッセージをリストの最初に追加
    });
    
  }

  @override
  Widget build(BuildContext context) {
    return Chat(
      user: _user,
      messages: _messages,
      showUserAvatars: true,
      showUserNames: true,
      onSendPressed: _handleSendPressed,
    );
  }
}

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveMessage({
    required int userId,
    required int companion,
    required String messageText,
    required DateTime messageDate,
  }) async {
    try {
      await _firestore.collection('messages').add({
        
        'user_id': userId,
        'companion': companion,
        'message_text': messageText,
        'message_date': Timestamp.fromDate(messageDate),
      });
      print('メッセージが保存されました');
    } catch (e) {
      print('エラー: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchMessages() async {
    try {
      final querySnapshot = await _firestore
          .collection('messages')
          .orderBy('message_date', descending: false)
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('エラー: $e');
      return [];
    }
  }
}