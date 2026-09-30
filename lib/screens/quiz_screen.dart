import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/quiz_provider.dart';
import '../providers/user_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<QuizProvider>().restart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('MCU TRIVIA')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1B1035), MarvelColors.bg],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: quiz.questions.isEmpty
              ? const SizedBox.shrink()
              : quiz.finished
              ? _Results(key: const ValueKey('results'), quiz: quiz)
              : _Question(key: ValueKey(quiz.index), quiz: quiz),
        ),
      ),
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({super.key, required this.quiz});
  final QuizProvider quiz;

  @override
  Widget build(BuildContext context) {
    final q = quiz.current;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Text(
              'QUESTION ${quiz.index + 1}/${quiz.questions.length}',
              style: AppTheme.display(20, color: MarvelColors.gold),
            ),
            const Spacer(),
            Text('SCORE ${quiz.score}', style: AppTheme.display(20)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: (quiz.index + 1) / quiz.questions.length,
            minHeight: 6,
            backgroundColor: Colors.white12,
            valueColor: const AlwaysStoppedAnimation(MarvelColors.red),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          q.question,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 24),
        for (var i = 0; i < q.options.length; i++) _option(context, i),
        if (quiz.answered) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: MarvelColors.blue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_rounded, color: MarvelColors.gold),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    q.fact,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: MarvelColors.red,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              quiz.next();
              if (quiz.finished) {
                context.read<UserProvider>().submitQuizScore(quiz.score);
              }
            },
            child: Text(
              quiz.index + 1 == quiz.questions.length ? 'SEE RESULTS' : 'NEXT',
            ),
          ),
        ],
      ],
    );
  }

  Widget _option(BuildContext context, int i) {
    final q = quiz.current;
    Color border = Colors.white24;
    Color fill = MarvelColors.surface;
    IconData? icon;
    if (quiz.answered) {
      if (i == q.answer) {
        border = MarvelColors.green;
        fill = MarvelColors.green.withValues(alpha: 0.2);
        icon = Icons.check_circle_rounded;
      } else if (i == quiz.selected) {
        border = MarvelColors.red;
        fill = MarvelColors.red.withValues(alpha: 0.2);
        icon = Icons.cancel_rounded;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => quiz.answer(i),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border, width: 1.5),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.white10,
                child: Text(
                  String.fromCharCode(65 + i),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(q.options[i], style: const TextStyle(fontSize: 15)),
              ),
              if (icon != null) Icon(icon, color: border),
            ],
          ),
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({super.key, required this.quiz});
  final QuizProvider quiz;

  String get _rank {
    final pct = quiz.score / quiz.questions.length;
    if (pct == 1) return 'SORCERER SUPREME';
    if (pct >= 0.75) return 'AVENGER';
    if (pct >= 0.5) return 'S.H.I.E.L.D. AGENT';
    return 'NPC IN SOKOVIA';
  }

  @override
  Widget build(BuildContext context) {
    final best = context.watch<UserProvider>().bestQuiz;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_rounded,
              size: 90,
              color: MarvelColors.gold,
            ),
            Text(
              '${quiz.score} / ${quiz.questions.length}',
              style: AppTheme.display(64),
            ),
            Text(_rank, style: AppTheme.display(30, color: MarvelColors.gold)),
            const SizedBox(height: 6),
            Text(
              'Best: $best',
              style: const TextStyle(color: MarvelColors.textDim),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: MarvelColors.red,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
              ),
              onPressed: quiz.restart,
              icon: const Icon(Icons.replay_rounded),
              label: const Text('PLAY AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}
