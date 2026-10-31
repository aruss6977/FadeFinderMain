import 'package:flutter/material.dart';
import 'screens/match_screen.dart';
import 'screens/vote_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/welcome_page.dart';
import 'screens/account_creation_screen.dart';
import 'screens/sign_in_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

// application entry point: establishes engine bindings and mounts root widget
Future<void> main() async {
  // ensures platform channels are wired before executing asynchronous initialization
  WidgetsFlutterBinding.ensureInitialized();

  // initializes native firebase core client using generated platform configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FadeFinderApp());
}

// root application widget configuring global theming, routes, and starting views
class FadeFinderApp extends StatelessWidget {
  const FadeFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FadeFinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // material 3 design palette seeded with combat red accent tone
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.redAccent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const WelcomePage(),
      // named route definitions enabling declarative navigation transitions
      routes: {
        '/app': (context) => const AuthenticatedApp(),
        '/sign-in': (context) => const SignInScreen(),
        '/create-account': (context) => const AccountCreationScreen(),
      },
    );
  }
}

// authentication gatekeeper routing users between onboarding and authenticated shell
class AuthenticatedApp extends StatelessWidget {
  const AuthenticatedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // listens to realtime authentication changes (login, logout, token refresh)
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) => snapshot.data == null
          ? const WelcomePage()
          : const MainNavigationShell(),
    );
  }
}

// navigation shell managing persistent tabs across the primary bottom bar
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  // tracks active tab index displayed in viewport
  int _selectedTabIndex = 0;

  // primary destination screens mounted inside the shell indexed stack
  final List<Widget> _screens = const [
    MatchScreen(),
    VoteScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // indexed stack maintains state and scroll offsets across tab switches
      body: IndexedStack(
        index: _selectedTabIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTabIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.how_to_vote_outlined),
            selectedIcon: Icon(Icons.how_to_vote),
            label: 'Vote',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}