/// API keys are injected at build time so they never land in source control:
///
///   flutter run \
///     --dart-define=TMDB_API_KEY=your_tmdb_v3_key \
///     --dart-define=COMICVINE_API_KEY=your_comicvine_key
///
/// Both are optional. Without them the app runs on its bundled curated data.
class AppConfig {
  static const tmdbApiKey = String.fromEnvironment('TMDB_API_KEY');
  static const comicVineApiKey = String.fromEnvironment('COMICVINE_API_KEY');

  static bool get hasTmdb => tmdbApiKey.isNotEmpty;
  static bool get hasComicVine => comicVineApiKey.isNotEmpty;

  // api.tmdb.org is TMDB's official alias; some ISPs (e.g. Jio) block
  // api.themoviedb.org.
  static const tmdbBase = 'https://api.tmdb.org/3';
  static const tmdbImageBase = 'https://image.tmdb.org/t/p';

  /// Open-source superhero database (no key required).
  static const superheroAllUrl =
      'https://cdn.jsdelivr.net/gh/akabab/superhero-api@0.3.0/api/all.json';

  static const comicVineBase = 'https://comicvine.gamespot.com/api';

  static String tmdbImage(String? path, {String size = 'w500'}) =>
      path == null || path.isEmpty ? '' : '$tmdbImageBase/$size$path';
}
