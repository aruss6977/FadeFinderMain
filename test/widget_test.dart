import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fade_finder/main.dart';
import 'package:fade_finder/screens/account_creation_attributes_screen.dart';
import 'package:fade_finder/screens/welcome_page.dart';
import 'package:fade_finder/screens/sign_in_screen.dart';
import 'package:fade_finder/screens/profile_screen.dart';
import 'package:fade_finder/widgets/fighter_card.dart';
import 'package:fade_finder/services/username_auth_service.dart';

void main() {
  testWidgets('Welcome page opens before the app', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const FadeFinderApp());

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('FadeFinder'), findsOneWidget);

    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Discover'), findsNothing);
  });

  test('Usernames map to distinct Auth identifiers', () {
    expect(authEmailForUsername(' Alice_1 '),
        authEmailForUsername('alice_1'));
    expect(authEmailForUsername('alice_1'),
        isNot(authEmailForUsername('alice_2')));
    expect(isValidUsername('a b'), isFalse);
  });

  testWidgets('Sign in only opens the app after authentication succeeds',
      (WidgetTester tester) async {
    var authenticated = false;
    await tester.pumpWidget(MaterialApp(
      home: SignInScreen(signIn: (username, password) async {
        expect(username, 'alice');
        if (password != 'Strong1!') {
          throw const UsernameSignInException('Invalid username or password.');
        }
        authenticated = true;
      }),
      routes: {'/app': (_) => const Scaffold(body: Text('Discover'))},
    ));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'alice');
    await tester.enterText(fields.at(1), 'wrong');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pumpAndSettle();
    expect(authenticated, isFalse);
    expect(find.text('Invalid username or password.'), findsOneWidget);
    expect(find.text('Discover'), findsNothing);

    await tester.enterText(fields.at(1), 'Strong1!');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pumpAndSettle();
    expect(authenticated, isTrue);
    expect(find.text('Discover'), findsOneWidget);
  });

  testWidgets('Older account can select email sign in without a database lookup',
      (WidgetTester tester) async {
    String? signedInEmail;
    await tester.pumpWidget(MaterialApp(
      home: SignInScreen(
        signInWithEmail: (email, password) async {
          signedInEmail = email;
          expect(password, 'Strong1!');
        },
      ),
      routes: {'/app': (_) => const Scaffold(body: Text('Discover'))},
    ));

    await tester.tap(find.text('Older account? Sign in with email'));
    await tester.pump();
    expect(find.text('Email address'), findsOneWidget);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'old@example.com');
    await tester.enterText(fields.at(1), 'Strong1!');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await tester.pumpAndSettle();

    expect(signedInEmail, 'old@example.com');
    expect(find.text('Discover'), findsOneWidget);
  });

  testWidgets('Profile shows the signed-in account details instead of mock data',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ProfileScreen(
        profileStream: Stream.value({
          'name': 'alice_1',
          'fighterName': 'Alice Ace Rivera',
          'email': 'shared@example.com',
          'age': 27,
          'heightInches': 70,
          'weightLbs': 155.5,
          'style': 'boxing',
        }),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(FighterCard), findsOneWidget);
    expect(find.text('ALICE ACE RIVERA'), findsOneWidget);
    expect(find.text('ALICE_1'), findsNothing);
    expect(find.text('EMAIL: shared@example.com'), findsOneWidget);
    expect(find.textContaining('AGE: 27'), findsOneWidget);
    expect(find.textContaining('HT: 5\'10"'), findsOneWidget);
    expect(find.textContaining('WT: 155.5 LBS'), findsOneWidget);
    expect(find.text('REC: 0-0-0'), findsOneWidget);
    expect(find.text('None'), findsOneWidget);
    expect(find.text('Signature Technique • Boxing'), findsOneWidget);
    expect(find.textContaining('Marcus'), findsNothing);
    expect(find.textContaining('Overhand Right'), findsNothing);
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
    expect(find.text('Fighter name'), findsOneWidget);
    expect(find.text('Age'), findsOneWidget);
    expect(find.text('Fight style (optional)'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pump();
    expect(find.text('Enter a valid height in inches'), findsOneWidget);
    expect(find.text('Enter a valid weight in pounds'), findsOneWidget);
    expect(find.text('Enter your fighter name'), findsOneWidget);
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
    await tester.enterText(fields.at(2), 'Alice Ace Rivera');
    await tester.enterText(fields.at(3), '25');
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(savedDetails?.heightInches, 70);
    expect(savedDetails?.weightLbs, 155.5);
    expect(savedDetails?.fighterName, 'Alice Ace Rivera');
    expect(savedDetails?.age, 25);
    expect(savedDetails?.style, isNull);
    expect(find.text('Account successfully created'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
