import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/mcu_data.dart';
import '../providers/movies_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/common.dart';
import 'home_screen.dart';

class TitlesScreen extends StatelessWidget {
  const TitlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final movies = context.watch<MoviesProvider>();
    final user = context.watch<UserProvider>();
    final list = movies.filtered;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text('MOVIES & SERIES', style: AppTheme.display(34)),
                  ),
                  if (movies.loading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<TypeFilter>(
                segments: const [
                  ButtonSegment(value: TypeFilter.all, label: Text('All')),
                  ButtonSegment(
                    value: TypeFilter.movies,
                    icon: Icon(Icons.movie_rounded),
                    label: Text('Movies'),
                  ),
                  ButtonSegment(
                    value: TypeFilter.series,
                    icon: Icon(Icons.live_tv_rounded),
                    label: Text('Series'),
                  ),
                ],
                selected: {movies.typeFilter},
                onSelectionChanged: (s) => movies.setType(s.first),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                children: [
                  _PhaseChip(
                    label: 'All phases',
                    color: MarvelColors.red,
                    selected: movies.phaseFilter == null,
                    onTap: () => movies.setPhase(null),
                  ),
                  for (final e in phaseNames.entries)
                    _PhaseChip(
                      label: e.value,
                      color: MarvelColors.phase(e.key),
                      selected: movies.phaseFilter == e.key,
                      onTap: () => movies.setPhase(e.key),
                    ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                childAspectRatio: 0.52,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
              ),
              itemCount: list.length,
              itemBuilder: (_, i) => PosterCard(
                title: list[i],
                width: double.infinity,
                watched: user.isWatched(list[i].id),
                onTap: () => openTitle(context, list[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  const _PhaseChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? color : MarvelColors.surfaceHigh,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.6)),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 10)]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    ),
  );
}
