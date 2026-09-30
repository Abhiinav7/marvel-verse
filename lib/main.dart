import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/characters_provider.dart';
import 'providers/comics_provider.dart';
import 'providers/movies_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/user_provider.dart';
import 'screens/home_shell.dart';
import 'services/comicvine_service.dart';
import 'services/storage_service.dart';
import 'services/superhero_service.dart';
import 'services/tmdb_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
  );
  final storage = StorageService();
  await storage.init();
  runApp(MarvelVerseApp(storage: storage));
}

class MarvelVerseApp extends StatelessWidget {
  const MarvelVerseApp({super.key, required this.storage});

  final StorageService storage;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MoviesProvider(TmdbService())..loadSummaries(),
        ),
        ChangeNotifierProvider(
          create: (_) => CharactersProvider(SuperheroService())..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => ComicsProvider(ComicVineService()),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider(storage)),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: MaterialApp(
        title: 'Marvel Verse',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        scrollBehavior: const _DragEverywhere(),
        home: const HomeShell(),
      ),
    );
  }
}

/// Lets carousels and lists be dragged with a mouse/trackpad on web & desktop.
class _DragEverywhere extends MaterialScrollBehavior {
  const _DragEverywhere();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    ...super.dragDevices,
    PointerDeviceKind.mouse,
  };
}
