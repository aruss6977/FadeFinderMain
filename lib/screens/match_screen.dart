import 'package:flutter/material.dart';
import '../data/mock_fighters.dart';
import '../widgets/fighter_card.dart';

// Screen 1: Discovery / Match Feed.
// Stateful because it tracks which fighter card is currently on top.
class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  // Current index in our list of mock fighters
  int _currentIndex = 0;

  // Advances to next card or stops if at the end of the list
  void _nextFighter() {
    if (_currentIndex < mockFighters.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No more fighters nearby!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final fighter = mockFighters[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FadeFinder'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
          child: Column(
            children: [
              // Display the current fighter's profile card
              Expanded(
                child: Center(
                  child: FighterCard(fighter: fighter),
                ),
              ),
              const SizedBox(height: 20),

              // Action buttons: Pass vs Challenge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: 'pass_btn',
                    backgroundColor: Colors.grey.shade300,
                    onPressed: _nextFighter,
                    child: const Icon(Icons.close, color: Colors.black87),
                  ),
                  FloatingActionButton(
                    heroTag: 'challenge_btn',
                    backgroundColor: Colors.redAccent.shade700,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Challenged ${fighter.name}!')),
                      );
                      _nextFighter();
                    },
                    child: const Icon(Icons.sports_mma, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}