import 'package:flutter/foundation.dart';

import '../core/config.dart';
import '../data/mcu_data.dart';
import '../data/models/mcu_title.dart';
import '../services/tmdb_service.dart';

enum WatchOrder { release, chronological }

enum TypeFilter { all, movies, series }

class MoviesProvider extends ChangeNotifier {
  MoviesProvider(this._tmdb);

  final TmdbService _tmdb;
  final List<McuTitle> _all = List.of(mcuTitles);

  bool loading = false;
  String? error;
  int? phaseFilter;
  TypeFilter typeFilter = TypeFilter.all;
  WatchOrder order = WatchOrder.release;

  bool get online => AppConfig.hasTmdb;

  List<McuTitle> get all => _sorted(_all, WatchOrder.release);

  List<McuTitle> get filtered {
    final list = _all.where((t) {
      if (phaseFilter != null && t.phase != phaseFilter) return false;
      return switch (typeFilter) {
        TypeFilter.all => true,
        TypeFilter.movies => t.type == TitleType.movie,
        TypeFilter.series => t.type != TitleType.movie,
      };
    }).toList();
    return _sorted(list, WatchOrder.release);
  }

  List<McuTitle> watchOrder(WatchOrder o) => _sorted(_all, o);

  List<McuTitle> _sorted(List<McuTitle> l, WatchOrder o) => List.of(l)
    ..sort(
      (a, b) => o == WatchOrder.release
          ? a.releaseDate.compareTo(b.releaseDate)
          : a.chronoOrder.compareTo(b.chronoOrder),
    );

  List<McuTitle> get upcoming =>
      all.where((t) => !t.isReleased).toList(growable: false);

  McuTitle? get nextRelease => upcoming.isEmpty ? null : upcoming.first;

  List<McuTitle> get topRated {
    final rated = _all.where((t) => t.rating != null && t.isReleased).toList()
      ..sort((a, b) => b.rating!.compareTo(a.rating!));
    return rated.take(10).toList();
  }

  List<McuTitle> get latest =>
      all.where((t) => t.isReleased).toList().reversed.take(10).toList();

  List<McuTitle> search(String q) {
    final s = q.toLowerCase();
    return all.where((t) => t.title.toLowerCase().contains(s)).toList();
  }

  McuTitle byId(String id) => _all.firstWhere((t) => t.id == id);

  void setPhase(int? p) {
    phaseFilter = p;
    notifyListeners();
  }

  void setType(TypeFilter t) {
    typeFilter = t;
    notifyListeners();
  }

  void setOrder(WatchOrder o) {
    order = o;
    notifyListeners();
  }

  /// Fetches posters/ratings for every title, a few at a time.
  Future<void> loadSummaries() async {
    if (!online || loading) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      const batch = 6;
      for (var i = 0; i < _all.length; i += batch) {
        final chunk = _all.skip(i).take(batch);
        await Future.wait(
          chunk.map((t) async {
            try {
              final j = await _tmdb.summary(t);
              if (j != null) t.applyTmdb(j);
            } catch (_) {
              /* keep curated data for this title */
            }
          }),
        );
        notifyListeners();
      }
    } catch (e) {
      error = 'Could not reach TMDB. Showing offline data.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetails(McuTitle t) async {
    if (!online || t.detailsLoaded) return;
    try {
      final j = await _tmdb.details(t);
      if (j != null) {
        t.applyTmdb(j);
        t.detailsLoaded = true;
      }
    } catch (_) {
      // Detail screen falls back to curated data.
    }
    notifyListeners();
  }
}
