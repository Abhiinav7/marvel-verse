import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/hero_character.dart';
import 'sketchfab_frame_io.dart'
    if (dart.library.js_interop) 'sketchfab_frame_web.dart';
import 'hero_loader.dart';
import 'sketchfab_html.dart';

/// Streams a Sketchfab model through the Viewer API — no downloads or API
/// key needed.
class SketchfabViewer extends StatefulWidget {
  const SketchfabViewer({
    super.key,
    required this.model,
    required this.name,
    required this.color,
    required this.accent,
  });

  final SketchfabModel model;
  final String name;
  final Color color;
  final Color accent;

  @override
  State<SketchfabViewer> createState() => _SketchfabViewerState();
}

enum _Status { loading, ready, error }

class _SketchfabViewerState extends State<SketchfabViewer> {
  var _status = _Status.loading;
  double? _progress;
  Timer? _timeout;
  void Function(String json)? _send;
  double _lastScale = 1;

  void _camera({double dx = 0, double dy = 0, double zoom = 1}) =>
      _send?.call(jsonEncode({'dx': dx, 'dy': dy, 'zoom': zoom}));

  @override
  void initState() {
    super.initState();
    // Don't spin forever on a slow network; Sketchfab keeps loading anyway.
    _timeout = Timer(const Duration(seconds: 90), () => _set(_Status.ready));
  }

  @override
  void dispose() {
    _timeout?.cancel();
    super.dispose();
  }

  void _onMessage(String msg) {
    if (msg.startsWith('progress:')) {
      final p = double.tryParse(msg.substring('progress:'.length));
      if (p != null && mounted && _status == _Status.loading) {
        setState(() => _progress = p.clamp(0, 1));
      }
    } else {
      _set(msg == 'error' ? _Status.error : _Status.ready);
    }
  }

  void _set(_Status s) {
    if (!mounted || _status != _Status.loading) return;
    _timeout?.cancel();
    setState(() => _status = s);
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.model;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_status != _Status.error)
          // Kept near-invisible until textures are in (Sketchfab first shows a
          // grey, untextured model), then faded in. Not 0: Flutter skips
          // painting fully transparent children, so the platform view would
          // never be created.
          AnimatedOpacity(
            opacity: _status == _Status.ready ? 1 : 0.02,
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOut,
            child: IgnorePointer(
              child: SketchfabFrame(
                uid: m.uid,
                html: sketchfabHtml(m.uid, distance: m.distance),
                onMessage: _onMessage,
                onCommandSink: (send) => _send = send,
                onExternalLink: (url) => launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ),
          ),
        // Owns all touches on the model: one finger rotates, two fingers
        // pinch-zoom. Sketchfab itself never sees a tap.
        if (_status == _Status.ready)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: (_) => _lastScale = 1,
            onScaleUpdate: (d) {
              final zoom = d.scale / _lastScale;
              _lastScale = d.scale;
              _camera(
                dx: d.focalPointDelta.dx,
                dy: d.focalPointDelta.dy,
                zoom: d.pointerCount > 1 ? zoom : 1,
              );
            },
          ),
        if (_status == _Status.error)
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.view_in_ar_rounded, size: 48, color: Colors.white38),
                SizedBox(height: 8),
                Text(
                  'Couldn\'t load the 3D model',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        IgnorePointer(
          child: AnimatedOpacity(
            opacity: _status == _Status.loading ? 1 : 0,
            duration: const Duration(milliseconds: 400),
            child: Center(
              child: HeroLoader(
                name: widget.name,
                color: widget.color,
                accent: widget.accent,
                progress: _progress,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// "3D: `title` by `author` · Sketchfab" — the attribution the model
/// licences require. Tapping opens the model page.
class ModelCredit extends StatelessWidget {
  const ModelCredit({super.key, required this.model, this.center = false});

  final SketchfabModel model;
  final bool center;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(
        Uri.parse(model.pageUrl),
        mode: LaunchMode.externalApplication,
      ),
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: '3D: '),
            TextSpan(
              text: model.title,
              style: const TextStyle(decoration: TextDecoration.underline),
            ),
            TextSpan(text: ' by ${model.author} · Sketchfab'),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: center ? TextAlign.center : TextAlign.start,
        style: const TextStyle(fontSize: 11, color: Colors.white60),
      ),
    );
  }
}
