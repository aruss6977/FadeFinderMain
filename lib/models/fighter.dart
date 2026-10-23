import 'package:flutter/material.dart';

// supported combat disciplines with high-contrast, accessible ui theme accents
enum FightStyle {
  boxing('Boxing', Icons.sports_mma, Color(0xFFFF3B30)), // vivid signal vermilion
  muayThai('Muay Thai', Icons.flash_on, Color(0xFFFF9500)), // warm amber orange
  bjj('BJJ', Icons.all_inclusive, Color(0xFFAF52DE)), // vibrant lavender violet
  mma('MMA', Icons.shield, Color(0xFF007AFF)), // vivid steel blue
  wrestling('Wrestling', Icons.fitness_center, Color(0xFF34C759)); // accessible clean emerald

  final String label;
  final IconData icon;
  final Color themeColor;

  const FightStyle(this.label, this.icon, this.themeColor);
}

// standard combat weight classifications
enum WeightClass {
  flyweight('Flyweight', 125.0),
  bantamweight('Bantamweight', 135.0),
  featherweight('Featherweight', 145.0),
  lightweight('Lightweight', 155.0),
  welterweight('Welterweight', 170.0),
  middleweight('Middleweight', 185.0),
  lightHeavyweight('Light Heavyweight', 205.0),
  heavyweight('Heavyweight', 265.0);

  final String label;
  final double maxWeight;

  const WeightClass(this.label, this.maxWeight);

  // resolves weight class category from raw numeric scale reading
  static WeightClass fromWeight(double weight) {
    for (final wc in WeightClass.values) {
      if (weight <= wc.maxWeight) return wc;
    }
    return WeightClass.heavyweight;
  }
}

// athlete domain model encapsulating physical specs, bio, and performance stats
class Fighter {
  final String id;
  final String name;
  final int age;
  final int heightInches;
  final double weightLbs;
  final FightStyle? style;
  final String bio;
  final String signatureMove;
  final int powerRating;
  final String record;

  const Fighter({
    required this.id,
    required this.name,
    required this.age,
    required this.heightInches,
    required this.weightLbs,
    this.style,
    this.bio = '',
    this.signatureMove = 'Overhand Right',
    this.powerRating = 85,
    this.record = '3-1-0',
  });

  // dynamic weight class lookup derived from numeric weight
  WeightClass get weightClass => WeightClass.fromWeight(weightLbs);

  // imperial formatted height string representation (e.g. 5'11")
  String get formattedHeight {
    final feet = heightInches ~/ 12;
    final inches = heightInches % 12;
    return "$feet'$inches\"";
  }
}

// matchup domain model representing a head-to-head arena voting clash
class Matchup {
  final String id;
  final Fighter fighterA;
  final Fighter fighterB;
  int votesA;
  int votesB;

  Matchup({
    required this.id,
    required this.fighterA,
    required this.fighterB,
    this.votesA = 0,
    this.votesB = 0,
  });

  // aggregated vote count across both corners
  int get totalVotes => votesA + votesB;

  // proportional percentage distribution for corner a
  double get percentageA => totalVotes == 0 ? 50.0 : (votesA / totalVotes) * 100;

  // proportional percentage distribution for corner b
  double get percentageB => totalVotes == 0 ? 50.0 : (votesB / totalVotes) * 100;
}