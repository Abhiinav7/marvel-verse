import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/mcu_data.dart';
import '../data/models/mcu_title.dart';
import '../providers/movies_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/common.dart';
import 'home_screen.dart';

class WatchOrderScreen extends StatelessWidget {
  const WatchOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final movies = context.watch<MoviesProvider>();
    final user = context.watch<UserProvider>();
    final list = movies.watchOrder(movies.order);
    final released = list.where((t) => t.isReleased).length;
    final done = list.where((t) => user.isWatched(t.id)).length;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text('WATCH ORDER', style: AppTheme.display(34)),
                ),
                Text(
                  '$done / $released',
                  style: AppTheme.display(24, color: MarvelColors.gold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: released == 0 ? 0 : (done / released).clamp(0, 1),
                minHeight: 8,
                backgroundColor: MarvelColors.surfaceHigh,
                valueColor: const AlwaysStoppedAnimation(MarvelColors.gold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<WatchOrder>(
                segments: const [
                  ButtonSegment(
                    value: WatchOrder.release,
                    icon: Icon(Icons.new_releases_outlined),
                    label: Text('Release'),
                  ),
                  ButtonSegment(
                    value: WatchOrder.chronological,
                    icon: Icon(Icons.history_toggle_off_rounded),
                    label: Text('Chronological'),
                  ),
                ],
                selected: {movies.order},
                onSelectionChanged: (s) => movies.setOrder(s.first),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              movies.order == WatchOrder.release
                  ? 'Watch in the order audiences first saw them.'
                  : 'Follow the in-universe timeline, from 1942 to the Multiverse.',
              style: const TextStyle(color: MarvelColors.textDim, fontSize: 12),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 24),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final t = list[i];
                final showPhase =
                    movies.order == WatchOrder.release &&
                    (i == 0 || list[i - 1].phase != t.phase);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showPhase)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(52, 14, 0, 6),
                        child: Text(
                          phaseNames[t.phase]!.toUpperCase(),
                          style: AppTheme.display(
                            20,
                            color: MarvelColors.phase(t.phase),
                          ),
                        ),
                      ),
                    _TimelineTile(
                      index: i + 1,
                      title: t,
                      isFirst: i == 0,
                      isLast: i == list.length - 1,
                      watched: user.isWatched(t.id),
                      onToggle: () => user.toggleWatched(t.id),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.index,
    required this.title,
    required this.isFirst,
    required this.isLast,
    required this.watched,
    required this.onToggle,
  });

  final int index;
  final McuTitle title;
  final bool isFirst;
  final bool isLast;
  final bool watched;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final c = MarvelColors.phase(title.phase);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFirst
                        ? Colors.transparent
                        : c.withValues(alpha: 0.5),
                  ),
                ),
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: watched ? c : MarvelColors.surface,
                    border: Border.all(color: c, width: 2),
                    boxShadow: watched
                        ? [
                            BoxShadow(
                              color: c.withValues(alpha: 0.6),
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                  child: Text('$index', style: AppTheme.display(15)),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast
                        ? Colors.transparent
                        : c.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => openTitle(context, title),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: MarvelColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border(left: BorderSide(color: c, width: 3)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 46,
                        height: 68,
                        child: PosterImage(title: title),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            [
                              '${title.releaseDate.year}',
                              if (title.isTv) 'Series',
                              if (title.timelineYear != null)
                                'Set: ${title.timelineYear}',
                            ].join(' • '),
                            style: const TextStyle(
                              fontSize: 11,
                              color: MarvelColors.textDim,
                            ),
                          ),
                          if (!title.isReleased)
                            const Padding(
                              padding: EdgeInsets.only(top: 3),
                              child: Text(
                                'COMING SOON',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: MarvelColors.gold,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: title.isReleased ? onToggle : null,
                      icon: Icon(
                        watched
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: watched
                            ? MarvelColors.green
                            : MarvelColors.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
