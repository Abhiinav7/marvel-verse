import 'package:flutter/material.dart';

class Comic {
  Comic({
    required this.title,
    required this.subtitle,
    required this.description,
    this.year,
    this.imageUrl,
    this.url,
    this.color = const Color(0xFFE62429),
    this.tieIn,
  });

  final String title;
  final String subtitle;
  final String description;
  final String? year;
  final String? imageUrl;
  final String? url;
  final Color color;

  /// The MCU title this story inspired, if any.
  final String? tieIn;

  factory Comic.fromComicVine(Map<String, dynamic> j) {
    final volume = j['volume']?['name'];
    final number = j['issue_number'];
    final rawDesc = (j['deck'] ?? j['description'] ?? '') as String;
    return Comic(
      title: volume != null ? '$volume #$number' : (j['name'] ?? 'Untitled'),
      subtitle: j['name'] ?? '',
      description: rawDesc.replaceAll(RegExp(r'<[^>]*>'), '').trim(),
      year: (j['cover_date'] as String?)?.split('-').first,
      imageUrl: j['image']?['medium_url'],
      url: j['site_detail_url'],
    );
  }
}
