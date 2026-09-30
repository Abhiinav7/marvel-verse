import 'package:flutter/material.dart';

import 'models/hero_character.dart';

/// Each hero streams a fan-made model from Sketchfab (see
/// [HeroCharacter.sketchfab]). These stand-ins are only used for a hero
/// without one. To bundle your own .glb instead, drop it into
/// `assets/models/` and set [HeroCharacter.modelUrl].
const standInModel =
    'https://modelviewer.dev/shared-assets/models/Astronaut.glb';
const standInRobot =
    'https://modelviewer.dev/shared-assets/models/RobotExpressive.glb';

final List<HeroCharacter> heroCharacters = [
  HeroCharacter(
    id: 'iron-man',
    sketchfab: SketchfabModel(
      'd9d09b4b596c42f08da4ca6d82c38cb3',
      'Iron Man THE AVENGERS',
      'YE YE',
    ),
    name: 'Iron Man',
    realName: 'Tony Stark',
    actor: 'Robert Downey Jr.',
    color: const Color(0xFFC8102E),
    accent: const Color(0xFFF7B32B),
    team: 'Avengers',
    firstMcu: 'Iron Man (2008)',
    powers: [
      'Powered armor',
      'Genius intellect',
      'Repulsor tech',
      'Nanotech suit',
    ],
    bio:
        'Genius, billionaire, philanthropist. Tony Stark built his first suit '
        'in a cave and went on to found the Avengers — and ultimately snapped '
        'Thanos out of existence.',
  ),
  HeroCharacter(
    id: 'captain-america',
    sketchfab: SketchfabModel(
      '88f14d5e9c724f5abc7d30a934833d9b',
      'Captain America',
      'danielmclogan',
    ),
    name: 'Captain America',
    realName: 'Steve Rogers',
    actor: 'Chris Evans',
    color: const Color(0xFF1E4FD8),
    accent: const Color(0xFFE62429),
    team: 'Avengers',
    firstMcu: 'Captain America: The First Avenger (2011)',
    powers: [
      'Super-soldier serum',
      'Vibranium shield',
      'Master tactician',
      'Worthy of Mjolnir',
    ],
    bio:
        'A kid from Brooklyn who never backed down from a fight. The '
        'super-soldier serum made him strong; his character made him a leader.',
  ),
  HeroCharacter(
    id: 'thor',
    sketchfab: SketchfabModel(
      '0e85573c69dc4891b51ccb41ebb3b813',
      'Thor Odinson',
      'Tigerar1',
    ),
    name: 'Thor',
    realName: 'Thor Odinson',
    actor: 'Chris Hemsworth',
    color: const Color(0xFF3A7BD5),
    accent: const Color(0xFF00E5FF),
    team: 'Avengers',
    firstMcu: 'Thor (2011)',
    powers: [
      'God of Thunder',
      'Mjolnir & Stormbreaker',
      'Super strength',
      'Longevity',
    ],
    bio:
        'Prince of Asgard and God of Thunder. Thor has lost his home, his '
        'family and his hammer — and keeps getting back up.',
  ),
  HeroCharacter(
    id: 'hulk',
    sketchfab: SketchfabModel(
      '1379a9de81b7426ea4ee71ff4c126e80',
      'Hulk | Marvel Rivals',
      'King_45',
    ),
    name: 'Hulk',
    realName: 'Bruce Banner',
    actor: 'Mark Ruffalo',
    color: const Color(0xFF2E9E44),
    accent: const Color(0xFF7B2FF7),
    team: 'Avengers',
    firstMcu: 'The Incredible Hulk (2008)',
    powers: [
      'Limitless strength',
      'Regeneration',
      'Gamma radiation',
      'Genius (Banner)',
    ],
    bio:
        'A brilliant scientist whose gamma experiment gave him a green, '
        'rage-powered alter ego. Eventually, Banner and Hulk learned to share.',
  ),
  HeroCharacter(
    id: 'black-widow',
    sketchfab: SketchfabModel(
      '2a995a158e644694a19772f5bcdfaea3',
      'Black Widow (Textured)',
      '3D MODELS',
    ),
    name: 'Black Widow',
    realName: 'Natasha Romanoff',
    actor: 'Scarlett Johansson',
    color: const Color(0xFF1A1A1A),
    accent: const Color(0xFFE62429),
    team: 'Avengers',
    firstMcu: 'Iron Man 2 (2010)',
    powers: ['Master spy', 'Hand-to-hand combat', 'Widow\'s Bite', 'Tactician'],
    bio:
        'Trained in the Red Room, Natasha turned her ledger of red into a '
        'life defending others. She gave everything on Vormir.',
  ),
  HeroCharacter(
    id: 'spider-man',
    sketchfab: SketchfabModel(
      'e7a0ffa3e3174634bdb1edc08ac0bd7c',
      'Spider-Man',
      'CipherFilms',
    ),
    name: 'Spider-Man',
    realName: 'Peter Parker',
    actor: 'Tom Holland',
    color: const Color(0xFFD7192D),
    accent: const Color(0xFF1E4FD8),
    team: 'Avengers',
    firstMcu: 'Captain America: Civil War (2016)',
    powers: [
      'Spider-sense',
      'Wall-crawling',
      'Web-shooters',
      'Superhuman agility',
    ],
    bio:
        'Your friendly neighbourhood Spider-Man. A Queens teenager who '
        'learned that with great power comes great responsibility.',
  ),
  HeroCharacter(
    id: 'black-panther',
    sketchfab: SketchfabModel(
      'e73e355bdafa4fbeae0e42fca8c34bcc',
      'Black Panther',
      'Lil_CJ_5888',
      distance: 1.3,
    ),
    name: 'Black Panther',
    realName: 'T\'Challa',
    apiName: 'Black Panther',
    actor: 'Chadwick Boseman',
    color: const Color(0xFF2B1B4A),
    accent: const Color(0xFFB57BFF),
    team: 'Wakanda',
    firstMcu: 'Captain America: Civil War (2016)',
    powers: [
      'Heart-Shaped Herb',
      'Vibranium suit',
      'Kinetic absorption',
      'King of Wakanda',
    ],
    bio:
        'King of the hidden, technologically advanced nation of Wakanda. '
        'Wakanda Forever.',
  ),
  HeroCharacter(
    id: 'doctor-strange',
    sketchfab: SketchfabModel(
      'f45da068ab5943d290de77eab4986ed6',
      'Doctor Strange(Textured)(Rigged)',
      '3D MODELS',
    ),
    name: 'Doctor Strange',
    realName: 'Stephen Strange',
    actor: 'Benedict Cumberbatch',
    color: const Color(0xFF1B3A8C),
    accent: const Color(0xFFFF7A00),
    team: 'Masters of the Mystic Arts',
    firstMcu: 'Doctor Strange (2016)',
    powers: [
      'Sorcery',
      'Sling ring portals',
      'Cloak of Levitation',
      'Astral projection',
    ],
    bio:
        'Former neurosurgeon turned Sorcerer Supreme. He looked at 14,000,605 '
        'futures and found the one where we win.',
  ),
  HeroCharacter(
    id: 'scarlet-witch',
    sketchfab: SketchfabModel(
      'd436695afbd14668bece641c7c6f0bfd',
      'Wanda Maximoff - Scarlet Witch',
      'wilsonghm99',
    ),
    name: 'Scarlet Witch',
    realName: 'Wanda Maximoff',
    actor: 'Elizabeth Olsen',
    color: const Color(0xFFA3001B),
    accent: const Color(0xFFFF4D8D),
    team: 'Avengers',
    firstMcu: 'Avengers: Age of Ultron (2015)',
    powers: ['Chaos magic', 'Telekinesis', 'Reality warping', 'Telepathy'],
    bio:
        'Empowered by the Mind Stone, Wanda became one of the most powerful '
        'beings in the multiverse — and one of its most tragic.',
  ),
  HeroCharacter(
    id: 'captain-marvel',
    sketchfab: SketchfabModel(
      '69fcbdbdcb744f6cbc44951913c5296a',
      'Captain Marvel(Textured)(Rigged)',
      '3D MODELS',
    ),
    name: 'Captain Marvel',
    realName: 'Carol Danvers',
    actor: 'Brie Larson',
    color: const Color(0xFF1E3A8A),
    accent: const Color(0xFFF7B32B),
    team: 'Avengers',
    firstMcu: 'Captain Marvel (2019)',
    powers: ['Photon blasts', 'Flight', 'Binary form', 'Energy absorption'],
    bio:
        'An Air Force pilot supercharged by the Tesseract\'s energy. Higher, '
        'further, faster.',
  ),
  HeroCharacter(
    id: 'star-lord',
    sketchfab: SketchfabModel(
      '14e35f7da75045adb2d345f45397af92',
      'Star Lord UCM',
      'YE YE',
    ),
    name: 'Star-Lord',
    realName: 'Peter Quill',
    actor: 'Chris Pratt',
    color: const Color(0xFF7A2E0E),
    accent: const Color(0xFF00E5FF),
    team: 'Guardians of the Galaxy',
    firstMcu: 'Guardians of the Galaxy (2014)',
    powers: ['Element guns', 'Jet boots', 'Celestial heritage', 'Awesome Mix'],
    bio:
        'Abducted from Earth as a kid, Peter Quill grew up an outlaw and '
        'became leader of the galaxy\'s most unlikely heroes.',
  ),
  HeroCharacter(
    id: 'groot',
    sketchfab: SketchfabModel(
      'df57bc80f7b047f2a67017ad628c64c2',
      'Baby Groot',
      'Aran',
    ),
    name: 'Groot',
    realName: 'Groot',
    actor: 'Vin Diesel (voice)',
    color: const Color(0xFF5B3A1E),
    accent: const Color(0xFF2ECC71),
    team: 'Guardians of the Galaxy',
    firstMcu: 'Guardians of the Galaxy (2014)',
    powers: ['Regeneration', 'Plant growth', 'Size alteration', 'I am Groot'],
    bio:
        'A tree-like Flora colossus with a vocabulary of three words and a '
        'heart bigger than the galaxy.',
    modelUrl: standInRobot,
  ),
  HeroCharacter(
    id: 'ant-man',
    sketchfab: SketchfabModel(
      '5fb3b51ea20b4cdaa3d762e32a6496e6',
      'Marvel Ant Man Fan Art',
      'Tom Hart',
      distance: 0.65,
    ),
    name: 'Ant-Man',
    realName: 'Scott Lang',
    apiName: 'Ant-Man II',
    actor: 'Paul Rudd',
    color: const Color(0xFF9E1B1B),
    accent: const Color(0xFF9A9AB0),
    team: 'Avengers',
    firstMcu: 'Ant-Man (2015)',
    powers: ['Pym Particles', 'Shrinking', 'Giant-Man', 'Ant communication'],
    bio:
        'A reformed thief who found the key to time travel in the Quantum '
        'Realm — by accident.',
  ),
  HeroCharacter(
    id: 'wolverine',
    sketchfab: SketchfabModel(
      '9242cdc32c814e0fa1b0a613c7379dbe',
      'Wolverine(Textured)(Rigged)',
      '3D MODELS',
    ),
    name: 'Wolverine',
    realName: 'Logan',
    actor: 'Hugh Jackman',
    color: const Color(0xFFF2C200),
    accent: const Color(0xFF1E4FD8),
    team: 'X-Men',
    firstMcu: 'Deadpool & Wolverine (2024)',
    powers: [
      'Adamantium claws',
      'Healing factor',
      'Heightened senses',
      'Longevity',
    ],
    bio:
        'The best there is at what he does. A mutant with an unbreakable '
        'skeleton and a temper to match.',
  ),
  HeroCharacter(
    id: 'deadpool',
    sketchfab: SketchfabModel(
      '0894b38ab97740a9a083c783299f52a5',
      'Deadpool Movie Model',
      'CGI DUDE',
    ),
    name: 'Deadpool',
    realName: 'Wade Wilson',
    actor: 'Ryan Reynolds',
    color: const Color(0xFFB00020),
    accent: const Color(0xFF1A1A1A),
    team: 'X-Force (sort of)',
    firstMcu: 'Deadpool & Wolverine (2024)',
    powers: [
      'Healing factor',
      'Katanas',
      'Breaks the fourth wall',
      'Chimichangas',
    ],
    bio:
        'The Merc with a Mouth. Unkillable, unfiltered and fully aware he\'s '
        'in a movie — and an app.',
  ),
  HeroCharacter(
    id: 'thanos',
    sketchfab: SketchfabModel(
      '33a76fa5ad654715acc2eef792f6832a',
      'Thanos 4K Retextured',
      'JonnyMANSON',
    ),
    name: 'Thanos',
    realName: 'Thanos',
    actor: 'Josh Brolin',
    color: const Color(0xFF5B3A8C),
    accent: const Color(0xFFF7B32B),
    team: 'Black Order',
    firstMcu: 'The Avengers (2012)',
    isVillain: true,
    powers: [
      'Titan physiology',
      'Infinity Gauntlet',
      'Master strategist',
      'Inevitable',
    ],
    bio:
        'The Mad Titan. He believed halving all life would save the universe '
        '— and he snapped.',
  ),
  HeroCharacter(
    id: 'loki',
    sketchfab: SketchfabModel(
      'c8aa72708788460abc2c813e32fc6219',
      'Loki THE AVENGERS MR',
      'YE YE',
    ),
    name: 'Loki',
    realName: 'Loki Laufeyson',
    actor: 'Tom Hiddleston',
    color: const Color(0xFF0F5C3A),
    accent: const Color(0xFFF7B32B),
    team: 'TVA',
    firstMcu: 'Thor (2011)',
    isVillain: true,
    powers: ['Illusions', 'Shape-shifting', 'Sorcery', 'Silver tongue'],
    bio:
        'God of Mischief turned God of Stories. From villain to the one '
        'holding the Multiverse together.',
  ),
];
