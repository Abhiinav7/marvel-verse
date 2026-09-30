import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/config.dart';
import '../core/theme.dart';
import '../data/models/mcu_title.dart';
import '../providers/movies_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/common.dart';

class MovieDetailScreen extends StatefulWidget {
  const MovieDetailScreen({super.key, required this.title});
  final McuTitle title;

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MoviesProvider>().loadDetails(widget.title);
  }

  Future<void> _openTrailer(String key) => launchUrl(
    Uri.parse('https://www.youtube.com/watch?v=$key'),
    mode: LaunchMode.externalApplication,
  );

  String _money(int v) => v >= 1e9
      ? '\$${(v / 1e9).toStringAsFixed(2)}B'
      : '\$${(v / 1e6).toStringAsFixed(0)}M';

  @override
  Widget build(BuildContext context) {
    context.watch<MoviesProvider>(); // rebuild when details arrive
    final user = context.watch<UserProvider>();
    final t = widget.title;
    final color = MarvelColors.phase(t.phase);
    final watched = user.isWatched(t.id);
    final fav = user.isFavTitle(t.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: MarvelColors.bg,
            actions: [
              IconButton(
                icon: Icon(
                  fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: fav ? MarvelColors.red : null,
                ),
                onPressed: () => user.toggleFavTitle(t.id),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PosterImage(title: t, backdrop: t.backdropPath != null),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          color.withValues(alpha: 0.25),
                          MarvelColors.bg,
                        ],
                        stops: const [0.3, 0.7, 1],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Hero(
                    tag: 'poster-${t.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 110,
                        height: 165,
                        child: PosterImage(title: t),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PhaseBadge(phase: t.phase),
                        const SizedBox(height: 8),
                        Text(
                          t.title.toUpperCase(),
                          style: AppTheme.display(30),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 10,
                          runSpacing: 4,
                          children: [
                            _meta(
                              Icons.calendar_month_rounded,
                              _date(t.releaseDate),
                            ),
                            if (t.runtime != null && t.runtime! > 0)
                              _meta(
                                Icons.timer_outlined,
                                t.isTv
                                    ? '${t.runtime}m/ep'
                                    : '${t.runtime} min',
                              ),
                            if (t.rating != null && t.rating! > 0)
                              _meta(
                                Icons.star_rounded,
                                '${t.rating!.toStringAsFixed(1)} (${t.voteCount})',
                                color: MarvelColors.gold,
                              ),
                            if (t.seasons != null)
                              _meta(Icons.live_tv_rounded, t.seasons!),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: watched
                            ? MarvelColors.green
                            : MarvelColors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: Icon(
                        watched
                            ? Icons.check_circle_rounded
                            : Icons.add_circle_outline_rounded,
                      ),
                      label: Text(watched ? 'Watched' : 'Mark as watched'),
                      onPressed: () => user.toggleWatched(t.id),
                    ),
                  ),
                  if (t.trailerKey != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: MarvelColors.gold),
                          foregroundColor: MarvelColors.gold,
                        ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Trailer'),
                        onPressed: () => _openTrailer(t.trailerKey!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (t.genres.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final g in t.genres) Chip(label: Text(g))],
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SectionHeader('Story')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                t.overview ?? t.tagline,
                style: const TextStyle(
                  height: 1.5,
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Row(
                children: [
                  _InfoTile(
                    label: 'Timeline #',
                    value: '${t.chronoOrder}',
                    color: MarvelColors.purple,
                  ),
                  const SizedBox(width: 10),
                  _InfoTile(
                    label: 'Set in',
                    value: t.timelineYear ?? '—',
                    color: MarvelColors.blue,
                  ),
                  const SizedBox(width: 10),
                  _InfoTile(
                    label: 'Saga',
                    value: t.saga == Saga.infinity ? 'Infinity' : 'Multiverse',
                    color: color,
                  ),
                ],
              ),
            ),
          ),
          if ((t.revenue ?? 0) > 0 || (t.budget ?? 0) > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: [
                    if ((t.budget ?? 0) > 0)
                      _InfoTile(
                        label: 'Budget',
                        value: _money(t.budget!),
                        color: MarvelColors.cyan,
                      ),
                    if ((t.budget ?? 0) > 0 && (t.revenue ?? 0) > 0)
                      const SizedBox(width: 10),
                    if ((t.revenue ?? 0) > 0)
                      _InfoTile(
                        label: 'Box office',
                        value: _money(t.revenue!),
                        color: MarvelColors.gold,
                      ),
                  ],
                ),
              ),
            ),
          if (t.cast.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SectionHeader('Cast')),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 170,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: t.cast.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _CastCard(member: t.cast[i]),
                ),
              ),
            ),
          ] else if (!AppConfig.hasTmdb)
            const SliverToBoxAdapter(
              child: OfflineBanner(
                message: 'Cast, trailers and box office load with a TMDB key.',
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  String _date(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${m[d.month - 1]} ${d.day}, ${d.year}';
  }

  Widget _meta(IconData icon, String text, {Color? color}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: color ?? MarvelColors.textDim),
      const SizedBox(width: 3),
      Text(text, style: const TextStyle(fontSize: 12, color: Colors.white70)),
    ],
  );
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.display(20),
          ),
        ],
      ),
    ),
  );
}

class _CastCard extends StatelessWidget {
  const _CastCard({required this.member});
  final CastMember member;

  @override
  Widget build(BuildContext context) {
    final url = AppConfig.tmdbImage(member.profilePath, size: 'w185');
    return SizedBox(
      width: 96,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 96,
              height: 110,
              child: url.isEmpty
                  ? Container(
                      color: MarvelColors.surfaceHigh,
                      child: const Icon(Icons.person_rounded, size: 40),
                    )
                  : CachedNetworkImage(imageUrl: url, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            member.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          Text(
            member.character,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: MarvelColors.textDim),
          ),
        ],
      ),
    );
  }
}
