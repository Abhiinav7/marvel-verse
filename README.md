# Marvel Verse

A Flutter fan app for the Marvel Cinematic Universe. It uses Provider for state management.

## Features
- **Home**: a live countdown to the next MCU release, your watch-progress ring with "up next", latest releases, fan favourites, a hero strip, saga cards and a quiz banner.
- **Titles**: 53 movies, series and specials. Filter by phase (colour-coded by Infinity Stone) and by movie or series.
- **Title details**: overview, rating, runtime, genres, cast, a YouTube trailer, budget and box office, timeline position and the in-universe year.
- **Watch Order**: switch between release order and chronological (Disney+ timeline) order. Each title has a watched checkbox and progress is saved on the device.
- **Heroes**: a swipeable carousel of 17 heroes and villains, each with an interactive 3D model streamed from Sketchfab (drag to rotate, pinch to zoom). The detail page shows power stats, powers, comic debut and aliases.
- **Comics**: essential story arcs linked to the MCU projects they inspired, live issue search (Comic Vine) and a link to Marvel Unlimited's free issues.
- **Extras**: MCU trivia quiz with fan ranks and a saved best score, global search (titles, heroes, actors), favourites.

## Run
```bash
flutter pub get
flutter run \
  --dart-define=TMDB_API_KEY=<tmdb v3 key> \
  --dart-define=COMICVINE_API_KEY=<comic vine key>
```
Both keys are optional. Without them the app runs on its bundled curated data.

| Source | Used for | Key |
|---|---|---|
| [TMDB](https://www.themoviedb.org/settings/api) | posters, ratings, cast, trailers, box office | free |
| [akabab/superhero-api](https://github.com/akabab/superhero-api) | hero portraits, power stats, comic debut | none |
| [Comic Vine](https://comicvine.gamespot.com/api/) | live comic issue search | free |

Marvel's own developer API (developer.marvel.com) has been retired, which is why comic data comes from Comic Vine.

## 3D models
Each hero streams a fan-made model from [Sketchfab](https://sketchfab.com) through its Viewer API. No downloads or API key are needed, but it does need internet. The artist is credited under each model, as the licences require.

- **Change a model:** find it on Sketchfab and copy the 32-character ID from the model's URL. Then update that hero's `SketchfabModel(id, title, author)` in `lib/data/characters_data.dart`.
- **Framing:** the camera fits the whole model automatically. If one looks too small or cropped, set `distance:` on its `SketchfabModel` (the default is 0.85; smaller is closer).
- **Offline or bundled instead:** remove the `sketchfab:` line and set `modelUrl: 'assets/models/x.glb'`, with the file registered in `pubspec.yaml`.

The models are fan art of Marvel characters. That's fine for a personal app, but Marvel/Disney own the characters, so check the rights before publishing to an app store.

## Structure
```
lib/
  core/       theme (Marvel palette, Bebas Neue) and config (API keys)
  data/       curated MCU titles, heroes, comics, quiz, and models
  services/   TMDB, superhero-api, Comic Vine, local storage
  providers/  Movies, Characters, Comics, User (progress/favs), Quiz
  screens/    home, titles, detail, watch order, heroes, comics, quiz, search
  widgets/    posters, glass cards, countdown, stat bars, 3D viewer
```
