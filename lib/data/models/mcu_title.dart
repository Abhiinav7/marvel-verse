enum TitleType { movie, series, special }

enum Saga { infinity, multiverse }

/// A curated MCU entry. The static fields are bundled with the app; the
/// nullable "enriched" fields are filled from TMDB when an API key is present.
class McuTitle {
  McuTitle({
    required this.id,
    required this.title,
    required this.tmdbId,
    required this.type,
    required this.phase,
    required this.releaseDate,
    required this.chronoOrder,
    required this.tagline,
    this.timelineYear,
    this.seasons,
  });

  /// Stable local id (slug), used for watch-progress storage.
  final String id;
  final String title;
  final int tmdbId;
  final TitleType type;
  final int phase;
  final DateTime releaseDate;

  /// Position in the in-universe (chronological) timeline.
  final int chronoOrder;
  final String tagline;
  final String? timelineYear;
  final String? seasons;

  Saga get saga => phase <= 3 ? Saga.infinity : Saga.multiverse;
  bool get isReleased => releaseDate.isBefore(DateTime.now());
  bool get isTv => type == TitleType.series;

  // ---- Enriched from TMDB ----
  String? overview;
  String? posterPath;
  String? backdropPath;
  double? rating;
  int? voteCount;
  int? runtime;
  List<String> genres = const [];
  List<CastMember> cast = const [];
  String? trailerKey;
  int? budget;
  int? revenue;
  int? numberOfEpisodes;
  bool detailsLoaded = false;

  void applyTmdb(Map<String, dynamic> j) {
    overview = (j['overview'] as String?)?.isNotEmpty == true
        ? j['overview']
        : overview;
    posterPath = j['poster_path'] ?? posterPath;
    backdropPath = j['backdrop_path'] ?? backdropPath;
    rating = (j['vote_average'] as num?)?.toDouble() ?? rating;
    voteCount = j['vote_count'] ?? voteCount;
    runtime =
        j['runtime'] ??
        ((j['episode_run_time'] as List?)?.isNotEmpty == true
            ? j['episode_run_time'][0]
            : runtime);
    budget = j['budget'] ?? budget;
    revenue = j['revenue'] ?? revenue;
    numberOfEpisodes = j['number_of_episodes'] ?? numberOfEpisodes;
    final g = j['genres'] as List?;
    if (g != null) genres = g.map((e) => e['name'] as String).toList();

    final credits = j['credits'] ?? j['aggregate_credits'];
    final castJson = credits?['cast'] as List?;
    if (castJson != null) {
      cast = castJson.take(15).map((c) => CastMember.fromJson(c)).toList();
    }
    final videos = j['videos']?['results'] as List?;
    if (videos != null) {
      final yt = videos.where((v) => v['site'] == 'YouTube').toList();
      final trailer = yt.firstWhere(
        (v) => v['type'] == 'Trailer',
        orElse: () => yt.isNotEmpty ? yt.first : null,
      );
      trailerKey = trailer?['key'];
    }
  }
}

class CastMember {
  CastMember({required this.name, required this.character, this.profilePath});

  final String name;
  final String character;
  final String? profilePath;

  factory CastMember.fromJson(Map<String, dynamic> j) {
    final roles = j['roles'] as List?;
    return CastMember(
      name: j['name'] ?? '',
      character:
          j['character'] ??
          (roles != null && roles.isNotEmpty ? roles[0]['character'] : '') ??
          '',
      profilePath: j['profile_path'],
    );
  }
}
