import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/models/hero_character.dart';
import '../data/models/mcu_title.dart';
import '../providers/characters_provider.dart';
import '../providers/movies_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/common.dart';
import 'character_detail_screen.dart';
import 'home_shell.dart';
import 'movie_detail_screen.dart';
import 'quiz_screen.dart';
import 'search_screen.dart';

void openTitle(BuildContext context, McuTitle t) => Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => MovieDetailScreen(title: t)),
);

void openHero(BuildContext context, HeroCharacter h) => Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => CharacterDetailScreen(hero: h)),
);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final movies = context.watch<MoviesProvider>();
    final user = context.watch<UserProvider>();
    final heroes = context.watch<CharactersProvider>().all;
    final next = movies.nextRelease;

    return RefreshIndicator(
      color: MarvelColors.red,
      onRefresh: movies.loadSummaries,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: MarvelColors.bg,
            titleSpacing: 16,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  color: MarvelColors.red,
                  child: Text('MARVEL', style: AppTheme.display(28)),
                ),
                const SizedBox(width: 8),
                Text('VERSE', style: AppTheme.display(28)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.quiz_rounded),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizScreen()),
                ),
              ),
            ],
          ),
          if (!movies.online)
            const SliverToBoxAdapter(
              child: OfflineBanner(
                message:
                    'Running on curated offline data. Add a TMDB key '
                    '(--dart-define=TMDB_API_KEY=...) for posters, ratings, '
                    'cast and trailers.',
              ),
            ),
          if (next != null)
            SliverToBoxAdapter(child: _NextReleaseCard(title: next)),
          SliverToBoxAdapter(
            child: _ProgressCard(
              watched: user.watched.length,
              total: movies.all.where((t) => t.isReleased).length,
              nextUp: movies
                  .watchOrder(WatchOrder.chronological)
                  .where((t) => t.isReleased && !user.isWatched(t.id))
                  .firstOrNull,
            ),
          ),
          SliverToBoxAdapter(
            child: SectionHeader(
              'Latest releases',
              action: 'See all',
              onAction: () => HomeShell.goTo(context, 1),
            ),
          ),
          SliverToBoxAdapter(child: _PosterRow(titles: movies.latest)),
          if (movies.topRated.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SectionHeader('Fan favourites')),
            SliverToBoxAdapter(child: _PosterRow(titles: movies.topRated)),
          ],
          SliverToBoxAdapter(
            child: SectionHeader(
              'Heroes & villains',
              action: 'Swipe in 3D',
              onAction: () => HomeShell.goTo(context, 3),
            ),
          ),
          SliverToBoxAdapter(child: _HeroRow(heroes: heroes)),
          const SliverToBoxAdapter(child: SectionHeader('Sagas')),
          SliverToBoxAdapter(child: _SagaCards(movies: movies)),
          const SliverToBoxAdapter(child: _QuizBanner()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _NextReleaseCard extends StatelessWidget {
  const _NextReleaseCard({required this.title});
  final McuTitle title;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => openTitle(context, title),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        height: 210,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: MarvelColors.red.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (title.backdropPath != null)
              PosterImage(title: title, backdrop: true)
            else
              const DecoratedBox(
                decoration: BoxDecoration(gradient: MarvelColors.heroGradient),
              ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: MarvelColors.gold,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'NEXT IN THE MCU',
                      style: AppTheme.display(14, color: Colors.black),
                    ),
                  ),
                  const Spacer(),
                  Text(title.title.toUpperCase(), style: AppTheme.display(34)),
                  const SizedBox(height: 8),
                  CountdownText(target: title.releaseDate),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.watched,
    required this.total,
    this.nextUp,
  });
  final int watched;
  final int total;
  final McuTitle? nextUp;

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0.0 : (watched / total).clamp(0.0, 1.0);
    return GestureDetector(
      onTap: () => HomeShell.goTo(context, 2),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF1B2A6B), Color(0xFF3A1C71)],
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: pct),
                    duration: const Duration(milliseconds: 900),
                    builder: (_, v, _) => CircularProgressIndicator(
                      value: v,
                      strokeWidth: 7,
                      backgroundColor: Colors.white12,
                      valueColor: const AlwaysStoppedAnimation(
                        MarvelColors.gold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      '${(pct * 100).round()}%',
                      style: AppTheme.display(22),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('YOUR MCU JOURNEY', style: AppTheme.display(20)),
                  Text(
                    '$watched of $total titles watched',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  if (nextUp != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Up next: ${nextUp!.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: MarvelColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _PosterRow extends StatelessWidget {
  const _PosterRow({required this.titles});
  final List<McuTitle> titles;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: titles.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, i) => PosterCard(
          title: titles[i],
          watched: user.isWatched(titles[i].id),
          onTap: () => openTitle(context, titles[i]),
        ),
      ),
    );
  }
}

class _HeroRow extends StatelessWidget {
  const _HeroRow({required this.heroes});
  final List<HeroCharacter> heroes;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 112,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: heroes.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final h = heroes[i];
          return GestureDetector(
            onTap: () => openHero(context, h),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [h.color, h.accent]),
                  ),
                  child: CircleAvatar(
                    backgroundColor: MarvelColors.surface,
                    backgroundImage: h.imageUrl != null
                        ? CachedNetworkImageProvider(h.imageUrl!)
                        : null,
                    child: h.imageUrl == null
                        ? Text(h.name[0], style: AppTheme.display(30))
                        : null,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 80,
                  child: Text(
                    h.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SagaCards extends StatelessWidget {
  const _SagaCards({required this.movies});
  final MoviesProvider movies;

  @override
  Widget build(BuildContext context) {
    Widget card(String name, String sub, Saga saga, List<Color> colors) {
      final count = movies.all.where((t) => t.saga == saga).length;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            movies.setPhase(null);
            HomeShell.goTo(context, 1);
          },
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(colors: colors),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.display(24)),
                Text(
                  sub,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const Spacer(),
                Text(
                  '$count titles',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          card('INFINITY SAGA', 'Phases 1–3', Saga.infinity, const [
            Color(0xFF7B2FF7),
            Color(0xFFE62429),
          ]),
          const SizedBox(width: 12),
          card('MULTIVERSE SAGA', 'Phases 4–6', Saga.multiverse, const [
            Color(0xFF00897B),
            Color(0xFF1E6FFF),
          ]),
        ],
      ),
    );
  }
}

class _QuizBanner extends StatelessWidget {
  const _QuizBanner();

  @override
  Widget build(BuildContext context) {
    final best = context.watch<UserProvider>().bestQuiz;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QuizScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [MarvelColors.gold, Color(0xFFFF7A00)],
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.bolt_rounded, size: 44, color: Colors.black),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ARE YOU WORTHY?',
                    style: AppTheme.display(26, color: Colors.black),
                  ),
                  Text(
                    best > 0
                        ? 'Best score: $best — beat it!'
                        : 'Take the MCU trivia challenge',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.black),
          ],
        ),
      ),
    );
  }
}
