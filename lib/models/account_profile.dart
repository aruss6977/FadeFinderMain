import 'fighter.dart';

class AccountProfile {
  const AccountProfile({
    required this.username,
    required this.fighterName,
    required this.email,
    required this.age,
    required this.heightInches,
    required this.weightLbs,
    required this.style,
  });

  final String username;
  final String fighterName;
  final String email;
  final int? age;
  final int? heightInches;
  final double? weightLbs;
  final FightStyle? style;

  factory AccountProfile.fromMap(Map<String, dynamic> data) {
    final rawStyle = data['style'];
    FightStyle? style;
    for (final candidate in FightStyle.values) {
      if (rawStyle == candidate.name || rawStyle == candidate.label) {
        style = candidate;
        break;
      }
    }
    return AccountProfile(
      username: (data['name'] as String?)?.trim() ?? '',
      fighterName: (data['fighterName'] as String?)?.trim() ?? '',
      email: (data['email'] as String?)?.trim() ?? '',
      age: (data['age'] as num?)?.toInt(),
      heightInches: (data['heightInches'] as num?)?.toInt(),
      weightLbs: (data['weightLbs'] as num?)?.toDouble(),
      style: style,
    );
  }

}
