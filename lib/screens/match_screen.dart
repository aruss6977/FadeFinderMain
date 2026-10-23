import 'package:flutter/material.dart';
import '../data/mock_fighters.dart';
import '../models/fighter.dart';
import '../widgets/fighter_card.dart';

// discovery sparring screen with card swiping, undo support, and discipline filters
class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  // active discipline filter; null indicates all combat styles
  FightStyle? _selectedStyle;

  // active deck of fighters available for swiping
  late List<Fighter> _filteredDeck;

  // history stack enabling users to undo their previous pass or challenge action
  final List<Fighter> _actionHistory = [];

  @override
  void initState() {
    super.initState();
    _resetDeck();
  }

  // rebuilds deck based on the active style filter
  void _resetDeck() {
    setState(() {
      _actionHistory.clear();
      if (_selectedStyle == null) {
        _filteredDeck = List.from(mockFighters);
      } else {
        _filteredDeck = mockFighters
            .where((fighter) => fighter.style == _selectedStyle)
            .toList();
      }
    });
  }

  // handles user challenging an athlete (right swipe or glove button)
  void _challengeFighter(Fighter fighter) {
    setState(() {
      _actionHistory.add(fighter);
      _filteredDeck.removeWhere((f) => f.id == fighter.id);
      if (!activeChallenges.any((f) => f.id == fighter.id)) {
        activeChallenges.add(fighter);
      }
    });

    _showNotification(
      icon: Icons.sports_mma,
      message: 'CHALLENGED ${fighter.name.toUpperCase()}!',
      accentColor: const Color(0xFF2E7D32),
    );
  }

  // handles passing on an athlete (left swipe or x button)
  void _passFighter(Fighter fighter) {
    setState(() {
      _actionHistory.add(fighter);
      _filteredDeck.removeWhere((f) => f.id == fighter.id);
    });

    _showNotification(
      icon: Icons.close,
      message: 'PASSED ON ${fighter.name.toUpperCase()}',
      accentColor: const Color(0xFFD32F2F),
    );
  }

  // reverts the most recent swipe or button action and pushes card back on top of deck
  void _undoLastAction() {
    if (_actionHistory.isEmpty) return;

    final lastFighter = _actionHistory.removeLast();
    setState(() {
      // remove from challenges queue if it was challenged during that step
      activeChallenges.removeWhere((f) => f.id == lastFighter.id);
      _filteredDeck.insert(0, lastFighter);
    });

    _showNotification(
      icon: Icons.undo,
      message: 'RESTORED ${lastFighter.name.toUpperCase()}',
      accentColor: const Color(0xFFE65100),
    );
  }

  // helper displaying brief floating snackbar notifications
  void _showNotification({
    required IconData icon,
    required String message,
    required Color accentColor,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2B2B2B),
        duration: const Duration(milliseconds: 700),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: accentColor, width: 1.5),
        ),
        content: Row(
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
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
          'DISCOVER FIGHTERS',
          style: TextStyle(
            color: Color(0xFF1C1B1F), // dark ink header
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo, color: Color(0xFF1C1B1F)),
            tooltip: 'Undo Last Action',
            onPressed: _actionHistory.isNotEmpty ? _undoLastAction : null,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // horizontal filter pills for combat disciplines
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip('ALL', null),
                  ...FightStyle.values.map(
                    (style) => _buildFilterChip(style.label.toUpperCase(), style),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // action hint prompt
            const Text(
              'SWIPE RIGHT TO CHALLENGE • SWIPE LEFT TO PASS',
              style: TextStyle(
                color: Color(0xFF79747E),
                fontSize: 10,
                letterSpacing: 0.8,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // swipeable trading card arena
            Expanded(
              child: Center(
                child: _filteredDeck.isEmpty
                    ? _buildEmptyDeckState()
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          // underlying card in stack
                          if (_filteredDeck.length > 1)
                            Transform.scale(
                              scale: 0.94,
                              child: Opacity(
                                opacity: 0.6,
                                child: FighterCard(fighter: _filteredDeck[1]),
                              ),
                            ),

                          // active top card wrapped with dismissible gestures
                          Dismissible(
                            key: ValueKey(_filteredDeck.first.id),
                            direction: DismissDirection.horizontal,
                            onDismissed: (direction) {
                              final swiped = _filteredDeck.first;
                              if (direction == DismissDirection.endToStart) {
                                _passFighter(swiped);
                              } else {
                                _challengeFighter(swiped);
                              }
                            },
                            child: FighterCard(fighter: _filteredDeck.first),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // programmatic action control buttons
            if (_filteredDeck.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // pass button (red cross)
                    InkWell(
                      onTap: () => _passFighter(_filteredDeck.first),
                      borderRadius: BorderRadius.circular(40),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFFFF3B30), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.close, color: Color(0xFFFF3B30), size: 28),
                      ),
                    ),
                    const SizedBox(width: 36),

                    // challenge button (green glove)
                    InkWell(
                      onTap: () => _challengeFighter(_filteredDeck.first),
                      borderRadius: BorderRadius.circular(40),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(color: const Color(0xFF34C759), width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.sports_mma, color: Color(0xFF34C759), size: 28),
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

  // discipline filter chip builder
  Widget _buildFilterChip(String label, FightStyle? style) {
    final isSelected = _selectedStyle == style;

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF1C1B1F),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        selected: isSelected,
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF1C1B1F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF1C1B1F) : const Color(0xFFD0C9BF),
          ),
        ),
        showCheckmark: false,
        onSelected: (_) {
          setState(() {
            _selectedStyle = style;
            _resetDeck();
          });
        },
      ),
    );
  }

  // empty deck state widget
  Widget _buildEmptyDeckState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle_outline, size: 54, color: Color(0xFF1C1B1F)),
        const SizedBox(height: 16),
        const Text(
          'ALL FIGHTERS REVIEWED',
          style: TextStyle(
            color: Color(0xFF1C1B1F),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'reset filters or reshuffle the deck to continue.',
          style: TextStyle(color: Color(0xFF79747E), fontSize: 12),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _resetDeck,
          icon: const Icon(Icons.refresh, size: 16),
          label: const Text('RESET DECK', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1C1B1F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ],
    );
  }
}