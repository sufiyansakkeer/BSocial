import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Chats'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Chat List Page - To be implemented'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(
                    '/chats/sample-chat-id?receiverId=sample-user-id&receiverName=John%20Doe'),
                child: const Text('Open Sample Chat'),
              ),
            ],
          ),
        ),
      );
}
