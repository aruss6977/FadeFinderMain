import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/mock_fighters.dart';
import '../models/account_profile.dart';
import '../models/fighter.dart';
import '../widgets/fighter_card.dart';

// profile tab displaying the logged-in user combat card and persistent challenge ledger
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.profileStream});

  final Stream<Map<String, dynamic>?>? profileStream;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Stream<Map<String, dynamic>?> _profileStream;

  @override
  void initState() {
    super.initState();
    if (widget.profileStream != null) {
      _profileStream = widget.profileStream!;
    } else {
      final user = FirebaseAuth.instance.currentUser;
      _profileStream = user == null
          ? Stream.value(null)
          : FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots()
              .map((snapshot) => snapshot.data());
    }
  }

  Widget _buildAccountProfile(AsyncSnapshot<Map<String, dynamic>?> snapshot) {
    if (snapshot.hasError) {
      return const Text(
        'Could not load your profile. Check Firestore access for your account.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white70),
      );
    }
    if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator(color: Colors.amberAccent);
    }
    final data = snapshot.data;
    if (data == null) {
      return const Text(
        'No profile was found for this account.',
        style: TextStyle(color: Colors.white70),
      );
    }
    try {
      final profile = AccountProfile.fromMap(data);
      if (profile.username.isEmpty ||
          profile.age == null ||
          profile.heightInches == null ||
          profile.weightLbs == null) {
        return const Text(
          'This account has incomplete profile data.',
          style: TextStyle(color: Colors.white70),
        );
      }
      return FighterCard(
        fighter: Fighter(
          id: data['id'] as String? ?? 'profile',
          name: profile.fighterName.isEmpty
              ? 'Fighter name not set'
              : profile.fighterName,
          age: profile.age!,
          heightInches: profile.heightInches!,
          weightLbs: profile.weightLbs!,
          style: profile.style,
          record: '0-0-0',
          signatureMove: 'None',
        ),
        profileEmail: profile.email,
      );
    } on TypeError {
      return const Text(
        'This account has incomplete profile data.',
        style: TextStyle(color: Colors.white70),
      );
    }
  }

  // removes an athlete from the active challenges queue and refreshes the ledger view
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0), // warm parchment background
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
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              activeChallenges.clear();
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: StreamBuilder<Map<String, dynamic>?>(
                  stream: _profileStream,
                  builder: (context, snapshot) =>
                      Center(child: _buildAccountProfile(snapshot)),
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

                      // empty state when no fighters have been challenged
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
                          separatorBuilder: (_, __) =>
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
