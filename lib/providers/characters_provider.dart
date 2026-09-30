import 'package:flutter/foundation.dart';

import '../data/characters_data.dart';
import '../data/models/hero_character.dart';
import '../services/superhero_service.dart';

enum HeroFilter { all, heroes, villains }

class CharactersProvider extends ChangeNotifier {
  CharactersProvider(this._service);

  final SuperheroService _service;
  final List<HeroCharacter> _all = heroCharacters;

  bool loading = false;
  bool enriched = false;
  int currentIndex = 0;
  HeroFilter filter = HeroFilter.all;

  List<HeroCharacter> get all => _all;

  List<HeroCharacter> get visible => switch (filter) {
    HeroFilter.all => _all,
    HeroFilter.heroes => _all.where((h) => !h.isVillain).toList(),
    HeroFilter.villains => _all.where((h) => h.isVillain).toList(),
  };

  HeroCharacter get current =>
      visible[currentIndex.clamp(0, visible.length - 1)];

  HeroCharacter byId(String id) => _all.firstWhere((h) => h.id == id);

  List<HeroCharacter> search(String q) {
    final s = q.toLowerCase();
    return _all
        .where(
          (h) =>
              h.name.toLowerCase().contains(s) ||
              h.realName.toLowerCase().contains(s) ||
              h.actor.toLowerCase().contains(s),
        )
        .toList();
  }

  void setIndex(int i) {
    currentIndex = i;
    notifyListeners();
  }

  void setFilter(HeroFilter f) {
    filter = f;
    currentIndex = 0;
    notifyListeners();
  }

  Future<void> load() async {
    if (enriched || loading) return;
    loading = true;
    notifyListeners();
    try {
      await _service.enrich(_all);
      enriched = true;
    } catch (_) {
      // Curated bios still render; stats/portraits just stay empty.
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
