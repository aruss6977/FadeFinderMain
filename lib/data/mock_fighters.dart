import '../models/fighter.dart';

final List<Fighter> mockFighters = [
  const Fighter(
    id: 'f1',
    name: 'Marcus Vance',
    age: 24,
    heightInches: 70,
    weightLbs: 154.0,
    style: FightStyle.boxing,
    signatureMove: 'Check Hook & Pivot',
    powerRating: 91,
    record: '8-1-0',
    bio: 'Southpaw amateur boxer with crisp head movement and relentless counter-punching.',
  ),
  const Fighter(
    id: 'f2',
    name: 'Devon Reed',
    age: 27,
    heightInches: 68,
    weightLbs: 152.5,
    style: FightStyle.muayThai,
    signatureMove: 'Switch Kick to Body',
    powerRating: 88,
    record: '6-2-0',
    bio: 'Muay Thai stylist focused on clinch knees and thunderous low kicks.',
  ),
  const Fighter(
    id: 'f3',
    name: 'Liam Chen',
    age: 22,
    heightInches: 73,
    weightLbs: 182.0,
    style: FightStyle.bjj,
    signatureMove: 'Triangle Choke',
    powerRating: 94,
    record: '12-0-0',
    bio: 'Purple belt submission hunter. Known for guard pulls and quick transitions.',
  ),
  const Fighter(
    id: 'f4',
    name: 'Carlos Mendez',
    age: 29,
    heightInches: 69,
    weightLbs: 168.0,
    style: FightStyle.mma,
    signatureMove: 'Double Leg Takedown',
    powerRating: 86,
    record: '5-3-0',
    bio: 'Well-rounded cage scrapper. Controls distance with wrestling and ground-and-pound.',
  ),
];

final List<Matchup> mockMatchups = [
  Matchup(
    id: 'm1',
    fighterA: mockFighters[0],
    fighterB: mockFighters[1],
    votesA: 48,
    votesB: 52,
  ),
];