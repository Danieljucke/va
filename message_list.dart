import 'package:antmap_mvp/models/chat.dart';
import 'package:antmap_mvp/widgets/chat/message_item.dart';
import 'package:flutter/material.dart';

class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;
  final bool isDarkMode;
  final bool isGroupChat;
  final Function(ChatMessage) onMessageAction;

  const MessageList({
    Key? key,
    required this.messages,
    required this.isDarkMode,
    required this.isGroupChat,
    required this.onMessageAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
      itemCount: messages.length + 1, // +1 pour le séparateur "today"
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildDateSeparator();
        }
        
        final messageIndex = index - 1;
        return MessageItem(
          message: messages[messageIndex],
          isDarkMode: isDarkMode,
          isGroupChat: isGroupChat,
          onMessageAction: onMessageAction,
        );
      },
    );
  }

  Widget _buildDateSeparator() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10.0),
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: const Text(
          "today",
          style: TextStyle(
            color: Colors.black54,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }
}
