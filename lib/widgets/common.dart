import 'dart:async';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../core/config.dart';
import '../core/theme.dart';
import '../data/models/mcu_title.dart';

/// TMDB poster with a colourful phase-tinted fallback when offline.
class PosterImage extends StatelessWidget {
  const PosterImage({super.key, required this.title, this.backdrop = false});

  final McuTitle title;
  final bool backdrop;

  @override
  Widget build(BuildContext context) {
    final path = backdrop ? title.backdropPath : title.posterPath;
    final url = AppConfig.tmdbImage(path, size: backdrop ? 'w1280' : 'w500');
    if (url.isEmpty) return _Fallback(title: title);
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (_, _) => const ShimmerBox(),
      errorWidget: (_, _, _) => _Fallback(title: title),
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback({required this.title});
  final McuTitle title;

  @override
  Widget build(BuildContext context) {
    final c = MarvelColors.phase(title.phase);
    return LayoutBuilder(
      builder: (context, box) => box.maxWidth < 80
          ? Container(
              color: Color.lerp(c, Colors.black, 0.35),
              alignment: Alignment.center,
              child: Icon(
                title.isTv ? Icons.live_tv_rounded : Icons.movie_filter_rounded,
                color: Colors.white70,
              ),
            )
          : _full(c),
    );
  }

  Widget _full(Color c) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c, Color.lerp(c, Colors.black, 0.75)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              title.isTv ? Icons.live_tv_rounded : Icons.movie_filter_rounded,
              size: 110,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              title.title.toUpperCase(),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.display(22),
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerBox extends StatelessWidget {
  const ShimmerBox({super.key, this.radius = 0});
  final double radius;

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
    baseColor: MarvelColors.surface,
    highlightColor: MarvelColors.surfaceHigh,
    child: Container(
      decoration: BoxDecoration(
        color: MarvelColors.surface,
        borderRadius: BorderRadius.circular(radius),
      ),
    ),
  );
}

class PosterCard extends StatelessWidget {
  const PosterCard({
    super.key,
    required this.title,
    required this.onTap,
    this.width = 130,
    this.watched = false,
  });

  final McuTitle title;
  final VoidCallback onTap;
  final double width;
  final bool watched;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'poster-${title.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PosterImage(title: title),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: PhaseBadge(phase: title.phase, compact: true),
                      ),
                      if (title.rating != null && title.rating! > 0)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: RatingPill(rating: title.rating!),
                        ),
                      if (watched)
                        const Positioned(
                          bottom: 6,
                          right: 6,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: MarvelColors.green,
                            child: Icon(
                              Icons.check,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Text(
              '${title.releaseDate.year} • ${title.isTv
                  ? 'Series'
                  : title.type == TitleType.special
                  ? 'Special'
                  : 'Movie'}',
              style: const TextStyle(color: MarvelColors.textDim, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class PhaseBadge extends StatelessWidget {
  const PhaseBadge({super.key, required this.phase, this.compact = false});
  final int phase;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = MarvelColors.phase(phase);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10, vertical: 3),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [BoxShadow(color: c.withValues(alpha: 0.5), blurRadius: 8)],
      ),
      child: Text(
        compact ? 'P$phase' : 'PHASE $phase',
        style: AppTheme.display(compact ? 13 : 15),
      ),
    );
  }
}

class RatingPill extends StatelessWidget {
  const RatingPill({super.key, required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) => Glass(
    radius: 8,
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 13, color: MarvelColors.gold),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

/// Frosted-glass container.
class Glass extends StatelessWidget {
  const Glass({
    super.key,
    required this.child,
    this.radius = 16,
    this.padding = const EdgeInsets.all(12),
    this.opacity = 0.12,
  });

  final Widget child;
  final double radius;
  final EdgeInsets padding;
  final double opacity;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: opacity),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: child,
      ),
    ),
  );
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.onAction});
  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 8, 10),
    child: Row(
      children: [
        Container(width: 4, height: 22, color: MarvelColors.red),
        const SizedBox(width: 8),
        Expanded(child: Text(title.toUpperCase(), style: AppTheme.display(24))),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    ),
  );
}

class CountdownText extends StatefulWidget {
  const CountdownText({super.key, required this.target, this.style});
  final DateTime target;
  final TextStyle? style;

  @override
  State<CountdownText> createState() => _CountdownTextState();
}

class _CountdownTextState extends State<CountdownText> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.target.difference(DateTime.now());
    if (d.isNegative) return Text('OUT NOW', style: widget.style);
    String two(int n) => n.toString().padLeft(2, '0');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _unit('${d.inDays}', 'DAYS'),
        _unit(two(d.inHours % 24), 'HRS'),
        _unit(two(d.inMinutes % 60), 'MIN'),
        _unit(two(d.inSeconds % 60), 'SEC'),
      ],
    );
  }

  Widget _unit(String v, String label) => Padding(
    padding: const EdgeInsets.only(right: 10),
    child: Glass(
      radius: 10,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Column(
        children: [
          Text(v, style: AppTheme.display(26)),
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: Colors.white70),
          ),
        ],
      ),
    ),
  );
}

class StatBar extends StatelessWidget {
  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label[0].toUpperCase() + label.substring(1),
            style: const TextStyle(color: MarvelColors.textDim, fontSize: 13),
          ),
        ),
        Expanded(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value / 100),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: v,
                minHeight: 10,
                backgroundColor: MarvelColors.surfaceHigh,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 36,
          child: Text(
            '$value',
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: MarvelColors.gold.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: MarvelColors.gold.withValues(alpha: 0.4)),
    ),
    child: Row(
      children: [
        const Icon(Icons.wifi_off_rounded, color: MarvelColors.gold, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
        ),
      ],
    ),
  );
}
