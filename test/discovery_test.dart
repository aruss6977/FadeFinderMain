import 'package:fade_finder/models/fighter.dart';
import 'package:fade_finder/services/discovery_repository.dart';
import 'package:fade_finder/screens/match_screen.dart';
import 'package:fade_finder/widgets/fighter_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDiscoveryRepository implements DiscoveryRepository {
  _FakeDiscoveryRepository(this.data);
  final DiscoveryData data;
  final List<String> savedSwipes = [];

  @override
  Future<DiscoveryData> load() async => data;
  @override
  Future<List<Fighter>> allFighters() async => data.fighters;
  @override
  Future<void> recordSwipe(String fighterId) async {
    savedSwipes.add(fighterId);
  }

  @override
  Future<void> undoSwipe(String fighterId) async {
    savedSwipes.remove(fighterId);
  }
}

void main() {
  const self = Fighter(
    id: 'self',
    name: 'Self',
    age: 25,
    heightInches: 70,
    weightLbs: 150,
  );
  const sameClass = Fighter(
    id: 'same',
    name: 'Same',
    age: 26,
    heightInches: 69,
    weightLbs: 154,
    style: FightStyle.boxing,
  );
  const wrestler = Fighter(
    id: 'wrestler',
    name: 'Grappler',
    age: 24,
    heightInches: 68,
    weightLbs: 152,
    style: FightStyle.wrestling,
  );
  const swiped = Fighter(
    id: 'swiped',
    name: 'Swiped',
    age: 28,
    heightInches: 71,
    weightLbs: 155,
  );
  const otherClass = Fighter(
    id: 'other',
    name: 'Other',
    age: 28,
    heightInches: 71,
    weightLbs: 170,
  );

  test(
    'discovery only offers unswiped accounts in the signed-in weight class',
    () {
      final data = DiscoveryData(
        currentUserId: 'self',
        weightClass: WeightClass.lightweight,
        fighters: [self, sameClass, swiped, otherClass],
        swipedIds: {'swiped'},
      );
      expect(data.available(null).map((f) => f.id), ['same']);
      expect(data.available(FightStyle.boxing).map((f) => f.id), ['same']);
      expect(data.available(FightStyle.mma), isEmpty);
      expect(
        DiscoveryData(
          currentUserId: 'self',
          weightClass: WeightClass.lightweight,
          fighters: data.fighters,
          swipedIds: {'swiped', 'same'},
        ).available(null),
        isEmpty,
      );
    },
  );

  testWidgets('user document card omits email and username', (tester) async {
    final fighter = fighterFromUserData({
      'fighterName': 'Ace',
      'name': 'private_username',
      'email': 'shared@example.com',
      'age': 25,
      'heightInches': 70,
      'weightLbs': 155.0,
      'style': 'boxing',
    }, 'uid-1');
    expect(fighter, isNotNull);
    expect(fighter!.name, 'Ace');
    expect(fighter.weightClass, WeightClass.lightweight);
    expect(fighter.style, FightStyle.boxing);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: FighterCard(fighter: fighter)),
    ));
    expect(find.text('ACE'), findsOneWidget);
    expect(find.textContaining('shared@example.com'), findsNothing);
    expect(find.textContaining('private_username'), findsNothing);
  });

  testWidgets('discovery shows the requested notice when no fighters remain', (
    tester,
  ) async {
    final repository = _FakeDiscoveryRepository(
      const DiscoveryData(
        currentUserId: 'self',
        weightClass: WeightClass.lightweight,
        fighters: [self, otherClass],
        swipedIds: {},
      ),
    );
    await tester.pumpWidget(
      MaterialApp(home: MatchScreen(repository: repository)),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('there are no more users who want to catch a fade'),
      findsOneWidget,
    );
    expect(find.text('Other'), findsNothing);
  });

  testWidgets('a saved swipe removes a fighter from discovery', (tester) async {
    final repository = _FakeDiscoveryRepository(
      const DiscoveryData(
        currentUserId: 'self',
        weightClass: WeightClass.lightweight,
        fighters: [self, sameClass],
        swipedIds: {},
      ),
    );
    await tester.pumpWidget(
      MaterialApp(home: MatchScreen(repository: repository)),
    );
    await tester.pumpAndSettle();
    expect(find.text('SAME'), findsOneWidget);
    await tester.tap(find.text('PASS'));
    await tester.pumpAndSettle();
    expect(repository.savedSwipes, ['same']);
    expect(
      find.text('there are no more users who want to catch a fade'),
      findsOneWidget,
    );
  });

  testWidgets('style filter chips filter fighters on match screen', (
    tester,
  ) async {
    final repository = _FakeDiscoveryRepository(
      const DiscoveryData(
        currentUserId: 'self',
        weightClass: WeightClass.lightweight,
        fighters: [self, wrestler, sameClass],
        swipedIds: {},
      ),
    );
    await tester.pumpWidget(
      MaterialApp(home: MatchScreen(repository: repository)),
    );
    await tester.pumpAndSettle();

    expect(find.text('GRAPPLER'), findsOneWidget);

    await tester.tap(find.text('Boxing'));
    await tester.pumpAndSettle();
    expect(find.text('GRAPPLER'), findsNothing);
    expect(find.text('SAME'), findsOneWidget);

    await tester.tap(find.text('All styles'));
    await tester.pumpAndSettle();
    expect(find.text('GRAPPLER'), findsOneWidget);
  });
}