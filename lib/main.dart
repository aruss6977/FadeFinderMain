import 'package:flutter/material.dart';
import 'screens/match_screen.dart';
import 'screens/vote_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const FadeFinderApp());
}

// Root Application Widget: configures global theming and starting route.
class FadeFinderApp extends StatelessWidget {
  const FadeFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FadeFinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.redAccent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MainNavigationShell(),
    );
  }
}

// Navigation Shell: Manages the BottomNavigationBar and switches active screen tabs.
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedTabIndex = 0;

  // The 3 core app screens mapped to bottom navigation tabs
  final List<Widget> _screens = const [
    MatchScreen(),
    VoteScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack preserves state of all screens while switching tabs
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