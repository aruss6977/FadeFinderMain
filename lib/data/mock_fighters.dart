import '../models/fighter.dart';

// Initial mock dataset for UI rendering and local testing.
// No network URLs are used here so cards load instantly without external dependencies.
final List<Fighter> mockFighters = [
  const Fighter(
    id: 'f1',
    name: 'Marcus Vance',
    age: 24,
    heightInches: 70, // 5'10"
    weightLbs: 154.0,
    style: FightStyle.boxing,
    bio: 'Southpaw amateur boxer with 4 years in the gym. Looking for technical sparring.',
  ),
  const Fighter(
    id: 'f2',
    name: 'Devon Reed',
    age: 27,
    heightInches: 68, // 5'8"
    weightLbs: 152.5,
    style: FightStyle.muayThai,
    bio: 'Muay Thai enthusiast. Fast hands and low kicks. Controlled pace only.',
  ),
  const Fighter(
    id: 'f3',
    name: 'Liam Chen',
    age: 22,
    heightInches: 73, // 6'1"
    weightLbs: 182.0,
    style: FightStyle.bjj,
    bio: 'Purple belt in Gi and No-Gi. Looking for clean submission grappling rounds.',
  ),
  const Fighter(
    id: 'f4',
    name: 'Carlos Mendez',
    age: 29,
    heightInches: 69, // 5'9"
    weightLbs: 168.0,
    style: FightStyle.mma,
    bio: 'Amateur MMA fighter working on cage control, wrestling defense, and transitions.',
  ),
];

// Initial mock matchup for Tab 2 (voting screen).
final List<Matchup> mockMatchups = [
  Matchup(
    id: 'm1',
    fighterA: mockFighters[0],
    fighterB: mockFighters[1],
    votesA: 34,
    votesB: 42,
  ),
];