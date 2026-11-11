import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/chat.dart';
import '../models/fighter.dart';

class ChatConversationScreen extends StatefulWidget {
  final ChatThread thread;

  const ChatConversationScreen({
    super.key,
    required this.thread,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final String _chatDocId;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? 'current_user';
    final participants = [_currentUserId!, widget.thread.opponent.id]..sort();
    _chatDocId = 'chat_${participants[0]}_${participants[1]}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatDateTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final myUid = _currentUserId ?? 'current_user';
    _messageController.clear();

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(_chatDocId)
          .collection('messages')
          .add({
        'senderId': myUid,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('chats').doc(_chatDocId).set({
        'participants': [myUid, widget.thread.opponent.id],
        'lastMessage': text,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      setState(() {
        widget.thread.messages.add(
          ChatMessage(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
            senderId: myUid,
            text: text,
            timestamp: DateTime.now(),
            isFromMe: true,
          ),
        );
      });
      activeChatThreadsNotifier.value = List.from(activeChatThreadsNotifier.value);
    }

    _scrollToBottom();
  }

  void _confirmBout() {
    if (widget.thread.isConfirmedMatchup) return;

    final currentAuthUser = FirebaseAuth.instance.currentUser;
    final currentUserName = currentAuthUser?.displayName ??
        (currentAuthUser?.email?.split('@').first ?? 'You');

    setState(() {
      widget.thread.isConfirmedMatchup = true;

      final currentUserFighter = Fighter(
        id: currentAuthUser?.uid ?? 'current_user',
        name: currentUserName,
        age: 24,
        heightInches: 70,
        weightLbs: 160.0,
        bio: 'Contender ready for bout action.',
        signatureMove: 'Cross Hook',
        powerRating: 85,
        record: '0-0-0',
      );

      final matchupId = 'bout_${widget.thread.id}';
      final currentMatchups = List<Matchup>.from(matchupsNotifier.value);

      if (!currentMatchups.any((m) => m.id == matchupId)) {
        currentMatchups.add(
          Matchup(
            id: matchupId,
            fighterA: currentUserFighter,
            fighterB: widget.thread.opponent,
            votesA: 0,
            votesB: 0,
          ),
        );
        matchupsNotifier.value = currentMatchups;
      }

      activeChatThreadsNotifier.value = List.from(activeChatThreadsNotifier.value);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('BOUT CONFIRMED! Added to Arena Voting.'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final opponent = widget.thread.opponent;
    final styleColor = opponent.style?.themeColor ?? const Color(0xFF1C1B1F);
    final myUid = _currentUserId ?? 'current_user';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1B1F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: styleColor.withValues(alpha: 0.15),
              child: Icon(
                opponent.style?.icon ?? Icons.sports_mma,
                color: styleColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    opponent.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1C1B1F),
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${opponent.style?.label ?? "Striker"} • ${opponent.record}',
                    style: const TextStyle(
                      color: Color(0xFF79747E),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: widget.thread.isConfirmedMatchup
                ? Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'BOUT SET',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  )
                : TextButton.icon(
                    onPressed: _confirmBout,
                    icon: const Icon(Icons.sports_mma, size: 16),
                    label: const Text(
                      'CONFIRM BOUT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1C1B1F),
                      backgroundColor: const Color(0xFFE2DDD5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(_chatDocId)
                    .collection('messages')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    if (widget.thread.messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              opponent.style?.icon ?? Icons.sports_mma,
                              size: 40,
                              color: const Color(0xFF79747E),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Chat started with ${opponent.name}',
                              style: const TextStyle(
                                color: Color(0xFF1C1B1F),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Coordinate sparring rules, gym location, and round duration.',
                              style: TextStyle(
                                color: Color(0xFF79747E),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.thread.messages.length,
                      itemBuilder: (context, index) {
                        final msg = widget.thread.messages[index];
                        return _buildBubble(
                          text: msg.text,
                          timeText: _formatDateTime(msg.timestamp),
                          isMe: msg.isFromMe,
                        );
                      },
                    );
                  }

                  final docs = snapshot.data!.docs;
                  WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final senderId = data['senderId'] as String? ?? '';
                      final text = data['text'] as String? ?? '';
                      final ts = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                      final isMe = senderId == myUid;

                      return _buildBubble(
                        text: text,
                        timeText: _formatDateTime(ts),
                        isMe: isMe,
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE2DDD5)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Message ${opponent.name}...',
                        hintStyle: const TextStyle(color: Color(0xFF79747E), fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFFD0C9BF)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFFD0C9BF)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFF1C1B1F), width: 1.5),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF7F5F0),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF1C1B1F)),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble({
    required String text,
    required String timeText,
    required bool isMe,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF1C1B1F) : Colors.white,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
            bottomLeft: !isMe ? const Radius.circular(0) : const Radius.circular(16),
          ),
          border: isMe ? null : Border.all(color: const Color(0xFFE2DDD5)),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : const Color(0xFF1C1B1F),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              timeText,
              style: TextStyle(
                color: isMe ? Colors.white60 : const Color(0xFF79747E),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}