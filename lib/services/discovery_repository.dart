import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/account_profile.dart';
import '../models/fighter.dart';

// Build only the fields shown on fighter cards. Contact email and username
// are deliberately never copied into the UI model.
Fighter? fighterFromUserData(Map<String, dynamic> data, String uid) {
  final profile = AccountProfile.fromMap(data);
  if (profile.fighterName.isEmpty ||
      profile.age == null ||
      profile.heightInches == null ||
      profile.weightLbs == null) {
    return null;
  }
  return Fighter(
    id: uid,
    name: profile.fighterName,
    age: profile.age!,
    heightInches: profile.heightInches!,
    weightLbs: profile.weightLbs!,
    style: profile.style,
    record: '0-0-0',
    signatureMove: 'None',
  );
}

class DiscoveryData {
  const DiscoveryData({
    required this.currentUserId,
    required this.weightClass,
    required this.fighters,
    required this.swipedIds,
  });

  final String currentUserId;
  final WeightClass weightClass;
  final List<Fighter> fighters;
  final Set<String> swipedIds;

  List<Fighter> available(FightStyle? style) => fighters
      .where((fighter) => fighter.id != currentUserId)
      .where((fighter) => fighter.weightClass == weightClass)
      .where((fighter) => !swipedIds.contains(fighter.id))
      .where((fighter) => style == null || fighter.style == style)
      .toList();
}

abstract class DiscoveryRepository {
  Future<DiscoveryData> load();
  Future<List<Fighter>> allFighters();
  Future<void> recordSwipe(String fighterId);
  Future<void> undoSwipe(String fighterId);
}

class FirebaseDiscoveryRepository implements DiscoveryRepository {
  FirebaseDiscoveryRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<List<Fighter>> allFighters() async {
    final results = await _firestore.collection('users').get();
    return results.docs
        .map((document) => fighterFromUserData(document.data(), document.id))
        .whereType<Fighter>()
        .toList();
  }

  User get _user {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Sign in to discover fighters.');
    return user;
  }

  @override
  Future<DiscoveryData> load() async {
    final user = _user;
    final ownDocument = _firestore.collection('users').doc(user.uid);
    final ownSnapshot = await ownDocument.get();
    final ownData = ownSnapshot.data();
    if (ownData == null) {
      throw StateError('Your fighter profile was not found.');
    }
    final profile = AccountProfile.fromMap(ownData);
    final weight = profile.weightLbs;
    if (weight == null || weight <= 0) {
      throw StateError('Add your weight to your fighter profile.');
    }
    final weightClass = WeightClass.fromWeight(weight);

    final results = await _firestore.collection('users').get();
    final fighters = <Fighter>[];
    for (final document in results.docs) {
      final fighter = fighterFromUserData(document.data(), document.id);
      if (fighter != null && fighter.weightClass == weightClass) {
        fighters.add(fighter);
      }
    }

    final swipedIds =
        (ownData['swipedUserIds'] as List?)?.whereType<String>().toSet() ??
        <String>{};
    return DiscoveryData(
      currentUserId: user.uid,
      weightClass: weightClass,
      fighters: fighters,
      swipedIds: swipedIds,
    );
  }

  @override
  Future<void> recordSwipe(String fighterId) =>
      _firestore.collection('users').doc(_user.uid).update({
        'swipedUserIds': FieldValue.arrayUnion([fighterId]),
      });

  @override
  Future<void> undoSwipe(String fighterId) =>
      _firestore.collection('users').doc(_user.uid).update({
        'swipedUserIds': FieldValue.arrayRemove([fighterId]),
      });
}
