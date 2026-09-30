import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/models/hero_character.dart';
import '../data/models/mcu_title.dart';
import '../providers/characters_provider.dart';
import '../providers/movies_provider.dart';
import '../widgets/common.dart';
import 'home_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final titles = _q.isEmpty
        ? const <McuTitle>[]
        : context.read<MoviesProvider>().search(_q);
    final heroes = _q.isEmpty
        ? const <HeroCharacter>[]
        : context.read<CharactersProvider>().search(_q);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          autofocus: true,
          onChanged: (v) => setState(() => _q = v.trim()),
          style: const TextStyle(fontSize: 17),
          decoration: const InputDecoration(
            hintText: 'Search movies, series, heroes, actors…',
            border: InputBorder.none,
          ),
        ),
      ),
      body: _q.isEmpty
          ? const Center(
              child: Text(
                'Find anything in the MCU',
                style: TextStyle(color: MarvelColors.textDim),
              ),
            )
          : ListView(
              children: [
                if (heroes.isNotEmpty) const SectionHeader('Characters'),
                for (final h in heroes)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: h.color,
                      backgroundImage: h.imageUrl != null
                          ? CachedNetworkImageProvider(h.imageUrl!)
                          : null,
                      child: h.imageUrl == null ? Text(h.name[0]) : null,
                    ),
                    title: Text(h.name),
                    subtitle: Text('${h.realName} • ${h.actor}'),
                    onTap: () => openHero(context, h),
                  ),
                if (titles.isNotEmpty) const SectionHeader('Movies & series'),
                for (final t in titles)
                  ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: 40,
                        height: 60,
                        child: PosterImage(title: t),
                      ),
                    ),
                    title: Text(t.title),
                    subtitle: Text('${t.releaseDate.year} • Phase ${t.phase}'),
                    onTap: () => openTitle(context, t),
                  ),
                if (titles.isEmpty && heroes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text(
                        'No results',
                        style: TextStyle(color: MarvelColors.textDim),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
