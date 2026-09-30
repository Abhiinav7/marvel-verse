import 'package:flutter/foundation.dart';

import '../services/storage_service.dart';

/// Per-user data persisted on device: watch progress, favourites, quiz score.
class UserProvider extends ChangeNotifier {
  UserProvider(this._storage)
    : _watched = _storage.watched,
      _favTitles = _storage.favTitles,
      _favHeroes = _storage.favHeroes,
      _bestQuiz = _storage.bestQuiz;

  final StorageService _storage;
  final Set<String> _watched;
  final Set<String> _favTitles;
  final Set<String> _favHeroes;
  int _bestQuiz;

  Set<String> get watched => _watched;
  Set<String> get favTitles => _favTitles;
  Set<String> get favHeroes => _favHeroes;
  int get bestQuiz => _bestQuiz;

  bool isWatched(String id) => _watched.contains(id);
  bool isFavTitle(String id) => _favTitles.contains(id);
  bool isFavHero(String id) => _favHeroes.contains(id);

  void toggleWatched(String id) {
    _watched.contains(id) ? _watched.remove(id) : _watched.add(id);
    _storage.saveWatched(_watched);
    notifyListeners();
  }

  void toggleFavTitle(String id) {
    _favTitles.contains(id) ? _favTitles.remove(id) : _favTitles.add(id);
    _storage.saveFavTitles(_favTitles);
    notifyListeners();
  }

  void toggleFavHero(String id) {
    _favHeroes.contains(id) ? _favHeroes.remove(id) : _favHeroes.add(id);
    _storage.saveFavHeroes(_favHeroes);
    notifyListeners();
  }

  void submitQuizScore(int score) {
    if (score <= _bestQuiz) return;
    _bestQuiz = score;
    _storage.saveBestQuiz(score);
    notifyListeners();
  }
}
