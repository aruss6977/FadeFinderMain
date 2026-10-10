import 'package:flutter/material.dart';
import '../data/mock_fighters.dart';
import '../models/fighter.dart';

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
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
      backgroundColor: const Color(0xFF141418),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ARENA MATCHUPS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Head-to-Head Arena Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E24),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'FEATURED SPARRING CLASH',
                    style: TextStyle(
                      color: Colors.amberAccent,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cards Clash Row: Mini Card A vs Mini Card B
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Fighter A Mini Battle Card
                      Expanded(
                        child: _buildMiniBattleCard(matchup.fighterA, _voteA, Colors.redAccent),
                      ),

                      // "VS" Battle Badge
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black,
                            border: Border.all(color: Colors.amberAccent, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amberAccent.withOpacity(0.3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Text(
                            'VS',
                            style: TextStyle(
                              color: Colors.amberAccent,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      // Fighter B Mini Battle Card
                      Expanded(
                        child: _buildMiniBattleCard(matchup.fighterB, _voteB, Colors.blueAccent),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Battle Vote Distribution Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${matchup.percentageA.toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      Text(
                        '${matchup.totalVotes} VOTES CAST',
                        style: const TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${matchup.percentageB.toStringAsFixed(0)}%',
                        style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: matchup.percentageA / 100,
                      minHeight: 12,
                      backgroundColor: Colors.blueAccent,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mini Trading Card component for head-to-head match views
  Widget _buildMiniBattleCard(Fighter fighter, VoidCallback onVote, Color buttonColor) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141418),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade600, width: 1.5),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // Silhouette Illustration Box
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  fighter.style.themeColor.withOpacity(0.7),
                  Colors.black,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Icon(
              Icons.sports_martial_arts,
              size: 50,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),

          Text(
            fighter.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),

          Text(
            fighter.style.label,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
          ),
          const SizedBox(height: 2),

          Text(
            fighter.record,
            style: const TextStyle(color: Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: onVote,
              child: const Text('PICK WIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}