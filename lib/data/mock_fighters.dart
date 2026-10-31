import '../models/fighter.dart';

// global in-memory ledger tracking sparring challenges issued during swipe sessions
// shared directly between match_screen (which appends) and profile_screen (which renders and removes)
final List<Fighter> activeChallenges = [];

// static seed catalog of combat sports athletes matching domain model definitions
// uses compile-time const constructors to minimize runtime memory footprint
final List<Fighter> mockFighters = [
  const Fighter(
    id: 'f1',
    name: 'Marcus "The Anvil" Vance',
    age: 26,
    heightInches: 71,
    weightLbs: 155,
    style: FightStyle.boxing,
    signatureMove: 'Overhand Right Counter',
    bio: 'southpaw counterpuncher with heavy hands and relentless pocket pressure.',
    powerRating: 92,
    record: '12-2-0 (8 KO)',
  ),
  const Fighter(
    id: 'f2',
    name: 'Elena "Anaconda" Rostova',
    age: 24,
    heightInches: 65,
    weightLbs: 125,
    style: FightStyle.bjj,
    signatureMove: 'Flying Armbar',
    bio: 'ibjjf world medalist specializing in leg locks and guard transitions.',
    powerRating: 89,
    record: '24-3-0 (19 SUB)',
  ),
  const Fighter(
    id: 'f3',
    name: 'Somchai "Iron Shin" Prasert',
    age: 28,
    heightInches: 68,
    weightLbs: 145,
    style: FightStyle.muayThai,
    signatureMove: 'Switch Left Middle Kick',
    bio: 'stadium-trained nak muay with devastating clinch knees and sweep timing.',
    powerRating: 94,
    record: '45-10-2 (28 KO)',
  ),
  const Fighter(
    id: 'f4',
    name: 'Colt "The Freight Train" Miller',
    age: 23,
    heightInches: 74,
    weightLbs: 205,
    style: FightStyle.wrestling,
    signatureMove: 'High Crotch to Blast Double',
    bio: 'ncaa division i all-american with explosive level changes and top control ride.',
    powerRating: 91,
    record: '18-4-0 (11 TKO)',
  ),
  const Fighter(
    id: 'f5',
    name: 'Darius "Apex" Sterling',
    age: 29,
    heightInches: 72,
    weightLbs: 170,
    style: FightStyle.mma,
    signatureMove: 'Spinning Back Kick to Guillotine',
    bio: 'well-rounded mixed martial artist comfortable in all ranges of combat.',
    powerRating: 95,
    record: '15-1-0 (9 KO, 4 SUB)',
  ),
];

// static seed matchups utilized by the arena vote screen
// points directly to mock_fighters instances by reference to preserve single-source data
final List<Matchup> mockMatchups = [
  Matchup(
    id: 'm1',
    fighterA: mockFighters[0],
    fighterB: mockFighters[2],
    votesA: 142,
    votesB: 98,
  ),
  Matchup(
    id: 'm2',
    fighterA: mockFighters[3],
    fighterB: mockFighters[4],
    votesA: 87,
    votesB: 114,
  ),
];