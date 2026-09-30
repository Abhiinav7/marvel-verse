import 'package:flutter/foundation.dart';

import '../core/config.dart';
import '../data/comics_data.dart';
import '../data/models/comic.dart';
import '../services/comicvine_service.dart';

class ComicsProvider extends ChangeNotifier {
  ComicsProvider(this._service);

  final ComicVineService _service;

  final List<Comic> essentials = essentialComics;
  List<Comic> results = [];
  bool loading = false;
  String? error;
  String lastQuery = '';

  bool get online => AppConfig.hasComicVine;

  Future<void> search(String query) async {
    lastQuery = query;
    if (!online) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      results = await _service.search(query);
      if (results.isEmpty) error = 'No issues found for "$query".';
    } catch (e) {
      results = [];
      error = 'Comic search failed. Check your connection or API key.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
