import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Web: hosts the Sketchfab page in a `srcdoc` iframe. The page posts
/// `sketchfab:<uid>:<msg>` messages to this window.
class SketchfabFrame extends StatefulWidget {
  const SketchfabFrame({
    super.key,
    required this.uid,
    required this.html,
    required this.onMessage,
    required this.onExternalLink,
    required this.onCommandSink,
  });

  final String uid;
  final String html;
  final ValueChanged<String> onMessage;
  final ValueChanged<String> onExternalLink;

  /// Hands the parent a function that sends a JSON camera command to the
  /// page's `window.sfCommand`.
  final ValueChanged<void Function(String json)> onCommandSink;

  @override
  State<SketchfabFrame> createState() => _SketchfabFrameState();
}

class _SketchfabFrameState extends State<SketchfabFrame> {
  late final JSFunction _listener = ((web.MessageEvent e) {
    final data = e.data;
    if (!data.isA<JSString>()) return;
    final prefix = 'sketchfab:${widget.uid}:';
    final msg = (data as JSString).toDart;
    if (msg.startsWith(prefix)) widget.onMessage(msg.substring(prefix.length));
  }).toJS;

  @override
  void initState() {
    super.initState();
    web.window.addEventListener('message', _listener);
  }

  web.HTMLIFrameElement? _frame;

  @override
  void dispose() {
    web.window.removeEventListener('message', _listener);
    // Tear the viewer down now so its WebGL context is freed immediately;
    // browsers cap live contexts and swiping through heroes adds up.
    _frame?.srcdoc = ''.toJS;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView.fromTagName(
      key: ValueKey(widget.uid),
      tagName: 'iframe',
      onElementCreated: (element) {
        final frame = element as web.HTMLIFrameElement
          ..srcdoc = widget.html.toJS
          ..allow = 'autoplay; fullscreen; xr-spatial-tracking'
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.background = 'transparent'
          // Gestures are handled in Flutter (see SketchfabViewer).
          ..style.pointerEvents = 'none';
        frame.setAttribute('allowtransparency', 'true');
        _frame = frame;
        widget.onCommandSink(
          (json) =>
              frame.contentWindow?.postMessage('sfcmd:$json'.toJS, '*'.toJS),
        );
      },
    );
  }
}
