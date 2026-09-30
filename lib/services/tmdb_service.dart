import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../data/models/mcu_title.dart';

class TmdbService {
  TmdbService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>?> _get(
    String path, [
    Map<String, String> query = const {},
  ]) async {
    if (!AppConfig.hasTmdb) return null;
    final uri = Uri.parse(
      '${AppConfig.tmdbBase}$path',
    ).replace(queryParameters: {'api_key': AppConfig.tmdbApiKey, ...query});
    final res = await _client.get(uri).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) return null;
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  /// Light lookup used for list posters/ratings.
  Future<Map<String, dynamic>?> summary(McuTitle t) async {
    final kind = t.isTv ? 'tv' : 'movie';
    final j = await _get('/$kind/${t.tmdbId}');
    if (j != null && _titleMatches(t, j)) return j;
    return _searchFallback(t);
  }

  /// Full details with cast and trailer.
  Future<Map<String, dynamic>?> details(McuTitle t) async {
    final kind = t.isTv ? 'tv' : 'movie';
    final append = t.isTv ? 'aggregate_credits,videos' : 'credits,videos';
    var j = await _get('/$kind/${t.tmdbId}', {'append_to_response': append});
    if (j != null && _titleMatches(t, j)) return j;
    final found = await _searchFallback(t);
    if (found == null) return null;
    return _get('/$kind/${found['id']}', {'append_to_response': append});
  }

  /// Guards against a stale hard-coded id by searching title + year.
  Future<Map<String, dynamic>?> _searchFallback(McuTitle t) async {
    final kind = t.isTv ? 'tv' : 'movie';
    final yearKey = t.isTv ? 'first_air_date_year' : 'year';
    final j = await _get('/search/$kind', {
      'query': t.title,
      yearKey: '${t.releaseDate.year}',
    });
    final results = j?['results'] as List?;
    if (results == null || results.isEmpty) return null;
    return results.first as Map<String, dynamic>;
  }

  bool _titleMatches(McuTitle t, Map<String, dynamic> j) {
    String norm(String s) =>
        s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final remote = norm((j['title'] ?? j['name'] ?? '') as String);
    final local = norm(t.title);
    return remote.contains(local.substring(0, local.length.clamp(0, 8))) ||
        local.contains(remote);
  }
}
