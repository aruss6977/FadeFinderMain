import 'package:flutter/material.dart';
import '../data/mock_fighters.dart';
import '../models/fighter.dart';

// arena voting screen supporting multiple matchups, vote locking, and corner switching
// provides head-to-head comparison cards with real-time percentage distribution bars
class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  // pointer tracking the currently visible matchup index in the carousel
  int _currentMatchupIndex = 0;

  // dictionary storing user votes keyed by matchup id
  // key: matchup.id, value: 'A' for corner a, 'B' for corner b, or null if unvoted
  final Map<String, String> _userVotes = {};

  // dynamic getter returning the matchup currently active in viewport
  Matchup get _currentMatchup => mockMatchups[_currentMatchupIndex];

  // casts or flips a user vote between corners without permitting duplicate ballots
  // adjusts tally counters atomically and updates the persistent selection map
  void _castVote(String corner) {
    final matchup = _currentMatchup;
    final previousVote = _userVotes[matchup.id];

    // guard: tapping the already selected corner does not increment vote totals
    if (previousVote == corner) {
      return;
    }

    setState(() {
      // decrement old corner count if user is flipping their selection
      if (previousVote == 'A') {
        matchup.votesA--;
      } else if (previousVote == 'B') {
        matchup.votesB--;
      }

      // register new corner ballot and update user choice record
      if (corner == 'A') {
        matchup.votesA++;
        _userVotes[matchup.id] = 'A';
      } else if (corner == 'B') {
        matchup.votesB++;
        _userVotes[matchup.id] = 'B';
      }
    });

    // clear active snackbar alerts to immediately display vote confirmation
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2B2B2B),
        duration: const Duration(milliseconds: 700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFFF9500), width: 1.5),
        ),
        content: Row(
          children: [
            const Icon(Icons.how_to_vote, color: Color(0xFFFF9500), size: 20),
            const SizedBox(width: 10),
            Text(
              'VOTE RECORDED FOR ${corner == 'A' ? matchup.fighterA.name.toUpperCase() : matchup.fighterB.name.toUpperCase()}',
              style: const TextStyle(
                color: Color(0xFFFF9500),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // navigates backward to the preceding clash in the catalog
  void _goToPreviousMatchup() {
    if (_currentMatchupIndex > 0) {
      setState(() {
        _currentMatchupIndex--;
      });
    }
  }

  // navigates forward to the subsequent clash in the catalog
  void _goToNextMatchup() {
    if (_currentMatchupIndex < mockMatchups.length - 1) {
      setState(() {
        _currentMatchupIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final matchup = _currentMatchup;
    final userSelection = _userVotes[matchup.id];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0), // warm editorial background canvas
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ARENA MATCHUPS',
          style: TextStyle(
            color: Color(0xFF1C1B1F),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // matchup carousel header bar with step counters and directional arrows
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1C1B1F), size: 18),
                  onPressed: _currentMatchupIndex > 0 ? _goToPreviousMatchup : null,
                ),
                Text(
                  'MATCHUP ${_currentMatchupIndex + 1} OF ${mockMatchups.length}',
                  style: const TextStyle(
                    color: Color(0xFF1C1B1F),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF1C1B1F), size: 18),
                  onPressed: _currentMatchupIndex < mockMatchups.length - 1 ? _goToNextMatchup : null,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // primary container enclosing head-to-head comparison cards and vote meter
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2DDD5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'FEATURED SPARRING CLASH',
                    style: TextStyle(
                      color: Color(0xFFFF3B30),
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // horizontal duel row: corner a mini card vs corner b mini card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // corner a fighter card (red team)
                      Expanded(
                        child: _buildMiniBattleCard(
                          fighter: matchup.fighterA,
                          onVote: () => _castVote('A'),
                          cornerColor: const Color(0xFFFF3B30),
                          isSelected: userSelection == 'A',
                        ),
                      ),

                      // central vs circular divider icon
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 40.0),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1C1B1F),
                            border: Border.all(color: const Color(0xFFFF3B30), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Text(
                            'VS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      // corner b fighter card (blue team)
                      Expanded(
                        child: _buildMiniBattleCard(
                          fighter: matchup.fighterB,
                          onVote: () => _castVote('B'),
                          cornerColor: const Color(0xFF007AFF),
                          isSelected: userSelection == 'B',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // vote percentage labels and total count readout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${matchup.percentageA.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Color(0xFFFF3B30),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${matchup.totalVotes} VOTES CAST',
                        style: const TextStyle(
                          color: Color(0xFF79747E),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${matchup.percentageB.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Color(0xFF007AFF),
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // two-tone distribution meter visualizing split percentage
                  // valueColor renders corner a; backgroundColor serves as corner b
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: matchup.percentageA / 100,
                      minHeight: 12,
                      backgroundColor: const Color(0xFF007AFF),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF3B30)),
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

  // helper widget rendering compact battle cards with selectable state styling
  Widget _buildMiniBattleCard({
    required Fighter fighter,
    required VoidCallback onVote,
    required Color cornerColor,
    required bool isSelected,
  }) {
    final styleTheme = fighter.style?.themeColor ?? const Color(0xFF1C1B1F);
    final styleLabel = fighter.style?.label ?? 'Unassigned';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F0),
        borderRadius: BorderRadius.circular(12),
        // selected cards receive darker high-contrast border
        border: Border.all(
          color: isSelected ? const Color(0xFF1C1B1F) : const Color(0xFFE2DDD5),
          width: isSelected ? 2.5 : 1.0,
        ),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          // fighter avatar box with discipline-tinted gradient
          Container(
            height: 90,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  styleTheme,
                  const Color(0xFF1C1B1F),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Icon(
              Icons.sports_martial_arts,
              size: 50,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 8),

          // athlete name with ellipsis constraint
          Text(
            fighter.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF1C1B1F),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),

          // combat style descriptor subtitle
          Text(
            styleLabel,
            style: const TextStyle(color: Color(0xFF79747E), fontSize: 11),
          ),
          const SizedBox(height: 2),

          // win-loss record readout
          Text(
            fighter.record,
            style: const TextStyle(
              color: Color(0xFF1C1B1F),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),

          // action button toggling corner pick and visual selection state
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? const Color(0xFF1C1B1F) : cornerColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onVote,
              child: Text(
                isSelected ? 'YOUR PICK ✓' : 'PICK WIN',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}