import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// Android / iOS: hosts the Sketchfab page in a WebView.
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
  static const _base = 'https://localhost/';
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // WebViews block media from starting without a tap by default, and
    // Sketchfab then shows its ▶ start screen instead of autostarting.
    var params = const PlatformWebViewControllerCreationParams();
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    }
    _controller = WebViewController.fromPlatformCreationParams(params);
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      platform.setMediaPlaybackRequiresUserGesture(false);
    }
    _controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'Flutter',
        onMessageReceived: (m) => widget.onMessage(m.message),
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (req) {
            // Sketchfab's own frames load freely; anything that tries to
            // replace our host page (e.g. the logo link) opens externally.
            if (!req.isMainFrame ||
                req.url.startsWith(_base) ||
                req.url.startsWith('about:')) {
              return NavigationDecision.navigate;
            }
            widget.onExternalLink(req.url);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadHtmlString(widget.html, baseUrl: _base);
    widget.onCommandSink(
      (json) => _controller.runJavaScript(
        'window.sfCommand && window.sfCommand($json)',
      ),
    );
    // Not supported on every platform (e.g. macOS).
    try {
      _controller.setBackgroundColor(Colors.transparent);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    // Touches are handled in Flutter (see SketchfabViewer), never by the
    // WebView, so Sketchfab's tap overlay can't appear.
    return WebViewWidget(controller: _controller);
  }
}
