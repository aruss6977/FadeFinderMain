import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/fighter.dart';

class AccountCreationData {
  const AccountCreationData({
    required this.email,
    required this.username,
    required this.password,
    required this.heightInches,
    required this.weightLbs,
    required this.age,
    required this.style,
  });

  final String email;
  final String username;
  final String password;
  final int heightInches;
  final double weightLbs;
  final int age;
  final FightStyle? style;
}

Future<void> createFirebaseAccount(AccountCreationData details) async {
  final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: details.email,
    password: details.password,
  );
  final user = credential.user!;

  try {
    final profile = <String, Object>{
      'id': user.uid,
      'email': details.email,
      'name': details.username,
      'heightInches': details.heightInches,
      'weightLbs': details.weightLbs,
      'age': details.age,
      if (details.style != null) 'style': details.style!.name,
    };
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set(profile);
  } catch (_) {
    // Avoid keeping an account without its required profile.
    try {
      await user.delete();
    } catch (_) {}
    rethrow;
  }

  await FirebaseAuth.instance.signOut();
}

class AccountCreationAttributesScreen extends StatefulWidget {
  const AccountCreationAttributesScreen({
    super.key,
    required this.email,
    required this.username,
    required this.password,
    this.createAccount = createFirebaseAccount,
  });

  final String email;
  final String username;
  final String password;
  final Future<void> Function(AccountCreationData) createAccount;

  @override
  State<AccountCreationAttributesScreen> createState() =>
      _AccountCreationAttributesScreenState();
}

class _AccountCreationAttributesScreenState
    extends State<AccountCreationAttributesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  FightStyle? _fightStyle;
  bool _isSubmitting = false;

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 8)),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white70),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      await widget.createAccount(AccountCreationData(
        email: widget.email,
        username: widget.username,
        password: widget.password,
        heightInches: int.parse(_heightController.text.trim()),
        weightLbs: double.parse(_weightController.text.trim()),
        age: int.parse(_ageController.text.trim()),
        style: _fightStyle,
      ));
      if (!mounted) return;

      final navigator = Navigator.of(context);
      navigator.popUntil((route) => route.isFirst);
      showDialog<void>(
        context: navigator.context,
        builder: (context) => AlertDialog(
          content: const Text('Account successfully created'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on FirebaseAuthException catch (error) {
      debugPrint('Firebase Auth account creation failed: ${error.code}: ${error.message}');
      _showError('Account creation failed (${error.code}): ${error.message ?? 'Please try again.'}');
    } on FirebaseException catch (error) {
      debugPrint('Firebase profile save failed: ${error.code}: ${error.message}');
      final message = switch (error.code) {
        'permission-denied' =>
          'Firestore denied the profile save (permission-denied). Check the users collection security rules.',
        'not-found' || 'failed-precondition' =>
          'Cloud Firestore is not ready (${error.code}). Check that a database exists for this Firebase project.',
        'unavailable' =>
          'Cloud Firestore is unavailable. Check your connection and try again.',
        _ => 'Could not save profile (${error.code}): ${error.message ?? 'Please try again.'}',
      };
      _showError(message);
    } catch (error, stackTrace) {
      debugPrint('Unexpected account creation error: $error\n$stackTrace');
      _showError('Could not create account. Check the app log for details.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Your Fighter Details'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                TextFormField(
                  controller: _heightController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: _fieldDecoration('Height (inches)'),
                  validator: (value) {
                    final height = int.tryParse(value?.trim() ?? '');
                    return height == null || height <= 0
                        ? 'Enter a valid height in inches'
                        : null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _weightController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: _fieldDecoration('Weight (lbs)'),
                  validator: (value) {
                    final weight = double.tryParse(value?.trim() ?? '');
                    return weight == null || !weight.isFinite || weight <= 0
                        ? 'Enter a valid weight in pounds'
                        : null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _ageController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  decoration: _fieldDecoration('Age'),
                  validator: (value) {
                    final age = int.tryParse(value?.trim() ?? '');
                    return age == null || age <= 0 ? 'Enter a valid age' : null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<FightStyle>(
                  initialValue: _fightStyle,
                  dropdownColor: Colors.black,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration('Fight style (optional)'),
                  items: FightStyle.values
                      .map((style) => DropdownMenuItem(
                            value: style,
                            child: Text(style.label),
                          ))
                      .toList(),
                  onChanged: (style) => setState(() => _fightStyle = style),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(_isSubmitting ? 'Creating account...' : 'Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
