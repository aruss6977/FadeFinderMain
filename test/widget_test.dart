import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fade_finder/main.dart';
import 'package:fade_finder/screens/account_creation_attributes_screen.dart';
import 'package:fade_finder/screens/welcome_page.dart';

void main() {
  testWidgets('Welcome page opens before the app', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FadeFinderApp());

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('FadeFinder'), findsNothing);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('FadeFinder'), findsOneWidget);
  });

  testWidgets('Create Account opens a form and checks matching passwords',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FadeFinderApp());
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm password'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'test@example.com');
    await tester.enterText(fields.at(1), 'tester');
    await tester.enterText(fields.at(2), 'password123');
    await tester.enterText(fields.at(3), 'different');
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('Account details require a valid email and strong password',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FadeFinderApp());
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    expect(find.textContaining('Use a valid email address'), findsOneWidget);
    expect(find.textContaining('At least 8 characters'), findsOneWidget);

    await tester.enterText(fields.at(0), 'invalid-email');
    await tester.enterText(fields.at(1), 'tester');
    await tester.enterText(fields.at(2), 'weak');
    await tester.enterText(fields.at(3), 'weak');
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Password does not meet the requirements'), findsOneWidget);
    expect(find.text('Your Fighter Details'), findsNothing);

    await tester.enterText(fields.at(0), 'test@example.com');
    await tester.enterText(fields.at(2), 'Strong1!');
    await tester.enterText(fields.at(3), 'Strong1!');
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Your Fighter Details'), findsOneWidget);
    expect(find.text('Height (inches)'), findsOneWidget);
    expect(find.text('Weight (lbs)'), findsOneWidget);
    expect(find.text('Age'), findsOneWidget);
    expect(find.text('Fight style (optional)'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Enter a valid height in inches'), findsOneWidget);
    expect(find.text('Enter a valid weight in pounds'), findsOneWidget);
    expect(find.text('Enter a valid age'), findsOneWidget);
  });

  testWidgets('Completed profile returns to welcome with success popup',
      (WidgetTester tester) async {
    AccountCreationData? savedDetails;
    await tester.pumpWidget(MaterialApp(
      home: const WelcomePage(),
      routes: {
        '/create-account': (_) => AccountCreationAttributesScreen(
              email: 'test@example.com',
              username: 'tester',
              password: 'Strong1!',
              createAccount: (details) async {
                savedDetails = details;
              },
            ),
      },
    ));

    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), '70');
    await tester.enterText(fields.at(1), '155.5');
    await tester.enterText(fields.at(2), '25');
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(savedDetails?.heightInches, 70);
    expect(savedDetails?.weightLbs, 155.5);
    expect(savedDetails?.age, 25);
    expect(savedDetails?.style, isNull);
    expect(find.text('Account successfully created'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}