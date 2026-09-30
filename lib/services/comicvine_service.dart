import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../data/models/comic.dart';

/// Comic Vine replaces the retired Marvel Developer API as the source of
/// live comic issue data. Free key: https://comicvine.gamespot.com/api/
class ComicVineService {
  ComicVineService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Comic>> search(String query) async {
    if (!AppConfig.hasComicVine || query.trim().isEmpty) return [];
    final uri = Uri.parse('${AppConfig.comicVineBase}/search/').replace(
      queryParameters: {
        'api_key': AppConfig.comicVineApiKey,
        'format': 'json',
        'resources': 'issue',
        'query': query,
        'limit': '30',
        'field_list':
            'name,issue_number,volume,image,cover_date,deck,description,site_detail_url',
      },
    );
    // Comic Vine rejects requests without a custom User-Agent.
    final res = await _client
        .get(uri, headers: {'User-Agent': 'MarvelVerseFanApp/1.0'})
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) {
      throw Exception('Comic Vine returned ${res.statusCode}');
    }
    final results = (jsonDecode(res.body)['results'] as List?) ?? [];
    return results
        .cast<Map<String, dynamic>>()
        .map(Comic.fromComicVine)
        .toList();
  }
}
