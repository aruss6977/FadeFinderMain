import 'package:flutter/material.dart';

/// Supported fighting styles
enum FightStyle {
  boxing('Boxing', Icons.sports_mma, Color(0xFFE53935)),
  muayThai('Muay Thai', Icons.flash_on, Color(0xFFFFB300)),
  bjj('BJJ', Icons.all_inclusive, Color(0xFF8E24AA)),
  mma('MMA', Icons.shield, Color(0xFF3949AB)),
  wrestling('Wrestling', Icons.fitness_center, Color(0xFF00897B));

  final String label;
  final IconData icon;
  final Color themeColor;

  const FightStyle(this.label, this.icon, this.themeColor);
}

/// Standard weight classifications
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

  static WeightClass fromWeight(double weight) {
    for (final wc in WeightClass.values) {
      if (weight <= wc.maxWeight) return wc;
    }
    return WeightClass.heavyweight;
  }
}

/// Fighter domain model with Trading Card stats
class Fighter {
  final String id;
  final String name;
  final int age;
  final int heightInches;
  final double weightLbs;
  final FightStyle style;
  final String bio;
  final String signatureMove;
  final int powerRating; // Like Card HP / Attack Power (e.g. 85-99)
  final String record; // e.g., "6-1-0"

  const Fighter({
    required this.id,
    required this.name,
    required this.age,
    required this.heightInches,
    required this.weightLbs,
    required this.style,
    this.bio = '',
    this.signatureMove = 'Overhand Right',
    this.powerRating = 85,
    this.record = '3-1-0',
  });

  WeightClass get weightClass => WeightClass.fromWeight(weightLbs);

  String get formattedHeight {
    final feet = heightInches ~/ 12;
    final inches = heightInches % 12;
    return "$feet'$inches\"";
  }
}

/// Matchup domain model for voting
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

  int get totalVotes => votesA + votesB;

  double get percentageA => totalVotes == 0 ? 50.0 : (votesA / totalVotes) * 100;
  double get percentageB => totalVotes == 0 ? 50.0 : (votesB / totalVotes) * 100;
}