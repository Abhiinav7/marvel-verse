import 'package:flutter/material.dart';

class HeroCharacter {
  HeroCharacter({
    required this.id,
    required this.name,
    required this.realName,
    required this.actor,
    required this.color,
    required this.accent,
    required this.bio,
    required this.powers,
    required this.firstMcu,
    required this.team,
    this.apiName,
    this.modelUrl,
    this.sketchfab,
    this.isVillain = false,
  });

  final String id;
  final String name;
  final String realName;
  final String actor;
  final Color color;
  final Color accent;
  final String bio;
  final List<String> powers;
  final String firstMcu;
  final String team;
  final bool isVillain;

  /// Name used to match the open superhero-api dataset (defaults to [name]).
  final String? apiName;

  /// A .glb/.gltf model — either a network URL or an `assets/...` path.
  /// When null, a stand-in model is shown on a [color]-themed stage.
  final String? modelUrl;

  /// A model streamed from Sketchfab's embedded viewer. Takes priority over
  /// [modelUrl] when set.
  final SketchfabModel? sketchfab;

  // ---- Enriched from superhero-api ----
  String? imageUrl;
  Map<String, int> powerStats = const {};
  String? firstComic;
  String? height;
  String? weight;
  String? alignment;
  List<String> aliases = const [];
}

/// A public Sketchfab model, shown via its embed player. [author] is credited
/// in the UI as the model's licence requires.
class SketchfabModel {
  const SketchfabModel(
    this.uid,
    this.title,
    this.author, {
    this.distance = 0.85,
  });

  final String uid;
  final String title;
  final String author;

  /// Camera distance after auto-fitting the whole model (1.0 = exact fit,
  /// smaller = closer). Tune per model if one looks too small or cropped.
  final double distance;

  String get pageUrl => 'https://sketchfab.com/3d-models/$uid';
}
