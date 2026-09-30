import 'package:flutter/material.dart';

import 'characters_screen.dart';
import 'comics_screen.dart';
import 'home_screen.dart';
import 'titles_screen.dart';
import 'watch_order_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  /// Lets child screens switch tabs (e.g. "See all" on the home screen).
  static void goTo(BuildContext context, int tab) =>
      context.findAncestorStateOfType<_HomeShellState>()?._select(tab);

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    // Not an IndexedStack on purpose: the Heroes tab hosts a WebView-backed
    // 3D viewer that we want torn down when the tab is not visible.
    final pages = const [
      HomeScreen(),
      TitlesScreen(),
      WatchOrderScreen(),
      CharactersScreen(),
      ComicsScreen(),
    ];
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie_rounded),
            label: 'Titles',
          ),
          NavigationDestination(
            icon: Icon(Icons.timeline_outlined),
            selectedIcon: Icon(Icons.timeline_rounded),
            label: 'Watch Order',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield_rounded),
            label: 'Heroes',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories_rounded),
            label: 'Comics',
          ),
        ],
      ),
    );
  }
}
