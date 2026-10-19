import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'models/fighter.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MaterialApp(home: FirebaseCheck()));
}

class FirebaseCheck extends StatefulWidget {
  const FirebaseCheck({super.key});

  @override
  State<FirebaseCheck> createState() => _FirebaseCheckState();
}

class _FirebaseCheckState extends State<FirebaseCheck> {
  final email = TextEditingController();
  final password = TextEditingController();
  final auth = AuthService();

  String status = 'Enter a test email and password.';
  bool busy = false;

  Future<void> runAction(
    Future<String> Function() action,
  ) async {
    setState(() {
      busy = true;
      status = 'Working...';
    });

    try {
      final result = await action();
      if (mounted) {
        setState(() => status = result);
      }
    } catch (error) {
      if (mounted) {
        setState(() => status = 'ERROR: $error');
      }
    } finally {
      if (mounted) {
        setState(() => busy = false);
      }
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firebase connection check')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Test email'),
            ),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Test password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: busy ? null : () => runAction(() async {
                final result = await auth.signUp(
                  email: email.text,
                  password: password.text,
                );
                return 'Account created: ${result.user!.uid}';
              }),
              child: const Text('1. Create account'),
            ),
            ElevatedButton(
              onPressed: busy ? null : () => runAction(() async {
                await auth.saveProfile(
                  name: 'Firebase Test User',
                  age: 22,
                  heightInches: 67,
                  weightLbs: 148.0,
                  style: FightStyle.boxing,
                );
                return 'Profile saved successfully.';
              }),
              child: const Text('2. Save test profile'),
            ),
            ElevatedButton(
              onPressed: busy ? null : () => runAction(() async {
                await auth.signOut();
                return 'Signed out.';
              }),
              child: const Text('3. Sign out'),
            ),
            ElevatedButton(
              onPressed: busy ? null : () => runAction(() async {
                await auth.signIn(
                  email: email.text,
                  password: password.text,
                );
                final profile = await auth.getMyProfile();
                return 'Signed in. Saved profile: $profile';
              }),
              child: const Text('4. Sign in and read profile'),
            ),
            const SizedBox(height: 20),
            SelectableText(status),
          ],
        ),
      ),
    );
  }
}