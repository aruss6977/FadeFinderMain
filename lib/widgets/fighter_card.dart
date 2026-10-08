import 'package:flutter/material.dart';
import '../models/fighter.dart';

// Reusable card widget that displays a single fighter's profile details.
// Marked as StatelessWidget because it only renders what it is given and holds no internal state.
class FighterCard extends StatelessWidget {
  final Fighter fighter;

  const FighterCard({
    super.key,
    required this.fighter,
  });

  @override
  Widget build(BuildContext context) {
    // Card provides standard elevation and rounded corner boundaries
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Placeholder Avatar using the fighter's first initial
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.redAccent.shade700,
              child: Text(
                fighter.name.isNotEmpty ? fighter.name[0] : '?',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Fighter Name and Age
            Text(
              '${fighter.name}, ${fighter.age}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Stat Badges: Style & Weight Class
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  label: Text(fighter.style.label),
                  backgroundColor: Colors.blueGrey.shade100,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(fighter.weightClass.label),
                  backgroundColor: Colors.orange.shade100,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Physical stats display (Formatted Height & Weight)
            Text(
              '${fighter.formattedHeight} • ${fighter.weightLbs.toStringAsFixed(1)} lbs',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Fighter Bio description
            if (fighter.bio.isNotEmpty)
              Text(
                fighter.bio,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }
}