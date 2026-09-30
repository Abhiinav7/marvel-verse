import 'package:flutter/foundation.dart';

import '../data/quiz_data.dart';

class QuizProvider extends ChangeNotifier {
  static const roundSize = 8;

  List<QuizQuestion> questions = [];
  int index = 0;
  int score = 0;
  int? selected;

  QuizProvider() {
    restart();
  }

  QuizQuestion get current => questions[index];
  bool get answered => selected != null;
  bool get finished => index >= questions.length;

  void restart() {
    questions = (List.of(quizQuestions)..shuffle()).take(roundSize).toList();
    index = 0;
    score = 0;
    selected = null;
    notifyListeners();
  }

  void answer(int option) {
    if (answered) return;
    selected = option;
    if (option == current.answer) score++;
    notifyListeners();
  }

  void next() {
    index++;
    selected = null;
    notifyListeners();
  }
}
