import 'package:flutter/material.dart';
import '../data/mock_fighters.dart';
import '../widgets/fighter_card.dart';

// profile tab displaying the logged-in user combat card and persistent challenge ledger
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // removes an athlete from the active challenges queue and refreshes the ledger view
  void _withdrawChallenge(String fighterId) {
    setState(() {
      activeChallenges.removeWhere((fighter) => fighter.id == fighterId);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1E24),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.amberAccent, width: 1.5),
        ),
        content: const Row(
          children: [
            Icon(Icons.remove_circle_outline, color: Colors.amberAccent, size: 20),
            SizedBox(width: 10),
            Text(
              'CHALLENGE WITHDRAWN',
              style: TextStyle(
                color: Colors.amberAccent,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // primary fighter representing the authenticated user profile card
    final currentUser = mockFighters.first;

    return Scaffold(
      backgroundColor: const Color(0xFF141418),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'MY FIGHTER PROFILE',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              // athlete digital combat trading card
              Center(
                child: FighterCard(fighter: currentUser),
              ),

              const SizedBox(height: 24),

              // active sparring challenges ledger container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E24),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // section header showing active challenge counts
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.sports_mma,
                                color: Colors.amberAccent,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'ACTIVE CHALLENGES',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amberAccent.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${activeChallenges.length} PENDING',
                              style: const TextStyle(
                                color: Colors.amberAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white12, height: 1),
                      const SizedBox(height: 12),

                      // empty state when no fighters have been challenged
                      if (activeChallenges.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 36,
                                  color: Colors.white.withValues(alpha: 0.2),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'no pending sparring requests.',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'swipe right on fighters in discover to challenge them.',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        // list showing all currently challenged fighters with withdrawal option
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activeChallenges.length,
                          separatorBuilder: (_, __) =>
                              const Divider(color: Colors.white10, height: 16),
                          itemBuilder: (context, index) {
                            final challengedFighter = activeChallenges[index];
                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: challengedFighter.style.themeColor
                                      .withValues(alpha: 0.25),
                                  child: Icon(
                                    challengedFighter.style.icon,
                                    color: challengedFighter.style.themeColor,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        challengedFighter.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${challengedFighter.style.label} • ${challengedFighter.weightClass.label}',
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: Colors.white38,
                                  ),
                                  onPressed: () =>
                                      _withdrawChallenge(challengedFighter.id),
                                  tooltip: 'Withdraw Challenge',
                                ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}