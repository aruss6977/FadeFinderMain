import 'package:flutter/material.dart';

// supported combat disciplines with associated presentation metadata
// each enum value carries its display label, material icon, and theme accent color
enum FightStyle {
  boxing('Boxing', Icons.sports_mma, Color(0xFFFF3B30)),
  muayThai('Muay Thai', Icons.flash_on, Color(0xFFFF9500)),
  bjj('BJJ', Icons.all_inclusive, Color(0xFFAF52DE)),
  mma('MMA', Icons.shield, Color(0xFF007AFF)),
  wrestling('Wrestling', Icons.fitness_center, Color(0xFF34C759));

  // visual and textual descriptors attached to each style
  final String label;
  final IconData icon;
  final Color themeColor;

  const FightStyle(this.label, this.icon, this.themeColor);
}

// standard combat weight classifications bounded by maximum weight limits
enum WeightClass {
  flyweight('Flyweight', 125.0),
  bantamweight('Bantamweight', 135.0),
  featherweight('Featherweight', 145.0),
  lightweight('Lightweight', 155.0),
  welterweight('Welterweight', 170.0),
  middleweight('Middleweight', 185.0),
  lightHeavyweight('Light Heavyweight', 205.0),
  heavyweight('Heavyweight', 265.0);

  // display name and upper weight limit in pounds
  final String label;
  final double maxWeight;

  const WeightClass(this.label, this.maxWeight);

  // resolves weight class category from a raw numeric scale reading
  // iterates through divisions in ascending order and falls back to heavyweight
  static WeightClass fromWeight(double weight) {
    for (final wc in WeightClass.values) {
      if (weight <= wc.maxWeight) return wc;
    }
    return WeightClass.heavyweight;
  }
}

// athlete domain model encapsulating physical specs, bio, and performance stats
// provides immutable state for discovery cards, profiles, and sparring ledgers
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

  // dynamic weight class lookup derived directly from numeric weight
  WeightClass get weightClass => WeightClass.fromWeight(weightLbs);

  // imperial formatted height string representation (e.g. 5'11")
  // uses integer truncating division (~/) for feet and modulo (%) for remainder inches
  String get formattedHeight {
    final feet = heightInches ~/ 12;
    final inches = heightInches % 12;
    return "$feet'$inches\"";
  }
}

// matchup domain model representing a head-to-head arena voting clash
// holds mutable vote counters that update live when users cast ballots
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
  // defaults to 50.0 to prevent division by zero when no votes exist
  double get percentageA => totalVotes == 0 ? 50.0 : (votesA / totalVotes) * 100;

  // proportional percentage distribution for corner b
  // defaults to 50.0 to prevent division by zero when no votes exist
  double get percentageB => totalVotes == 0 ? 50.0 : (votesB / totalVotes) * 100;
}