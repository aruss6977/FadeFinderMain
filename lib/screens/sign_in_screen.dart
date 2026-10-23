import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/username_auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, this.signIn, this.signInWithEmail});

  final Future<void> Function(String username, String password)? signIn;
  final Future<void> Function(String email, String password)? signInWithEmail;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSigningIn = false;
  bool _useEmail = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSigningIn || !_formKey.currentState!.validate()) return;
    setState(() {
      _isSigningIn = true;
      _error = null;
    });
    try {
      if (_useEmail) {
        await (widget.signInWithEmail ?? UsernameAuthService().signInWithEmail)(
          _usernameController.text,
          _passwordController.text,
        );
      } else {
        await (widget.signIn ?? UsernameAuthService().signIn)(
          _usernameController.text,
          _passwordController.text,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/app');
    } on UsernameSignInException catch (error) {
      setState(() => _error = error.message);
    } on FirebaseAuthException catch (error) {
      setState(() => _error = switch (error.code) {
            'too-many-requests' => 'Too many attempts. Try again later.',
            'network-request-failed' => 'Check your connection and try again.',
            _ => 'Invalid username or password.',
          });
    } on FirebaseException catch (_) {
      setState(() => _error = 'Could not sign in. Check your connection.');
    } catch (_) {
      setState(() => _error = 'Could not sign in. Please try again.');
    } finally {
      if (mounted) setState(() => _isSigningIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _usernameController,
                    style: const TextStyle(color: Colors.white),
                    autofillHints: _useEmail
                        ? const [AutofillHints.email]
                        : const [AutofillHints.username],
                    keyboardType: _useEmail
                        ? TextInputType.emailAddress
                        : TextInputType.text,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: _useEmail ? 'Email address' : 'Username',
                      labelStyle: const TextStyle(color: Colors.white70),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? _useEmail ? 'Enter your email address' : 'Enter your username'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.white),
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white70),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter your password'
                        : null,
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                  ],
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _isSigningIn ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(_isSigningIn ? 'Signing in...' : 'Sign In'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _isSigningIn
                        ? null
                        : () {
                            setState(() {
                              _useEmail = !_useEmail;
                              _usernameController.clear();
                              _error = null;
                            });
                          },
                    child: Text(_useEmail
                        ? 'Use username instead'
                        : 'Older account? Sign in with email'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
