import 'package:flutter/material.dart';
import '../data/mock_fighters.dart';
import '../models/chat.dart';
import 'chat_conversation_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'SPARRING CHATS',
          style: TextStyle(
            color: Color(0xFF1C1B1F),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<ChatThread>>(
        valueListenable: activeChatThreadsNotifier,
        builder: (context, threads, _) {
          if (threads.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 48, color: Color(0xFF79747E)),
                  SizedBox(height: 12),
                  Text(
                    'NO ACTIVE CHATS',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1C1B1F)),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Swipe right on a teammate in Discover to coordinate sparring.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF79747E)),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: threads.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final thread = threads[index];
              final opponent = thread.opponent;
              final styleColor = opponent.style?.themeColor ?? const Color(0xFF1C1B1F);

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2DDD5)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: styleColor.withValues(alpha: 0.15),
                    child: Icon(opponent.style?.icon ?? Icons.sports_mma, color: styleColor, size: 20),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          opponent.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      Text(
                        thread.lastMessageTime,
                        style: const TextStyle(color: Color(0xFF79747E), fontSize: 10),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        if (thread.isConfirmedMatchup) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'BOUT SET',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            thread.lastMessagePreview,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(0xFF79747E), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 18, color: Color(0xFF79747E)),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatConversationScreen(thread: thread),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}