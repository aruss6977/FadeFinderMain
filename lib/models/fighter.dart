enum FightStyle {
  boxing('Boxing'),
  muayThai('Muay Thai'),
  bjj('Brazilian Jiu-Jitsu'),
  mma('MMA'),
  wrestling('Wrestling'),
  kickboxing('Kickboxing');

  final String label;
  const FightStyle(this.label);
}

enum WeightClass {
  flyweight('Flyweight', 0, 125),
  bantamweight('Bantamweight', 125.1, 135),
  featherweight('Featherweight', 135.1, 145),
  lightweight('Lightweight', 145.1, 155),
  welterweight('Welterweight', 155.1, 170),
  middleweight('Middleweight', 170.1, 185),
  lightHeavyweight('Light Heavyweight', 185.1, 205),
  heavyweight('Heavyweight', 205.1, 999);

  final String label;
  final double minWeight;
  final double maxWeight;

  const WeightClass(this.label, this.minWeight, this.maxWeight);

  static WeightClass fromWeight(double weightInLbs) {
    for (final wc in WeightClass.values) {
      if (weightInLbs >= wc.minWeight && weightInLbs <= wc.maxWeight) {
        return wc;
      }
    }
    return WeightClass.heavyweight;
  }
}

class Fighter {
  final String id;
  final String name;
  final int age;
  final int heightInches;
  final double weightLbs;
  final FightStyle style;
  final String bio;
  final String avatarUrl;

  const Fighter({
    required this.id,
    required this.name,
    required this.age,
    required this.heightInches,
    required this.weightLbs,
    required this.style,
    this.bio = '',
    this.avatarUrl = '',
  });

  WeightClass get weightClass => WeightClass.fromWeight(weightLbs);

  String get formattedHeight {
    final feet = heightInches ~/ 12;
    final inches = heightInches % 12;
    return "$feet'$inches\"";
  }
}

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