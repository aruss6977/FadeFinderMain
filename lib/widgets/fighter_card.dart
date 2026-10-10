import 'package:flutter/material.dart';
import '../models/fighter.dart';

class FighterCard extends StatelessWidget {
  final Fighter fighter;

  const FighterCard({
    super.key,
    required this.fighter,
  });

  @override
  Widget build(BuildContext context) {
    final styleColor = fighter.style.themeColor;

    return Container(
      width: 320,
      decoration: BoxDecoration(
        // Outer metallic border (Trading card bevel)
        gradient: LinearGradient(
          colors: [
            Colors.amber.shade300,
            Colors.amber.shade700,
            Colors.amber.shade200,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8), // Border thickness
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24), // Dark card inner slate
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. TOP HEADER: Style Icon, Name, and Weight Class Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: styleColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: styleColor, width: 1.5),
                      ),
                      child: Icon(fighter.style.icon, size: 16, color: styleColor),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      fighter.name.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    fighter.weightClass.label.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // 2. CARD ART WINDOW: Framed illustration box
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: [
                    styleColor.withOpacity(0.8),
                    const Color(0xFF0F0F12),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(color: Colors.white24, width: 1.5),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.sports_martial_arts,
                    size: 90,
                    color: Colors.white.withOpacity(0.85),
                  ),
                  // Bottom-Left Badge: Record
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Text(
                        'REC: ${fighter.record}',
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Physical stats sub-banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.white10,
              child: Text(
                'AGE: ${fighter.age}  |  HT: ${fighter.formattedHeight}  |  WT: ${fighter.weightLbs.toStringAsFixed(1)} LBS',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3. SIGNATURE MOVE / ATTACK BOX
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Icon(fighter.style.icon, size: 20, color: styleColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fighter.signatureMove,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Signature Technique • ${fighter.style.label}',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 4. FLAVOR TEXT (Fighter Bio)
            if (fighter.bio.isNotEmpty)
              Text(
                '"${fighter.bio}"',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 8),

            // 5. CARD FOOTER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'FADEFINDER #00${fighter.id.replaceAll('f', '')}',
                  style: const TextStyle(color: Colors.white38, fontSize: 9),
                ),
                const Text(
                  '1ST EDITION ★',
                  style: TextStyle(color: Colors.amberAccent, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}