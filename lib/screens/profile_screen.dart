import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/mock_fighters.dart';
import '../models/fighter.dart';
import '../widgets/fighter_card.dart';

// profile tab displaying the logged-in user combat card and persistent challenge ledger
// listens to live firestore document updates and manages issued sparring invitations
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // removes an athlete from the active challenges queue and refreshes the ledger view
  // syncs state immediately with the shared in-memory activeChallenges list
  void _withdrawChallenge(String fighterId) {
    setState(() {
      activeChallenges.removeWhere((fighter) => fighter.id == fighterId);
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2B2B2B),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
        ),
        content: const Row(
          children: [
            Icon(Icons.remove_circle_outline, color: Color(0xFFFF3B30), size: 20),
            SizedBox(width: 10),
            Text(
              'CHALLENGE WITHDRAWN',
              style: TextStyle(
                color: Color(0xFFFF3B30),
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // parses a firestore user document snapshot map into a domain fighter model
  // defensively casts dynamic json numbers and matches string keys to fight style enums
  Fighter _fighterFromSnapshot(Map<String, dynamic> data, String uid) {
    FightStyle? parsedStyle;
    final rawStyle = data['style'] as String?;
    if (rawStyle != null) {
      for (final s in FightStyle.values) {
        if (s.name == rawStyle) {
          parsedStyle = s;
          break;
        }
      }
    }

    return Fighter(
      id: uid,
      name: data['name'] as String? ?? 'Unknown Fighter',
      age: (data['age'] as num?)?.toInt() ?? 25,
      heightInches: (data['heightInches'] as num?)?.toInt() ?? 70,
      weightLbs: (data['weightLbs'] as num?)?.toDouble() ?? 155.0,
      style: parsedStyle,
      bio: data['bio'] as String? ?? 'Ready to step into the ring.',
      signatureMove: data['signatureMove'] as String? ?? 'Overhand Right',
      powerRating: (data['powerRating'] as num?)?.toInt() ?? 85,
      record: data['record'] as String? ?? '0-0-0',
    );
  }

  @override
  Widget build(BuildContext context) {
    // resolve the currently authenticated firebase user instance
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0), // warm parchment editorial canvas
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'MY FIGHTER PROFILE',
          style: TextStyle(
            color: Color(0xFF1C1B1F),
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          // render logout button only when an authenticated session exists
          if (user != null)
            IconButton(
              icon: const Icon(Icons.logout, color: Color(0xFF1C1B1F)),
              tooltip: 'Sign Out',
              onPressed: () async {
                // invalidate session and tear down firebase tokens
                await FirebaseAuth.instance.signOut();
                // verify widget is still mounted in element tree before triggering navigation
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),

              // dynamic athlete digital combat card powered by live firestore stream
              Center(
                child: user == null
                    ? FighterCard(fighter: mockFighters.first)
                    : StreamBuilder<DocumentSnapshot>>(
                        // subscribe directly to document changes on the users collection
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          // display centered activity indicator while initial snapshot resolves
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(40.0),
                              child: CircularProgressIndicator(color: Color(0xFF1C1B1F)),
                            );
                          }

                          // fallback to mock card if cloud document has not yet initialized
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return FighterCard(fighter: mockFighters.first);
                          }

                          // unpack firestore document data and construct domain model
                          final data = snapshot.data!.data()!;
                          final realFighter = _fighterFromSnapshot(data, user.uid);
                          return FighterCard(fighter: realFighter);
                        },
                      ),
              ),

              const SizedBox(height: 24),

              // active sparring challenges ledger container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2DDD5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                                color: Color(0xFF1C1B1F),
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'ACTIVE CHALLENGES',
                                style: TextStyle(
                                  color: Color(0xFF1C1B1F),
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
                              color: const Color(0xFF1C1B1F),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${activeChallenges.length} PENDING',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFE2DDD5), height: 1),
                      const SizedBox(height: 12),

                      // empty state rendered when user has issued zero challenges
                      if (activeChallenges.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 36,
                                  color: Color(0xFF79747E),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'no pending sparring requests.',
                                  style: TextStyle(
                                    color: Color(0xFF1C1B1F),
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'swipe right on fighters in discover to challenge them.',
                                  style: TextStyle(
                                    color: Color(0xFF79747E),
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
                          separatorBuilder: (_, _) =>
                              const Divider(color: Color(0xFFF0EBE1), height: 16),
                          itemBuilder: (context, index) {
                            final challengedFighter = activeChallenges[index];
                            final challengedStyleColor =
                                challengedFighter.style?.themeColor ??
                                const Color(0xFF1C1B1F);
                            final challengedStyleIcon =
                                challengedFighter.style?.icon ?? Icons.sports_mma;
                            final challengedStyleLabel =
                                challengedFighter.style?.label ?? 'Unassigned';

                            return Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: challengedStyleColor.withValues(alpha: 0.15),
                                  child: Icon(
                                    challengedStyleIcon,
                                    color: challengedStyleColor,
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
                                          color: Color(0xFF1C1B1F),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '$challengedStyleLabel • ${challengedFighter.weightClass.label}',
                                        style: const TextStyle(
                                          color: Color(0xFF79747E),
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
                                    color: Color(0xFF79747E),
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