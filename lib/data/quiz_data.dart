class QuizQuestion {
  const QuizQuestion(this.question, this.options, this.answer, this.fact);

  final String question;
  final List<String> options;
  final int answer;
  final String fact;
}

const quizQuestions = <QuizQuestion>[
  QuizQuestion(
    'Which Infinity Stone was hidden on Vormir?',
    ['Mind', 'Soul', 'Time', 'Reality'],
    1,
    'The Soul Stone demands a sacrifice of someone you love.',
  ),
  QuizQuestion(
    'What is the name of Thor\'s axe forged in Infinity War?',
    ['Jarnbjorn', 'Gungnir', 'Stormbreaker', 'Hofund'],
    2,
    'Stormbreaker was forged in Nidavellir with Eitri\'s help.',
  ),
  QuizQuestion(
    'What does S.H.I.E.L.D. stand for in the MCU?',
    [
      'Strategic Homeland Intervention, Enforcement and Logistics Division',
      'Supreme Headquarters International Espionage Law-Enforcement Division',
      'Strategic Hazard Intervention Espionage Logistics Directorate',
      'Special Heroes Intelligence and Enforcement League Division',
    ],
    0,
    'Agent Coulson spells it out in Iron Man (2008).',
  ),
  QuizQuestion(
    'Which film was the first to be released in Phase Four?',
    ['Black Widow', 'WandaVision', 'Shang-Chi', 'Eternals'],
    1,
    'WandaVision premiered in January 2021, before Black Widow.',
  ),
  QuizQuestion(
    'What is Captain America\'s shield made of?',
    ['Adamantium', 'Uru', 'Vibranium', 'Carbonadium'],
    2,
    'Howard Stark built it from Wakandan vibranium.',
  ),
  QuizQuestion(
    'How many futures did Doctor Strange view?',
    ['1,400,605', '14,000,605', '14,605', '140,000,605'],
    1,
    'They won in exactly one.',
  ),
  QuizQuestion(
    'What is the name of Tony Stark\'s first AI assistant?',
    ['FRIDAY', 'EDITH', 'JARVIS', 'KAREN'],
    2,
    'J.A.R.V.I.S. later became part of Vision.',
  ),
  QuizQuestion(
    'Which planet is Gamora\'s adoptive father from?',
    ['Xandar', 'Titan', 'Sakaar', 'Ego'],
    1,
    'Thanos is from Titan, the ruined moon seen in Infinity War.',
  ),
  QuizQuestion(
    'In which city is Wakanda\'s outreach centre opened?',
    ['New York', 'Oakland', 'Lagos', 'London'],
    1,
    'T\'Challa buys the building where his father killed N\'Jobu.',
  ),
  QuizQuestion(
    'Who is the "Scarlet Witch"\'s twin brother?',
    ['Pietro', 'Vision', 'Tommy', 'Billy'],
    0,
    'Pietro Maximoff (Quicksilver) died in Sokovia.',
  ),
  QuizQuestion(
    'What is the TVA?',
    [
      'Time Variance Authority',
      'Temporal Validation Agency',
      'Timeline Vigilance Association',
      'Tesseract Verification Authority',
    ],
    0,
    'It polices the Sacred Timeline in Loki.',
  ),
  QuizQuestion(
    'Which hero says "I can do this all day"?',
    ['Iron Man', 'Spider-Man', 'Captain America', 'Hawkeye'],
    2,
    'Steve says it in 1943 and again to himself in Endgame.',
  ),
];
