import 'package:flutter/material.dart';
import '../data/mock_fighters.dart';
import '../models/fighter.dart';
import '../widgets/fighter_card.dart';

// discovery screen where users browse fighter trading cards with swipe gestures and filter chips
class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  // active deck displayed to the user based on applied filter
  late List<Fighter> _deck;

  // currently active combat style filter; null represents all disciplines
  FightStyle? _selectedStyleFilter;

  @override
  void initState() {
    super.initState();
    // initialize card deck on initial render
    _applyFilterAndReset();
  }

  // filters the mock fighters list by selected style or resets to the full catalog
  void _applyFilterAndReset([FightStyle? style]) {
    setState(() {
      _selectedStyleFilter = style;
      if (style == null) {
        _deck = List.from(mockFighters);
      } else {
        _deck = mockFighters.where((f) => f.style == style).toList();
      }
    });
  }

  // handles both manual swipe gestures and button triggers for passing or challenging
  void _handleSwipe(DismissDirection direction, Fighter fighter) {
    setState(() {
      _deck.removeWhere((item) => item.id == fighter.id);
    });

    // determine whether the action is a challenge (swipe right) or pass (swipe left)
    final isChallenge = direction == DismissDirection.startToEnd;
    final action = isChallenge ? 'CHALLENGED' : 'PASSED';
    final color = isChallenge ? Colors.greenAccent : Colors.redAccent;

    // if challenged, add fighter to active sparring queue avoiding duplicates
    if (isChallenge) {
      if (!activeChallenges.any((f) => f.id == fighter.id)) {
        activeChallenges.insert(0, fighter);
      }
    }

    // display quick non-blocking notification banner
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1E24),
        duration: const Duration(milliseconds: 900),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color, width: 1.5),
        ),
        content: Row(
          children: [
            Icon(
              isChallenge ? Icons.sports_mma : Icons.close,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$action: ${fighter.name.toUpperCase()}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // triggers programmatic swipe from the floating action buttons
  void _triggerProgrammaticSwipe(DismissDirection direction) {
    if (_deck.isEmpty) return;
    final topFighter = _deck.first;
    _handleSwipe(direction, topFighter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141418),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'DISCOVER FIGHTERS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        centerTitle: true,
        actions: [
          // deck reset action icon
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amberAccent),
            onPressed: () => _applyFilterAndReset(_selectedStyleFilter),
            tooltip: 'Reload Current Deck',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // horizontal scrollable list of discipline filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Row(
                children: [
                  _buildFilterChip(
                    label: 'ALL',
                    isSelected: _selectedStyleFilter == null,
                    onTap: () => _applyFilterAndReset(null),
                  ),
                  const SizedBox(width: 8),
                  ...FightStyle.values.map((style) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildFilterChip(
                        label: style.label.toUpperCase(),
                        isSelected: _selectedStyleFilter == style,
                        activeColor: style.themeColor,
                        onTap: () => _applyFilterAndReset(style),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // subtitle instructions banner
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 8),
              child: Text(
                _deck.isNotEmpty
                    ? 'SWIPE RIGHT TO CHALLENGE • SWIPE LEFT TO PASS'
                    : 'NO FIGHTERS MATCHING THIS CRITERIA',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),

            // trading card stack layout
            Expanded(
              child: Center(
                child: _deck.isEmpty
                    ? _buildEmptyState()
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          // underlying peek card rendered beneath the active top card
                          if (_deck.length > 1)
                            Transform.scale(
                              scale: 0.94,
                              child: Opacity(
                                opacity: 0.45,
                                child: FighterCard(fighter: _deck[1]),
                              ),
                            ),

                          // top interactive swipeable trading card
                          Dismissible(
                            key: ValueKey('${_deck.first.id}_${_selectedStyleFilter?.name ?? "all"}'),
                            direction: DismissDirection.horizontal,
                            onDismissed: (direction) =>
                                _handleSwipe(direction, _deck.first),
                            background: _buildSwipeIndicator(
                              alignment: Alignment.centerLeft,
                              color: Colors.greenAccent,
                              icon: Icons.sports_mma,
                              text: 'CHALLENGE',
                            ),
                            secondaryBackground: _buildSwipeIndicator(
                              alignment: Alignment.centerRight,
                              color: Colors.redAccent,
                              icon: Icons.close,
                              text: 'PASS',
                            ),
                            child: FighterCard(fighter: _deck.first),
                          ),
                        ],
                      ),
              ),
            ),

            // bottom action buttons for manual triggers
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // pass button (swipe left)
                  FloatingActionButton(
                    heroTag: 'pass_btn',
                    backgroundColor: const Color(0xFF1E1E24),
                    shape: CircleBorder(
                      side: BorderSide(
                        color: Colors.redAccent.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    onPressed: _deck.isEmpty
                        ? null
                        : () => _triggerProgrammaticSwipe(DismissDirection.endToStart),
                    child: const Icon(Icons.close, color: Colors.redAccent, size: 28),
                  ),
                  const SizedBox(width: 40),

                  // challenge button (swipe right)
                  FloatingActionButton(
                    heroTag: 'challenge_btn',
                    backgroundColor: const Color(0xFF1E1E24),
                    shape: CircleBorder(
                      side: BorderSide(
                        color: Colors.greenAccent.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    onPressed: _deck.isEmpty
                        ? null
                        : () => _triggerProgrammaticSwipe(DismissDirection.startToEnd),
                    child: const Icon(Icons.sports_mma, color: Colors.greenAccent, size: 28),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // individual styled filter pill widget
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color activeColor = Colors.amberAccent,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.2)
              : const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : Colors.white24,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
      ),
    );
  }

  // visual badge shown behind card during drag gesture
  Widget _buildSwipeIndicator({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String text,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 14,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // placeholder view displayed when all cards in current filter have been dismissed
  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.style_outlined,
          size: 70,
          color: Colors.white.withValues(alpha: 0.2),
        ),
        const SizedBox(height: 16),
        const Text(
          'DECK CLEARED',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedStyleFilter == null
              ? 'you have reviewed all available fighters.'
              : 'no more fighters found in ${_selectedStyleFilter!.label}.',
          style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amberAccent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => _applyFilterAndReset(null),
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text(
            'RESET TO ALL FIGHTERS',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}