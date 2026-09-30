/// Host page for a Sketchfab model, driven by the Viewer API
/// (https://sketchfab.com/developers/viewer). Compared with a bare embed
/// iframe it gives a real "model ready" signal and full camera control:
///
/// * Framing: artists' saved cameras are often close-ups or off-centre, so we
///   recenter on the whole model and then apply [distance] (1.0 = exact fit,
///   < 1 moves closer).
/// * Interaction: the Sketchfab iframe never receives touches (Sketchfab's
///   own overlay — avatar, share, settings, VR, fullscreen — pops up on tap
///   and can't be hidden on free models). Flutter captures the gestures and
///   drives the camera through `window.sfCommand({dx, dy, zoom})`, and we run
///   our own auto-spin that pauses while the user is interacting.
///
/// The page reports `ready`, `error` and `progress:<0..1>` messages via a
/// `Flutter` JavaScript channel on mobile, `parent.postMessage` on web.
String sketchfabHtml(String uid, {double distance = 1.0}) =>
    '''
<!doctype html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<style>
  html, body { margin: 0; height: 100%; background: transparent; overflow: hidden; }
  iframe { border: 0; width: 100%; height: 100%; background: transparent; pointer-events: none; }
</style>
</head>
<body>
<iframe id="viewer" allow="autoplay; xr-spatial-tracking" allowtransparency="true"></iframe>
<script src="https://static.sketchfab.com/api/sketchfab-viewer-1.12.1.js"></script>
<script>
  function notify(msg) {
    if (window.Flutter) Flutter.postMessage(msg);
    else parent.postMessage('sketchfab:$uid:' + msg, '*');
  }
  var distance = $distance;

  // ---- Camera rig (spherical coordinates around the target, Z up) ----
  var api = null, cam = null, baseR = 1;
  var pending = { dx: 0, dy: 0, zoom: 1 }, busy = false, lastTouch = 0;
  var SPIN = 0.004;          // radians per frame while idle
  var RESUME_AFTER = 2500;   // ms after the last gesture

  function applyCamera() {
    if (!api || !cam || busy) return;
    var idle = Date.now() - lastTouch > RESUME_AFTER;
    var dx = pending.dx, dy = pending.dy, zoom = pending.zoom;
    pending = { dx: 0, dy: 0, zoom: 1 };
    if (!dx && !dy && zoom === 1 && !idle) return;
    cam.yaw -= dx * 0.01 + (idle ? SPIN : 0);
    cam.pitch = Math.max(-0.3, Math.min(1.3, cam.pitch + dy * 0.006));
    cam.r = Math.max(baseR * 0.45, Math.min(baseR * 2.2, cam.r / zoom));
    var t = cam.target, c = Math.cos(cam.pitch);
    busy = true;
    api.setCameraLookAt([
      t[0] + cam.r * c * Math.cos(cam.yaw),
      t[1] + cam.r * c * Math.sin(cam.yaw),
      t[2] + cam.r * Math.sin(cam.pitch),
    ], t, 0, function () { busy = false; });
  }
  (function loop() { applyCamera(); requestAnimationFrame(loop); })();

  window.sfCommand = function (c) {
    lastTouch = Date.now();
    pending.dx += c.dx || 0;
    pending.dy += c.dy || 0;
    pending.zoom *= c.zoom || 1;
  };
  window.addEventListener('message', function (e) {
    if (typeof e.data === 'string' && e.data.indexOf('sfcmd:') === 0) {
      window.sfCommand(JSON.parse(e.data.slice(6)));
    }
  });

  function startRig(p, t) {
    var vx = p[0] - t[0], vy = p[1] - t[1], vz = p[2] - t[2];
    var r = Math.sqrt(vx * vx + vy * vy + vz * vz) || 1;
    baseR = r;
    cam = { target: t, r: r, yaw: Math.atan2(vy, vx), pitch: Math.asin(vz / r) };
  }

  try {
    new Sketchfab(document.getElementById('viewer')).init('$uid', {
      autostart: 1, transparent: 1, camera: 0, dnt: 1, autospin: 0,
      // Best effort — most of these are ignored for free models, which is
      // why touches are kept away from the viewer entirely.
      ui_theme: 'dark', ui_hint: 0, ui_infos: 0, ui_controls: 0,
      ui_general_controls: 0, ui_stop: 0, ui_animations: 0, ui_sound: 0,
      ui_inspector: 0, ui_settings: 0, ui_help: 0, ui_vr: 0, ui_ar: 0,
      ui_ar_help: 0, ui_ar_qrcode: 0, ui_fullscreen: 0, ui_annotations: 0,
      ui_loading: 0, ui_watermark_link: 0,
      // Phones don't need 4K textures; this cuts load time a lot.
      max_texture_size: 1024,
      success: function (sf) {
        // Geometry arrives first, but the model only looks right once its
        // textures finish. Sketchfab loads textures in two passes (a quick
        // low-res one that hits 100% almost instantly, then full-res from 0%
        // again), so textures count as done only once progress sits at 100%
        // with no further events.
        var model = 0, tex = 0, pass = 0, sawTexture = false, texTimer = null;
        var framed = false, texturesDone = false, sent = false;
        function progress() {
          var t = pass === 0 ? 0.25 * tex : 0.35 + 0.65 * tex;
          notify('progress:' + Math.min(0.1 * model + 0.9 * t, 0.99).toFixed(3));
        }
        function maybeReady() {
          if (framed && texturesDone && !sent) { sent = true; notify('ready'); }
        }
        sf.addEventListener('modelLoadProgress', function (e) {
          model = e.progress; progress();
        });
        sf.addEventListener('textureLoadProgress', function (e) {
          sawTexture = true;
          if (tex >= 1 && e.progress < 1) pass++;
          tex = e.progress; progress();
          clearTimeout(texTimer);
          texTimer = setTimeout(function () {
            if (tex >= 1) { texturesDone = true; maybeReady(); }
          }, 2500);
        });
        sf.start();
        sf.addEventListener('viewerready', function () {
          model = 1; progress();
          // Untextured or cached models may never report texture progress.
          setTimeout(function () {
            if (!sawTexture) { texturesDone = true; maybeReady(); }
          }, 3000);
          sf.recenterCamera(function () {
            sf.getCameraLookAt(function (err, c) {
              if (!err) {
                var p = c.position, t = c.target;
                startRig([
                  t[0] + (p[0] - t[0]) * distance,
                  t[1] + (p[1] - t[1]) * distance,
                  t[2] + (p[2] - t[2]) * distance,
                ], t);
                api = sf;
              }
              framed = true; maybeReady();
            });
          });
        });
      },
      error: function () { notify('error'); }
    });
  } catch (e) { notify('error'); }
</script>
</body>
</html>
''';
