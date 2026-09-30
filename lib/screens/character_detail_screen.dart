import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/models/hero_character.dart';
import '../providers/movies_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/common.dart';
import '../widgets/hero_model_viewer.dart';
import '../widgets/sketchfab/sketchfab_viewer.dart';
import 'home_screen.dart';

class CharacterDetailScreen extends StatelessWidget {
  const CharacterDetailScreen({super.key, required this.hero});
  final HeroCharacter hero;

  static const _statColors = {
    'intelligence': MarvelColors.cyan,
    'strength': MarvelColors.red,
    'speed': MarvelColors.gold,
    'durability': MarvelColors.green,
    'power': MarvelColors.purple,
    'combat': Color(0xFFFF7A00),
  };

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final fav = user.isFavHero(hero.id);
    final movies = context.read<MoviesProvider>();
    final firstTitle = movies.all
        .where((t) => hero.firstMcu.startsWith(t.title))
        .firstOrNull;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 420,
            backgroundColor: Color.lerp(hero.color, MarvelColors.bg, 0.7),
            actions: [
              IconButton(
                onPressed: () => user.toggleFavHero(hero.id),
                icon: Icon(
                  fav ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: fav ? MarvelColors.gold : null,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.2),
                    radius: 0.9,
                    colors: [
                      hero.color,
                      Color.lerp(hero.color, MarvelColors.bg, 0.85)!,
                    ],
                  ),
                ),
                child: SafeArea(child: HeroModelViewer(hero: hero)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  if (hero.imageUrl != null)
                    Container(
                      width: 72,
                      height: 72,
                      margin: const EdgeInsets.only(right: 14),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [hero.color, hero.accent],
                        ),
                      ),
                      child: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          hero.imageUrl!,
                        ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          hero.name.toUpperCase(),
                          style: AppTheme.display(40),
                        ),
                        Text(
                          hero.realName,
                          style: TextStyle(
                            color: hero.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Played by ${hero.actor}',
                          style: const TextStyle(color: MarvelColors.textDim),
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
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Text(
                hero.bio,
                style: const TextStyle(
                  height: 1.5,
                  fontSize: 15,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SectionHeader('Powers & abilities')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in hero.powers)
                    Chip(
                      avatar: Icon(
                        Icons.bolt_rounded,
                        size: 16,
                        color: hero.accent,
                      ),
                      label: Text(p),
                      backgroundColor: hero.color.withValues(alpha: 0.25),
                    ),
                ],
              ),
            ),
          ),
          if (hero.powerStats.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SectionHeader('Power stats')),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    for (final e in hero.powerStats.entries)
                      StatBar(
                        label: e.key,
                        value: e.value,
                        color: _statColors[e.key] ?? hero.color,
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SectionHeader('File')),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: MarvelColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _row('Affiliation', hero.team),
                    _row(
                      'MCU debut',
                      hero.firstMcu,
                      onTap: firstTitle == null
                          ? null
                          : () => openTitle(context, firstTitle),
                    ),
                    if (hero.firstComic != null)
                      _row('Comic debut', hero.firstComic!),
                    if (hero.aliases.isNotEmpty)
                      _row('Aliases', hero.aliases.join(', ')),
                    if (hero.height != null) _row('Height', hero.height!),
                    if (hero.weight != null) _row('Weight', hero.weight!),
                    if (hero.sketchfab != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                        child: ModelCredit(model: hero.sketchfab!),
                      ),
                    if (hero.alignment != null)
                      _row(
                        'Alignment',
                        hero.alignment![0].toUpperCase() +
                            hero.alignment!.substring(1),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _row(String k, String v, {VoidCallback? onTap}) => ListTile(
    dense: true,
    onTap: onTap,
    title: Text(k, style: const TextStyle(color: MarvelColors.textDim)),
    trailing: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 220),
      child: Text(
        v,
        textAlign: TextAlign.right,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: onTap != null ? MarvelColors.gold : Colors.white,
        ),
      ),
    ),
  );
}
