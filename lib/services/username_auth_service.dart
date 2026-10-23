import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Auth needs a unique email for each password account. New accounts
/// use an internal address derived from the username; the contact email stays
/// in the user's Firestore profile.
String normalizedUsername(String username) => username.trim().toLowerCase();

bool isValidUsername(String username) =>
    RegExp(r'^[a-z0-9_]{3,24}$').hasMatch(normalizedUsername(username));

String authEmailForUsername(String username) {
  final key = normalizedUsername(username);
  if (!isValidUsername(key)) {
    throw ArgumentError.value(username, 'username', 'Invalid username');
  }
  return '$key@accounts.fadefinder.example';
}

class UsernameSignInException implements Exception {
  const UsernameSignInException(this.message);

  final String message;
}

class UsernameAuthService {
  UsernameAuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Future<void> signIn(String username, String password) async {
    if (!isValidUsername(username) || password.isEmpty) {
      throw const UsernameSignInException('Invalid username or password.');
    }
    try {
      await _auth.signInWithEmailAndPassword(
        email: authEmailForUsername(username),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      if (_isInvalidCredential(error.code)) {
        throw const UsernameSignInException('Invalid username or password.');
      }
      rethrow;
    }
  }

  /// Older accounts were created with their contact email in Firebase Auth.
  /// They can use this path without a public Firestore username lookup.
  Future<void> signInWithEmail(String email, String password) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const UsernameSignInException('Invalid email or password.');
    }
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      if (_isInvalidCredential(error.code)) {
        throw const UsernameSignInException('Invalid email or password.');
      }
      rethrow;
    }
  }

  bool _isInvalidCredential(String code) =>
      code == 'user-not-found' ||
      code == 'invalid-credential' ||
      code == 'wrong-password' ||
      code == 'invalid-email';
}
