import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme.dart';
import '../data/models/comic.dart';
import '../providers/comics_provider.dart';
import '../widgets/common.dart';

class ComicsScreen extends StatefulWidget {
  const ComicsScreen({super.key});

  @override
  State<ComicsScreen> createState() => _ComicsScreenState();
}

class _ComicsScreenState extends State<ComicsScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    final comics = context.watch<ComicsProvider>();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('COMICS', style: AppTheme.display(34)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                enabled: comics.online,
                textInputAction: TextInputAction.search,
                onSubmitted: comics.search,
                decoration: InputDecoration(
                  hintText: comics.online
                      ? 'Search issues — e.g. "Infinity Gauntlet"'
                      : 'Add a Comic Vine key to search live issues',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: MarvelColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          if (!comics.online)
            const SliverToBoxAdapter(
              child: OfflineBanner(
                message:
                    'Marvel retired its public developer API, so live '
                    'issue data comes from Comic Vine (free key: '
                    '--dart-define=COMICVINE_API_KEY=...).',
              ),
            ),
          SliverToBoxAdapter(
            child: _UnlimitedCard(
              onTap: () => _open('https://www.marvel.com/unlimited'),
            ),
          ),
          if (comics.loading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else if (comics.error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  comics.error!,
                  style: const TextStyle(color: MarvelColors.textDim),
                ),
              ),
            )
          else if (comics.results.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: SectionHeader('Results for "${comics.lastQuery}"'),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 170,
                  childAspectRatio: 0.55,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                ),
                itemCount: comics.results.length,
                itemBuilder: (_, i) => _IssueCard(
                  comic: comics.results[i],
                  onTap: comics.results[i].url == null
                      ? null
                      : () => _open(comics.results[i].url!),
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SectionHeader('Essential reading')),
          SliverList.builder(
            itemCount: comics.essentials.length,
            itemBuilder: (_, i) => _EssentialCard(
              comic: comics.essentials[i],
              onSearch: comics.online
                  ? () {
                      _controller.text = comics.essentials[i].title;
                      comics.search(comics.essentials[i].title);
                    }
                  : null,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _UnlimitedCard extends StatelessWidget {
  const _UnlimitedCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: MarvelColors.heroGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('READ FREE ISSUES', style: AppTheme.display(22)),
                const Text(
                  'Marvel Unlimited offers a rotating selection of free comics.',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
          const Icon(Icons.open_in_new_rounded),
        ],
      ),
    ),
  );
}

class _EssentialCard extends StatelessWidget {
  const _EssentialCard({required this.comic, this.onSearch});
  final Comic comic;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    decoration: BoxDecoration(
      color: MarvelColors.surface,
      borderRadius: BorderRadius.circular(18),
    ),
    clipBehavior: Clip.antiAlias,
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  comic.color,
                  Color.lerp(comic.color, Colors.black, 0.6)!,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            alignment: Alignment.center,
            child: Text(comic.year ?? '', style: AppTheme.display(26)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(comic.title.toUpperCase(), style: AppTheme.display(22)),
                  Text(
                    comic.subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: MarvelColors.textDim,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    comic.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (comic.tieIn != null)
                        Expanded(
                          child: Row(
                            children: [
                              Icon(
                                Icons.movie_filter_rounded,
                                size: 14,
                                color: comic.color,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'Inspired ${comic.tieIn}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color.lerp(
                                      comic.color,
                                      Colors.white,
                                      0.4,
                                    ),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (onSearch != null)
                        TextButton(
                          onPressed: onSearch,
                          child: const Text('Find issues'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _IssueCard extends StatelessWidget {
  const _IssueCard({required this.comic, this.onTap});
  final Comic comic;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: comic.imageUrl == null
                ? Container(color: MarvelColors.surfaceHigh)
                : CachedNetworkImage(
                    imageUrl: comic.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (_, _) => const ShimmerBox(),
                    errorWidget: (_, _, _) =>
                        Container(color: MarvelColors.surfaceHigh),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          comic.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        if (comic.year != null)
          Text(
            comic.year!,
            style: const TextStyle(fontSize: 11, color: MarvelColors.textDim),
          ),
      ],
    ),
  );
}
