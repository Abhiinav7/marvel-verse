import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _watched = 'watched_ids';
  static const _favTitles = 'fav_titles';
  static const _favHeroes = 'fav_heroes';
  static const _bestQuiz = 'best_quiz';

  late final SharedPreferences _prefs;

  Future<void> init() async => _prefs = await SharedPreferences.getInstance();

  Set<String> get watched => (_prefs.getStringList(_watched) ?? []).toSet();
  Set<String> get favTitles => (_prefs.getStringList(_favTitles) ?? []).toSet();
  Set<String> get favHeroes => (_prefs.getStringList(_favHeroes) ?? []).toSet();
  int get bestQuiz => _prefs.getInt(_bestQuiz) ?? 0;

  Future<void> saveWatched(Set<String> ids) =>
      _prefs.setStringList(_watched, ids.toList());
  Future<void> saveFavTitles(Set<String> ids) =>
      _prefs.setStringList(_favTitles, ids.toList());
  Future<void> saveFavHeroes(Set<String> ids) =>
      _prefs.setStringList(_favHeroes, ids.toList());
  Future<void> saveBestQuiz(int v) => _prefs.setInt(_bestQuiz, v);
}
