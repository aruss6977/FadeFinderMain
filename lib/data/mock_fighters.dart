import 'package:flutter/foundation.dart';
import '../models/chat.dart';
import '../models/fighter.dart';

// global in-memory ledger tracking sparring challenges issued during swipe sessions
final List<Fighter> activeChallenges = [];

// reactive ledger tracking active chat conversations
final ValueNotifier<List<ChatThread>> activeChatThreadsNotifier = ValueNotifier<List<ChatThread>>([]);
List<ChatThread> get activeChatThreads => activeChatThreadsNotifier.value;

// reactive ledger tracking arena matchups
final ValueNotifier<List<Matchup>> matchupsNotifier = ValueNotifier<List<Matchup>>([]);
List<Matchup> get mockMatchups => matchupsNotifier.value;

// helper to locate an existing thread or create an empty one
ChatThread getOrCreateChatThread(Fighter opponent) {
  final currentList = List<ChatThread>.from(activeChatThreadsNotifier.value);
  final existingIndex = currentList.indexWhere((t) => t.opponent.id == opponent.id);
  
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

// empty mock catalogs
final List<Fighter> mockFighters = [];