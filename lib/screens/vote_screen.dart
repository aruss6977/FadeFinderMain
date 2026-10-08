import 'package:flutter/material.dart';
import '../data/mock_fighters.dart';
import '../models/fighter.dart';

// Screen 2: Community Matchup Voting.
// Stateful so users can tap to vote and see percentages update instantly.
class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  // Grab the first mock matchup for display
  late Matchup matchup;

  @override
  void initState() {
    super.initState();
    matchup = mockMatchups[0];
  }

  void _voteA() {
    setState(() {
      matchup.votesA++;
    });
  }

  void _voteB() {
    setState(() {
      matchup.votesB++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Matchups'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'UPCOMING SPARRING MATCH',
                      style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    // Fighters Head-to-Head
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Fighter A Column
                        Column(
                          children: [
                            Text(
                              matchup.fighterA.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(matchup.fighterA.style.label, style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _voteA,
                              child: const Text('Pick Win'),
                            ),
                          ],
                        ),

                        const Text('VS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                        // Fighter B Column
                        Column(
                          children: [
                            Text(
                              matchup.fighterB.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text(matchup.fighterB.style.label, style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _voteB,
                              child: const Text('Pick Win'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Real-time vote percentage breakdown
                    Text(
                      '${matchup.percentageA.toStringAsFixed(1)}%  —  ${matchup.percentageB.toStringAsFixed(1)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: matchup.percentageA / 100,
                        minHeight: 10,
                        backgroundColor: Colors.blueAccent,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('${matchup.totalVotes} total community votes', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}