import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'data/sample_profiles.dart';
import 'firebase_options.dart';
import 'models/fighter.dart';
import 'screens/account_creation_attributes_screen.dart';
import 'services/username_auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MaterialApp(home: SampleDataCheck()));
}

class SampleDataCheck extends StatefulWidget {
  const SampleDataCheck({super.key});

  @override
  State<SampleDataCheck> createState() => _SampleDataCheckState();
}

class _SampleDataCheckState extends State<SampleDataCheck> {
  final _password = TextEditingController();

  int _selectedIndex = 0;
  bool _busy = false;
  String _status = 'Choose a sample and enter its test password.';

  Future<void> _run({required bool createAccount}) async {
    final password = _password.text;

    if (password.isEmpty) {
      setState(() => _status = 'Enter a test password first.');
      return;
    }

    setState(() {
      _busy = true;
      _status = 'Working...';
    });

    final sample = sampleProfiles[_selectedIndex];
    final username = sample['name'] as String;

    try {
      // Use this screen with dedicated sample accounts only.
      await FirebaseAuth.instance.signOut();

      if (createAccount) {
        await createFirebaseAccount(
          AccountCreationData(
            email: sample['email'] as String,
            username: username,
            fighterName: sample['fighterName'] as String,
            password: password,
            heightInches: sample['heightInches'] as int,
            weightLbs: sample['weightLbs'] as double,
            age: sample['age'] as int,
            style: FightStyle.values.byName(sample['style'] as String),
          ),
        );
      }

      await UsernameAuthService().signIn(username, password);

      final user = FirebaseAuth.instance.currentUser!;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get(const GetOptions(source: Source.server));

      final saved = snapshot.data();

      if (saved == null) {
        throw StateError('Account signed in, but its profile is missing.');
      }

      final mismatches = sample.keys
          .where((key) => saved[key] != sample[key])
          .toList();

      if (saved['id'] != user.uid) {
        mismatches.add('id');
      }

      if (mismatches.isNotEmpty) {
        throw StateError('Profile fields do not match: $mismatches');
      }
      if (username == 'demo_boxer') {
  const otherUserUid = 'hdyeiTH02nar1BOsIFRiTvuztUe2';

  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(otherUserUid)
        .get(const GetOptions(source: Source.server));
  } on FirebaseException catch (error) {
    if (error.code != 'permission-denied') {
      rethrow;
    }

    if (mounted) {
      setState(() {
        _status = 'PASS: Own profile matched, and access to '
            'another user’s private profile was denied.';
      });
    }
    return;
  }

  throw StateError(
    'Privacy check failed: another user’s profile was readable.',
  );
}

      if (mounted) {
        setState(() {
          _status = 'PASS: $username signed in and all sample fields '
              'matched the saved Firebase profile.\nUID: ${user.uid}';
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _status = 'FAIL: $error');
      }
    } finally {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {
        // A sign-out failure should not hide the original test result.
      }

      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sample account database check')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Creates dedicated test accounts in Fight Finder Dev. '
              'Use a test password, not a personal password. '
              'This screen signs out any existing session.',
            ),
            const SizedBox(height: 20),
            DropdownButton<int>(
              value: _selectedIndex,
              isExpanded: true,
              items: [
                for (int i = 0; i < sampleProfiles.length; i++)
                  DropdownMenuItem(
                    value: i,
                    child: Text(sampleProfiles[i]['name'] as String),
                  ),
              ],
              onChanged: _busy
                  ? null
                  : (value) => setState(() => _selectedIndex = value!),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              enabled: !_busy,
              decoration: const InputDecoration(
                labelText: 'Password for this sample account',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _busy ? null : () => _run(createAccount: true),
              child: const Text('Create sample account and verify'),
            ),
            OutlinedButton(
              onPressed: _busy ? null : () => _run(createAccount: false),
              child: const Text('Sign in to existing sample and verify'),
            ),
            const SizedBox(height: 20),
            SelectableText(_status),
          ],
        ),
      ),
    );
  }
}