import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/fighter.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> saveProfile({
    required String name,
    required int age,
    required int heightInches,
    required double weightLbs,
    required FightStyle style,
    String bio = '',
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('Sign in before saving a profile.');
    }

    if (name.trim().isEmpty ||
        age <= 0 ||
        heightInches <= 0 ||
        !weightLbs.isFinite ||
        weightLbs <= 0) {
      throw ArgumentError('Enter valid profile information.');
    }

    final reference = _db.collection('users').doc(user.uid);

    await _db.runTransaction((transaction) async {
      final existing = await transaction.get(reference);

      transaction.set(
        reference,
        {
          'name': name.trim(),
          'age': age,
          'heightInches': heightInches,
          'weightLbs': weightLbs,
          'style': style.name,
          'bio': bio.trim(),
          if (!existing.exists)
            'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    });
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<Map<String, dynamic>?> getMyProfile() async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final snapshot =
        await _db.collection('users').doc(user.uid).get();

    return snapshot.data();
  }

  Future<void> signOut() {
    return _auth.signOut();
  }
}