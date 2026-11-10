import 'package:flutter/foundation.dart';
import '../models/chat.dart';
import '../models/fighter.dart';

// Re-export activeChallenges from challenge_state for compatibility
export 'challenge_state.dart';

// Reactive ledger tracking active chat threads
final ValueNotifier<List<ChatThread>> activeChatThreadsNotifier =
    ValueNotifier<List<ChatThread>>([]);
List<ChatThread> get activeChatThreads => activeChatThreadsNotifier.value;

// Reactive ledger tracking arena matchups
final ValueNotifier<List<Matchup>> matchupsNotifier =
    ValueNotifier<List<Matchup>>([]);
List<Matchup> get activeMatchups => matchupsNotifier.value;

// Helper to locate an existing thread or create an empty one
ChatThread getOrCreateChatThread(Fighter opponent) {
  final currentList = List<ChatThread>.from(activeChatThreadsNotifier.value);
  final existingIndex =
      currentList.indexWhere((t) => t.opponent.id == opponent.id);

  if (existingIndex != -1) {
    return currentList[existingIndex];
  }

  final newThread = ChatThread(
    id: 'chat_${opponent.id}',
    opponent: opponent,
    messages: [],
  );
  currentList.add(newThread);
  activeChatThreadsNotifier.value = currentList;
  return newThread;
}