import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../models/fighter.dart';

class VoteScreen extends StatefulWidget {
  const VoteScreen({super.key});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  int _currentIndex = 0;
  final Map<String, String> _userVotes = {};

  void _castVote(Matchup matchup, bool voteForA) {
    setState(() {
      if (voteForA) {
        matchup.votesA++;
        _userVotes[matchup.id] = 'A';
      } else {
        matchup.votesB++;
        _userVotes[matchup.id] = 'B';
      }
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'VOTED FOR ${voteForA ? matchup.fighterA.name.toUpperCase() : matchup.fighterB.name.toUpperCase()}!',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1C1B1F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ARENA VOTING',
          style: TextStyle(
            color: Color(0xFF1C1B1F),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<Matchup>>(
        valueListenable: matchupsNotifier,
        builder: (context, matchups, _) {
          if (matchups.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.how_to_vote_outlined, size: 54, color: Color(0xFF79747E)),
                  SizedBox(height: 16),
                  Text(
                    'NO ACTIVE BOUTS',
                    style: TextStyle(
                      color: Color(0xFF1C1B1F),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Confirm a bout in Sparring Chats to open community voting.',
                    style: TextStyle(color: Color(0xFF79747E), fontSize: 12),
                  ),
                ],
              ),
            );
          }

          if (_currentIndex >= matchups.length) {
            _currentIndex = 0;
          }
          final currentMatchup = matchups.elementAt(_currentIndex);

          final totalVotes = currentMatchup.votesA + currentMatchup.votesB;
          final pctA = totalVotes == 0 ? 50 : ((currentMatchup.votesA / totalVotes) * 100).round();
          final pctB = totalVotes == 0 ? 50 : 100 - pctA;
          final userChoice = _userVotes[currentMatchup.id];

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 18),
                        onPressed: matchups.length > 1
                            ? () {
                                setState(() {
                                  _currentIndex =
                                      (_currentIndex - 1 + matchups.length) % matchups.length;
                                });
                              }
                            : null,
                      ),
                      Text(
                        'BOUT ${_currentIndex + 1} OF ${matchups.length}',
                        style: const TextStyle(
                          color: Color(0xFF79747E),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 18),
                        onPressed: matchups.length > 1
                            ? () {
                                setState(() {
                                  _currentIndex = (_currentIndex + 1) % matchups.length;
                                });
                              }
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2DDD5)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFighterCard(
                            fighter: currentMatchup.fighterA,
                            votes: currentMatchup.votesA,
                            percent: pctA,
                            isSelected: userChoice == 'A',
                            onTap: () => _castVote(currentMatchup, true),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                const Expanded(child: Divider()),
                                Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 12),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1C1B1F),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'VS',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                          ),
                          _buildFighterCard(
                            fighter: currentMatchup.fighterB,
                            votes: currentMatchup.votesB,
                            percent: pctB,
                            isSelected: userChoice == 'B',
                            onTap: () => _castVote(currentMatchup, false),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2DDD5)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'TOTAL VOTES: $totalVotes',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        if (userChoice != null)
                          Text(
                            'YOUR PICK: ${userChoice == "A" ? currentMatchup.fighterA.name : currentMatchup.fighterB.name}',
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFighterCard({
    required Fighter fighter,
    required int votes,
    required int percent,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF0FDF4) : const Color(0xFFFDFDFD),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFFE2DDD5),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor:
                      const Color(0xFF1C1B1F).withValues(alpha: 0.08),
                  child: Icon(
                    fighter.style?.icon ?? Icons.sports_mma,
                    size: 24,
                    color: const Color(0xFF1C1B1F),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fighter.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      Text(
                        '${fighter.style?.label ?? "Striker"} • ${fighter.record}',
                        style: const TextStyle(
                            color: Color(0xFF79747E), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$percent%',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: isSelected
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFF1C1B1F),
                      ),
                    ),
                    Text(
                      '$votes votes',
                      style: const TextStyle(
                          color: Color(0xFF79747E), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 6,
                backgroundColor: const Color(0xFFE2DDD5),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isSelected
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF1C1B1F),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}