import 'package:flutter/material.dart';

import '../data/challenge_state.dart';
import '../models/fighter.dart';
import '../services/discovery_repository.dart';
import '../widgets/fighter_card.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key, this.repository});

  final DiscoveryRepository? repository;

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _SwipeAction {
  const _SwipeAction(this.fighter, this.challenged);
  final Fighter fighter;
  final bool challenged;
}

class _MatchScreenState extends State<MatchScreen> {
  late final DiscoveryRepository _repository =
      widget.repository ?? FirebaseDiscoveryRepository();
  DiscoveryData? _data;
  Set<String> _swipedIds = {};
  final List<_SwipeAction> _history = [];
  FightStyle? _selectedStyle;
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repository.load();
      if (!mounted) return;
      setState(() {
        _data = data;
        _swipedIds = {...data.swipedIds};
        _history.clear();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error is StateError ? error.message : 'Could not load fighters. Check your connection and database permissions.';
      });
    }
  }

  List<Fighter> _available(FightStyle? style) {
    final data = _data;
    if (data == null) return [];
    return DiscoveryData(
      currentUserId: data.currentUserId,
      weightClass: data.weightClass,
      fighters: data.fighters,
      swipedIds: _swipedIds,
    ).available(style);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _swipe(Fighter fighter, {required bool challenge}) async {
    if (_busy || _swipedIds.contains(fighter.id)) return;
    setState(() {
      _busy = true;
      _swipedIds.add(fighter.id);
      _history.add(_SwipeAction(fighter, challenge));
      if (challenge && !activeChallenges.any((f) => f.id == fighter.id)) {
        activeChallenges.add(fighter);
      }
    });
    try {
      await _repository.recordSwipe(fighter.id);
      if (mounted) {
        _showMessage(
          challenge ? 'Challenge sent to ${fighter.name}' : 'Fighter passed',
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _swipedIds.remove(fighter.id);
        _history.removeLast();
        if (challenge) activeChallenges.removeWhere((f) => f.id == fighter.id);
      });
      _showMessage('Could not save your swipe. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _undo() async {
    if (_busy || _history.isEmpty) return;
    final action = _history.last;
    setState(() => _busy = true);
    try {
      await _repository.undoSwipe(action.fighter.id);
      if (!mounted) return;
      setState(() {
        _history.removeLast();
        _swipedIds.remove(action.fighter.id);
        if (action.challenged) {
          activeChallenges.removeWhere((f) => f.id == action.fighter.id);
        }
      });
    } catch (_) {
      if (mounted) _showMessage('Could not undo your swipe. Please try again.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = _available(_selectedStyle);
    final fighter = available.isEmpty ? null : available.first;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'DISCOVER FIGHTERS',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2),
        ),
        actions: [
          IconButton(
            onPressed: _loading || _busy ? null : _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh fighters',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(_error!, textAlign: TextAlign.center),
                  ),
                  TextButton(onPressed: _load, child: const Text('Retry')),
                ],
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      '${_data!.weightClass.label.toUpperCase()} FIGHTERS',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: const Text('All styles'),
                            selected: _selectedStyle == null,
                            onSelected: (_) =>
                                setState(() => _selectedStyle = null),
                          ),
                        ),
                        ...FightStyle.values.map(
                          (style) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(style.label),
                              selected: _selectedStyle == style,
                              onSelected: (_) =>
                                  setState(() => _selectedStyle = style),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: fighter == null
                          ? Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                _available(null).isEmpty
                                    ? 'there are no more users who want to catch a fade'
                                    : 'No fighters match this style.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(16),
                              child: GestureDetector(
                                key: ValueKey(fighter.id),
                                onHorizontalDragEnd: _busy
                                    ? null
                                    : (details) {
                                        final velocity =
                                            details.primaryVelocity ?? 0;
                                        if (velocity.abs() > 250) {
                                          _swipe(
                                            fighter,
                                            challenge: velocity > 0,
                                          );
                                        }
                                      },
                                child: SingleChildScrollView(
                                  child: FighterCard(fighter: fighter),
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (fighter != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _busy
                                ? null
                                : () => _swipe(fighter, challenge: false),
                            icon: const Icon(Icons.close),
                            label: const Text('PASS'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF3B30),
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _busy
                                ? null
                                : () => _swipe(fighter, challenge: true),
                            icon: const Icon(Icons.sports_mma),
                            label: const Text('CHALLENGE'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF34C759),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  TextButton.icon(
                    onPressed: _busy || _history.isEmpty ? null : _undo,
                    icon: const Icon(Icons.undo),
                    label: const Text('Undo last swipe'),
                  ),
                ],
              ),
            ),
    );
  }
}
