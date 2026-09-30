import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme.dart';

/// Arc-reactor style loader shown while a hero's 3D model streams in:
/// counter-rotating rings, a pulsing core and an outer progress ring.
class HeroLoader extends StatefulWidget {
  const HeroLoader({
    super.key,
    required this.name,
    required this.color,
    required this.accent,
    this.progress,
  });

  final String name;
  final Color color;
  final Color accent;

  /// 0..1, or null while the size is still unknown.
  final double? progress;

  @override
  State<HeroLoader> createState() => _HeroLoaderState();
}

class _HeroLoaderState extends State<HeroLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  String get _stage {
    final p = widget.progress;
    if (p == null || p < 0.3) return 'Downloading suit';
    if (p < 0.95) return 'Loading textures';
    return 'Almost ready';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.progress;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 150,
          child: AnimatedBuilder(
            animation: _spin,
            builder: (_, _) => CustomPaint(
              painter: _ReactorPainter(
                t: _spin.value,
                progress: p,
                color: widget.color,
                accent: widget.accent,
              ),
              child: Center(
                child: Text(
                  p == null ? '···' : '${(p * 100).round()}%',
                  style: AppTheme.display(28).copyWith(
                    shadows: [Shadow(color: widget.accent, blurRadius: 12)],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'SUITING UP ${widget.name.toUpperCase()}',
          textAlign: TextAlign.center,
          style: AppTheme.display(20).copyWith(letterSpacing: 2),
        ),
        const SizedBox(height: 2),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            _stage,
            key: ValueKey(_stage),
            style: const TextStyle(fontSize: 12, color: Colors.white60),
          ),
        ),
      ],
    );
  }
}

class _ReactorPainter extends CustomPainter {
  _ReactorPainter({
    required this.t,
    required this.progress,
    required this.color,
    required this.accent,
  });

  final double t;
  final double? progress;
  final Color color;
  final Color accent;

  static const _tau = math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final glow = Color.lerp(accent, Colors.white, 0.35)!;

    // Pulsing core.
    final pulse = 0.5 + 0.5 * math.sin(t * _tau * 2);
    final coreR = r * (0.36 + 0.03 * pulse);
    canvas.drawCircle(
      c,
      coreR * 1.6,
      Paint()
        ..color = accent.withValues(alpha: 0.18 + 0.12 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawCircle(
      c,
      coreR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.35),
            color.withValues(alpha: 0.35),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: c, radius: coreR)),
    );

    // Inner ring: three segments, counter-clockwise.
    _segments(
      canvas,
      c,
      r * 0.52,
      -t * _tau * 1.5,
      3,
      0.7,
      glow.withValues(alpha: 0.8),
      3,
    );
    // Middle ring: six short dashes, clockwise.
    _segments(canvas, c, r * 0.68, t * _tau, 6, 0.45, color, 4);

    // Outer progress track + arc.
    final outer = Rect.fromCircle(center: c, radius: r * 0.9);
    canvas.drawArc(
      outer,
      0,
      _tau,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = Colors.white10,
    );
    final p = progress;
    final start = -math.pi / 2;
    // Unknown size: a sweeping comet. Known: the real fraction.
    final sweep = p == null ? _tau * 0.22 : _tau * p.clamp(0.02, 1.0);
    final from = p == null ? start + t * _tau * 2 : start;
    for (final (width, blur) in [(9.0, 8.0), (5.0, 0.0)]) {
      canvas.drawArc(
        outer,
        from,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = width
          ..color = blur > 0 ? accent.withValues(alpha: 0.5) : glow
          ..maskFilter = blur > 0
              ? MaskFilter.blur(BlurStyle.normal, blur)
              : null,
      );
    }
  }

  void _segments(
    Canvas canvas,
    Offset c,
    double radius,
    double rotation,
    int count,
    double fill,
    Color color,
    double width,
  ) {
    final rect = Rect.fromCircle(center: c, radius: radius);
    final gap = _tau / count;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = width
      ..color = color;
    for (var i = 0; i < count; i++) {
      canvas.drawArc(rect, rotation + i * gap, gap * fill, false, paint);
    }
  }

  @override
  bool shouldRepaint(_ReactorPainter old) =>
      old.t != t || old.progress != progress;
}
