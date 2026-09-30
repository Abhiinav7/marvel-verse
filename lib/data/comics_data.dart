import 'package:flutter/material.dart';

import 'models/comic.dart';

/// Essential Marvel story arcs, with the MCU projects they inspired.
final List<Comic> essentialComics = [
  Comic(
    title: 'The Infinity Gauntlet',
    subtitle: 'Jim Starlin • George Pérez',
    year: '1991',
    tieIn: 'Avengers: Infinity War',
    color: const Color(0xFF7B2FF7),
    description:
        'Thanos assembles all six Infinity Gems and erases half the '
        'universe to court Death. The blueprint for the Snap.',
  ),
  Comic(
    title: 'Civil War',
    subtitle: 'Mark Millar • Steve McNiven',
    year: '2006',
    tieIn: 'Captain America: Civil War',
    color: const Color(0xFF1E4FD8),
    description:
        'The Superhuman Registration Act divides heroes into two '
        'camps led by Iron Man and Captain America.',
  ),
  Comic(
    title: 'Secret Wars',
    subtitle: 'Jonathan Hickman • Esad Ribić',
    year: '2015',
    tieIn: 'Avengers: Secret Wars',
    color: const Color(0xFFE62429),
    description:
        'The multiverse collapses and Doctor Doom rebuilds '
        'what remains as Battleworld, ruled by God Emperor Doom.',
  ),
  Comic(
    title: 'Captain America: Winter Soldier',
    subtitle: 'Ed Brubaker • Steve Epting',
    year: '2005',
    tieIn: 'Captain America: The Winter Soldier',
    color: const Color(0xFF2B4A6F),
    description:
        'Bucky Barnes returns from the dead as a Soviet assassin '
        'with no memory of his best friend.',
  ),
  Comic(
    title: 'Planet Hulk',
    subtitle: 'Greg Pak • Carlo Pagulayan',
    year: '2006',
    tieIn: 'Thor: Ragnarok',
    color: const Color(0xFF2E9E44),
    description:
        'Exiled into space, Hulk becomes a gladiator on the planet '
        'Sakaar and rises to lead a revolution.',
  ),
  Comic(
    title: 'Extremis',
    subtitle: 'Warren Ellis • Adi Granov',
    year: '2005',
    tieIn: 'Iron Man 3',
    color: const Color(0xFFC8102E),
    description:
        'A techno-organic virus forces Tony Stark to rebuild '
        'himself — and redefine Iron Man.',
  ),
  Comic(
    title: 'House of M',
    subtitle: 'Brian Michael Bendis • Olivier Coipel',
    year: '2005',
    tieIn: 'WandaVision',
    color: const Color(0xFFA3001B),
    description:
        'Wanda Maximoff rewrites reality, then utters three words '
        'that change mutantkind forever.',
  ),
  Comic(
    title: 'Old Man Logan',
    subtitle: 'Mark Millar • Steve McNiven',
    year: '2008',
    tieIn: 'Deadpool & Wolverine',
    color: const Color(0xFFF2C200),
    description:
        'In a future where villains won, an aging Logan takes one '
        'last road trip across a ruined America.',
  ),
  Comic(
    title: 'Kang Dynasty',
    subtitle: 'Kurt Busiek • Alan Davis',
    year: '2001',
    tieIn: 'Multiverse Saga',
    color: const Color(0xFF00897B),
    description:
        'Kang the Conqueror invades Earth in the present and the '
        'Avengers must fight a war across time.',
  ),
  Comic(
    title: 'Ms. Marvel: No Normal',
    subtitle: 'G. Willow Wilson • Adrian Alphona',
    year: '2014',
    tieIn: 'Ms. Marvel',
    color: const Color(0xFF1E6FFF),
    description:
        'Jersey City teen Kamala Khan gains shape-shifting powers '
        'and takes up her idol\'s name.',
  ),
  Comic(
    title: 'Thor: God Butcher',
    subtitle: 'Jason Aaron • Esad Ribić',
    year: '2012',
    tieIn: 'Thor: Love and Thunder',
    color: const Color(0xFF3A7BD5),
    description:
        'Three Thors across time hunt Gorr, a being who has sworn '
        'to kill every god in existence.',
  ),
  Comic(
    title: 'Fantastic Four: Galactus Trilogy',
    subtitle: 'Stan Lee • Jack Kirby',
    year: '1966',
    tieIn: 'The Fantastic Four: First Steps',
    color: const Color(0xFF0D47A1),
    description:
        'The Silver Surfer heralds the arrival of Galactus, '
        'Devourer of Worlds.',
  ),
];
