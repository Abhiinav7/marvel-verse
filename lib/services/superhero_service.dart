import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../data/models/hero_character.dart';

/// Reads the open-source akabab/superhero-api dataset (no key needed) and
/// merges comic-canon stats and portraits into the curated MCU characters.
class SuperheroService {
  SuperheroService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> enrich(List<HeroCharacter> heroes) async {
    final res = await _client
        .get(Uri.parse(AppConfig.superheroAllUrl))
        .timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) return;
    final all = (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
    // The dataset's `publisher` field sometimes holds an alter ego
    // (e.g. "Binary"), so only rule out known non-Marvel publishers.
    const other = {'DC Comics', 'Dark Horse Comics', 'Image Comics'};
    final marvel = all.where(
      (h) => !other.contains(h['biography']?['publisher']),
    );

    for (final hero in heroes) {
      final target = (hero.apiName ?? hero.name).toLowerCase();
      final candidates = marvel.where(
        (h) => (h['name'] as String).toLowerCase() == target,
      );
      if (candidates.isEmpty) continue;
      final surname = hero.realName.split(' ').last.toLowerCase();
      final match = candidates.firstWhere(
        (h) => ((h['biography']?['fullName'] ?? '') as String)
            .toLowerCase()
            .contains(surname),
        orElse: () => candidates.first,
      );
      _apply(hero, match);
    }
  }

  void _apply(HeroCharacter hero, Map<String, dynamic> j) {
    hero.imageUrl = j['images']?['lg'] ?? j['images']?['md'];
    final stats = (j['powerstats'] as Map?) ?? {};
    hero.powerStats = {
      for (final e in stats.entries) e.key as String: (e.value as num).toInt(),
    };
    final bio = j['biography'] as Map? ?? {};
    hero.firstComic = bio['firstAppearance'];
    hero.alignment = bio['alignment'];
    hero.aliases = ((bio['aliases'] as List?) ?? [])
        .cast<String>()
        .where((a) => a != '-')
        .take(4)
        .toList();
    final app = j['appearance'] as Map? ?? {};
    hero.height = (app['height'] as List?)?.last;
    hero.weight = (app['weight'] as List?)?.last;
  }
}
