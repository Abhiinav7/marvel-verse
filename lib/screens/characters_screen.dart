import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../data/models/hero_character.dart';
import '../providers/characters_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/hero_model_viewer.dart';
import '../widgets/sketchfab/sketchfab_viewer.dart';
import 'home_screen.dart';

/// Swipeable 3D character carousel. The model area captures touches for
/// rotation, so paging happens by swiping the info card or tapping arrows.
class CharactersScreen extends StatefulWidget {
  const CharactersScreen({super.key});

  @override
  State<CharactersScreen> createState() => _CharactersScreenState();
}

class _CharactersScreenState extends State<CharactersScreen> {
  late final PageController _page;

  @override
  void initState() {
    super.initState();
    _page = PageController(
      initialPage: context.read<CharactersProvider>().currentIndex,
    );
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _go(int delta, int length) {
    final target = (context.read<CharactersProvider>().currentIndex + delta)
        .clamp(0, length - 1);
    _page.animateToPage(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chars = context.watch<CharactersProvider>();
    final heroes = chars.visible;
    final hero = chars.current;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.35),
          radius: 1.1,
          colors: [
            hero.color.withValues(alpha: 0.85),
            Color.lerp(hero.color, MarvelColors.bg, 0.8)!,
            MarvelColors.bg,
          ],
          stops: const [0, 0.55, 1],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
              child: Row(
                children: [
                  Expanded(child: Text('HEROES', style: AppTheme.display(34))),
                  if (chars.loading)
                    const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  Text(
                    '${chars.currentIndex + 1}/${heroes.length}',
                    style: AppTheme.display(22, color: hero.accent),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (final f in HeroFilter.values)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          f.name[0].toUpperCase() + f.name.substring(1),
                        ),
                        selected: chars.filter == f,
                        onSelected: (_) {
                          chars.setFilter(f);
                          _page.jumpToPage(0);
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ),
            // 3D stage — only the visible hero mounts a WebView.
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: HeroModelViewer(
                        key: ValueKey(hero.id),
                        hero: hero,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 4,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _ArrowButton(
                        icon: Icons.chevron_left_rounded,
                        onTap: () => _go(-1, heroes.length),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _ArrowButton(
                        icon: Icons.chevron_right_rounded,
                        onTap: () => _go(1, heroes.length),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 56,
                    right: 56,
                    child: IgnorePointer(
                      ignoring: hero.sketchfab == null,
                      child: Column(
                        children: [
                          const Text(
                            'Drag to rotate • Pinch to zoom',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white54,
                            ),
                          ),
                          if (hero.sketchfab != null)
                            ModelCredit(model: hero.sketchfab!, center: true),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 210,
              child: PageView.builder(
                controller: _page,
                itemCount: heroes.length,
                onPageChanged: chars.setIndex,
                itemBuilder: (_, i) => AnimatedBuilder(
                  animation: _page,
                  builder: (_, child) {
                    var scale = 1.0;
                    if (_page.position.haveDimensions) {
                      scale = (1 - ((_page.page ?? 0) - i).abs() * 0.12).clamp(
                        0.85,
                        1.0,
                      );
                    }
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: _HeroInfoCard(hero: heroes[i]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < heroes.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == chars.currentIndex ? 22 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == chars.currentIndex
                            ? hero.accent
                            : Colors.white24,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.black38,
    shape: const CircleBorder(),
    child: IconButton(icon: Icon(icon, size: 30), onPressed: onTap),
  );
}

class _HeroInfoCard extends StatelessWidget {
  const _HeroInfoCard({required this.hero});
  final HeroCharacter hero;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final fav = user.isFavHero(hero.id);
    return GestureDetector(
      onTap: () => openHero(context, hero),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              hero.color.withValues(alpha: 0.9),
              Color.lerp(hero.color, Colors.black, 0.6)!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: hero.accent.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: hero.color.withValues(alpha: 0.45),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    hero.name.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.display(38),
                  ),
                ),
                IconButton(
                  onPressed: () => user.toggleFavHero(hero.id),
                  icon: Icon(
                    fav ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: fav ? MarvelColors.gold : Colors.white,
                  ),
                ),
              ],
            ),
            Text(
              '${hero.realName}  •  ${hero.actor}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final p in hero.powers.take(3))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(p, style: const TextStyle(fontSize: 11)),
                  ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  hero.isVillain
                      ? Icons.whatshot_rounded
                      : Icons.shield_rounded,
                  size: 16,
                  color: hero.accent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hero.team,
                    style: TextStyle(
                      color: hero.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Text(
                  'Details',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
