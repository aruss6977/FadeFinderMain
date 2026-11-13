import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/fighter.dart';
import '../services/username_auth_service.dart';

class ProfileChanges {
  const ProfileChanges({
    required this.fighterName,
    required this.heightInches,
    required this.weightLbs,
    required this.age,
    required this.style,
  });

  final String fighterName;
  final int heightInches;
  final double weightLbs;
  final int age;
  final FightStyle? style;
}

class _PendingPasswordChange {
  const _PendingPasswordChange(this.oldPassword, this.newPassword);

  final String oldPassword;
  final String newPassword;
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.profile,
    required this.onSave,
    required this.onVerifyOldPassword,
    required this.onUpdatePassword,
  });

  final Map<String, dynamic> profile;
  final Future<void> Function(ProfileChanges) onSave;
  final Future<void> Function(String) onVerifyOldPassword;
  final Future<void> Function(String) onUpdatePassword;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _height;
  late final TextEditingController _weight;
  late final TextEditingController _age;
  FightStyle? _style;
  FightStyle? _originalStyle;
  _PendingPasswordChange? _pendingPassword;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final data = widget.profile;
    _name = TextEditingController(text: data['fighterName'] as String? ?? '');
    _height = TextEditingController(text: '${data['heightInches'] ?? ''}');
    _weight = TextEditingController(text: '${data['weightLbs'] ?? ''}');
    _age = TextEditingController(text: '${data['age'] ?? ''}');
    for (final candidate in FightStyle.values) {
      if (candidate.name == data['style']) {
        _style = candidate;
        break;
      }
    }
    _originalStyle = _style;
    for (final controller in [_name, _height, _weight, _age]) {
      controller.addListener(_refresh);
    }
  }

  void _refresh() => setState(() {});

  bool get _profileHasChanges {
    final data = widget.profile;
    return _name.text.trim() != (data['fighterName'] as String? ?? '') ||
        int.tryParse(_height.text.trim()) !=
            (data['heightInches'] as num?)?.toInt() ||
        double.tryParse(_weight.text.trim()) !=
            (data['weightLbs'] as num?)?.toDouble() ||
        int.tryParse(_age.text.trim()) != (data['age'] as num?)?.toInt() ||
        _style != _originalStyle;
  }

  bool get _hasChanges => _profileHasChanges || _pendingPassword != null;

  @override
  void dispose() {
    _name.dispose();
    _height.dispose();
    _weight.dispose();
    _age.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    var passwordUpdated = false;
    try {
      final passwordChange = _pendingPassword;
      if (passwordChange != null) {
        await widget.onVerifyOldPassword(passwordChange.oldPassword);
        await widget.onUpdatePassword(passwordChange.newPassword);
        passwordUpdated = true;
      }
      if (_profileHasChanges) {
        await widget.onSave(
          ProfileChanges(
            fighterName: _name.text.trim(),
            heightInches: int.parse(_height.text.trim()),
            weightLbs: double.parse(_weight.text.trim()),
            age: int.parse(_age.text.trim()),
            style: _style,
          ),
        );
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        if (passwordUpdated) setState(() => _pendingPassword = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              passwordUpdated
                  ? 'Password updated, but profile details were not saved: $error'
                  : 'Could not save changes: $error',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _changePassword() async {
    final pending = await showDialog<_PendingPasswordChange>(
      context: context,
      builder: (_) => _PasswordChangeDialog(
        onVerifyOldPassword: widget.onVerifyOldPassword,
      ),
    );
    if (pending != null && mounted) setState(() => _pendingPassword = pending);
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.profile;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      bottomNavigationBar: _hasChanges
          ? SafeArea(
              minimum: const EdgeInsets.all(16),
              child: FilledButton(
                key: const Key('confirm-profile-changes'),
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving...' : 'Confirm changes'),
              ),
            )
          : null,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ListTile(
                title: const Text('Email address'),
                subtitle: Text(data['email'] as String? ?? 'Not provided'),
              ),
              ListTile(
                title: const Text('Username'),
                subtitle: Text(data['name'] as String? ?? 'Not provided'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Fighter name'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter your fighter name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _height,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Height (inches)'),
                validator: (value) {
                  final height = int.tryParse(value?.trim() ?? '');
                  return height == null || height <= 0
                      ? 'Enter a valid height in inches'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weight,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Weight (lbs)'),
                validator: (value) {
                  final weight = double.tryParse(value?.trim() ?? '');
                  return weight == null || !weight.isFinite || weight <= 0
                      ? 'Enter a valid weight in pounds'
                      : null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _age,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age'),
                validator: (value) {
                  final age = int.tryParse(value?.trim() ?? '');
                  return age == null || age <= 0 ? 'Enter a valid age' : null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<FightStyle>(
                initialValue: _style,
                decoration: const InputDecoration(
                  labelText: 'Fight style (optional)',
                ),
                items: [
                  const DropdownMenuItem<FightStyle>(
                    value: null,
                    child: Text('Unassigned'),
                  ),
                  ...FightStyle.values.map(
                    (style) => DropdownMenuItem(
                      value: style,
                      child: Text(style.label),
                    ),
                  ),
                ],
                onChanged: (style) => setState(() => _style = style),
              ),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('Password'),
                subtitle: Text(
                  _pendingPassword == null
                      ? '••••••••'
                      : 'New password ready to save',
                ),
                trailing: TextButton(
                  onPressed: _changePassword,
                  child: const Text('Change password'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordChangeDialog extends StatefulWidget {
  const _PasswordChangeDialog({required this.onVerifyOldPassword});

  final Future<void> Function(String) onVerifyOldPassword;

  @override
  State<_PasswordChangeDialog> createState() => _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends State<_PasswordChangeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _oldVerified = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (!_oldVerified) {
        await widget.onVerifyOldPassword(_oldPassword.text);
        if (mounted) setState(() => _oldVerified = true);
      } else {
        if (mounted) {
          Navigator.of(
            context,
          ).pop(_PendingPasswordChange(_oldPassword.text, _newPassword.text));
        }
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(
          () => _error =
              !_oldVerified &&
                  (error.code == 'wrong-password' ||
                      error.code == 'invalid-credential')
              ? 'Old password is incorrect.'
              : error.message ?? 'Could not change password. Please try again.',
        );
      }
    } catch (error) {
      if (mounted) setState(() => _error = 'Could not change password: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(_oldVerified ? 'Set a new password' : 'Confirm old password'),
    content: Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_oldVerified)
              TextFormField(
                controller: _oldPassword,
                autofocus: true,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Old password'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Enter your old password'
                    : null,
              )
            else ...[
              TextFormField(
                controller: _newPassword,
                autofocus: true,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New password'),
                validator: (value) => isQualifyingPassword(value ?? '')
                    ? null
                    : 'Password does not meet the requirements',
              ),
              const SizedBox(height: 8),
              const Text(
                'At least 8 characters, with lowercase, uppercase, number, and special character.',
              ),
              TextFormField(
                controller: _confirmPassword,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm new password',
                ),
                validator: (value) => value == _newPassword.text
                    ? null
                    : 'Passwords do not match',
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: _busy ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _busy ? null : _continue,
        child: Text(
          _busy
              ? 'Please wait...'
              : _oldVerified
              ? 'Change password'
              : 'Continue',
        ),
      ),
    ],
  );
}
