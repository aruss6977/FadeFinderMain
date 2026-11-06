import 'fighter.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isFromMe;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isFromMe = true,
  });
}

class ChatThread {
  final String id;
  final Fighter opponent;
  final List<ChatMessage> messages;
  bool isConfirmedMatchup;

  ChatThread({
    required this.id,
    required this.opponent,
    List<ChatMessage>? messages,
    this.isConfirmedMatchup = false,
  }) : messages = messages ?? [];

  String get lastMessagePreview {
    if (messages.isEmpty) return 'No messages yet';
    return messages.last.text;
  }

  String get lastMessageTime {
    if (messages.isEmpty) return '';
    final dt = messages.last.timestamp;
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }
}