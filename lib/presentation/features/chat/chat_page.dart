import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
    super.key,
  });
  final String chatId;
  final String receiverId;
  final String receiverName;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(receiverName),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Chat Page - To be implemented'),
              const SizedBox(height: 8),
              Text('Chat ID: $chatId'),
              Text('Receiver ID: $receiverId'),
            ],
          ),
        ),
      );
}
