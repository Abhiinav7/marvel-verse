import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../data/characters_data.dart';
import '../data/models/hero_character.dart';
import 'sketchfab/sketchfab_viewer.dart';

/// Interactive, auto-rotating 3D model for a character: the hero's Sketchfab
/// model if it has one, else its own [HeroCharacter.modelUrl], else a
/// stand-in.
class HeroModelViewer extends StatelessWidget {
  const HeroModelViewer({
    super.key,
    required this.hero,
    this.interactive = true,
  });

  final HeroCharacter hero;
  final bool interactive;

  String get _src => hero.modelUrl ?? standInModel;

  @override
  Widget build(BuildContext context) {
    final sketchfab = hero.sketchfab;
    if (sketchfab != null) {
      return SketchfabViewer(
        key: ValueKey('sketchfab-${hero.id}'),
        model: sketchfab,
        name: hero.name,
        color: hero.color,
        accent: hero.accent,
      );
    }
    return ModelViewer(
      key: ValueKey('model-${hero.id}'),
      src: _src,
      alt: '3D model of ${hero.name}',
      backgroundColor: Colors.transparent,
      autoRotate: true,
      rotationPerSecond: '40deg',
      autoPlay: true,
      cameraControls: interactive,
      disableZoom: !interactive,
      disablePan: true,
      shadowIntensity: 1,
      exposure: 1.1,
      interactionPrompt: InteractionPrompt.none,
      debugLogging: false,
    );
  }
}
