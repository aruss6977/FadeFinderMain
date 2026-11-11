import 'package:fade_finder/models/fighter.dart';
import 'package:fade_finder/screens/edit_profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final profile = <String, dynamic>{
    'email': 'shared@example.com',
    'name': 'alice_1',
    'fighterName': 'Alice Ace Rivera',
    'heightInches': 70,
    'weightLbs': 155.0,
    'age': 27,
    'style': 'boxing',
  };

  testWidgets('profile changes wait for confirmation and save the new weight', (
    tester,
  ) async {
    ProfileChanges? saved;
    await tester.pumpWidget(
      MaterialApp(
        home: EditProfileScreen(
          profile: profile,
          onSave: (changes) async => saved = changes,
          onVerifyOldPassword: (_) async {},
          onUpdatePassword: (_) async {},
        ),
      ),
    );

    expect(find.text('shared@example.com'), findsOneWidget);
    expect(find.text('alice_1'), findsOneWidget);
    expect(find.byKey(const Key('confirm-profile-changes')), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Weight (lbs)'),
      '170',
    );
    await tester.pump();
    expect(saved, isNull);
    final confirm = find.byKey(const Key('confirm-profile-changes'));
    expect(confirm, findsOneWidget);
    await tester.ensureVisible(confirm);
    await tester.tap(confirm);
    await tester.pumpAndSettle();

    expect(saved?.weightLbs, 170);
    expect(WeightClass.fromWeight(saved!.weightLbs), WeightClass.welterweight);
    expect(saved?.fighterName, 'Alice Ace Rivera');
  });

  testWidgets(
    'password changes require the old and a qualifying new password',
    (tester) async {
      String? updatedPassword;
      var checks = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: EditProfileScreen(
            profile: profile,
            onSave: (_) async {},
            onVerifyOldPassword: (password) async {
              checks++;
              if (password != 'OldStrong1!') {
                throw FirebaseAuthException(code: 'wrong-password');
              }
            },
            onUpdatePassword: (password) async => updatedPassword = password,
          ),
        ),
      );

      await tester.ensureVisible(find.text('Change password'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Change password'));
      await tester.pumpAndSettle();
      expect(find.text('Old password'), findsOneWidget);
      expect(find.text('New password'), findsNothing);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Old password'),
        'wrong',
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Old password is incorrect.'), findsOneWidget);
      expect(updatedPassword, isNull);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Old password'),
        'OldStrong1!',
      );
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(checks, 2);
      expect(find.text('New password'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'New password'),
        'weak',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm new password'),
        'weak',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
      await tester.pump();
      expect(
        find.text('Password does not meet the requirements'),
        findsOneWidget,
      );
      expect(updatedPassword, isNull);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'New password'),
        'NewStrong1!',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
      await tester.pump();
      expect(find.text('Passwords do not match'), findsOneWidget);
      expect(updatedPassword, isNull);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm new password'),
        'NewStrong1!',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Change password'));
      await tester.pumpAndSettle();
      expect(updatedPassword, isNull);
      final confirm = find.byKey(const Key('confirm-profile-changes'));
      expect(confirm, findsOneWidget);
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(updatedPassword, 'NewStrong1!');
      expect(checks, 3);
      expect(find.byKey(const Key('confirm-profile-changes')), findsNothing);
    },
  );
}
