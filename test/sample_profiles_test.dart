import 'package:flutter_test/flutter_test.dart';

import 'package:fade_finder/data/sample_profiles.dart';
import 'package:fade_finder/models/account_profile.dart';
import 'package:fade_finder/models/fighter.dart';

void main() {
  group('Sample account profiles', () {
    test('Each sample loads with complete profile information', () {
      for (final data in sampleProfiles) {
        final profile = AccountProfile.fromMap(data);

        expect(profile.username, isNotEmpty);
        expect(profile.fighterName, isNotEmpty);
        expect(profile.email, endsWith('@example.com'));
        expect(profile.age, greaterThan(0));
        expect(profile.heightInches, greaterThan(0));
        expect(profile.weightLbs, greaterThan(0));
        expect(profile.style, isNotNull);
      }
    });

    test('Sample usernames are unique and match their lookup keys', () {
      final usernames = sampleProfiles
          .map((data) => data['usernameKey'] as String)
          .toList();

      expect(usernames.toSet().length, usernames.length);

      for (final data in sampleProfiles) {
        expect(
          data['usernameKey'],
          (data['name'] as String).trim().toLowerCase(),
        );
      }
    });

    test('Stored style names map to the correct fighting styles', () {
      final expectedStyles = {
        'boxing': FightStyle.boxing,
        'wrestling': FightStyle.wrestling,
        'mma': FightStyle.mma,
      };

      for (final data in sampleProfiles) {
        final profile = AccountProfile.fromMap(data);

        expect(profile.style, expectedStyles[data['style']]);
      }
    });

    test('A profile without an optional style still loads', () {
      final data = Map<String, dynamic>.from(sampleProfiles.first);
      data.remove('style');

      final profile = AccountProfile.fromMap(data);

      expect(profile.style, isNull);
      expect(profile.username, 'demo_boxer');
    });

    test('Profiles accept integer or decimal Firestore numbers', () {
      final data = Map<String, dynamic>.from(sampleProfiles.first);

      data['age'] = 22.0;
      data['heightInches'] = 70.0;
      data['weightLbs'] = 155;

      final profile = AccountProfile.fromMap(data);

      expect(profile.age, 22);
      expect(profile.heightInches, 70);
      expect(profile.weightLbs, 155.0);
    });
  });
}