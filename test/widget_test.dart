import 'package:flutter_test/flutter_test.dart';
import 'package:testing/data/mcu_data.dart';
import 'package:testing/providers/movies_provider.dart';
import 'package:testing/providers/quiz_provider.dart';
import 'package:testing/services/tmdb_service.dart';

void main() {
  test('curated MCU data has unique ids and chronological positions', () {
    expect(mcuTitles.map((t) => t.id).toSet().length, mcuTitles.length);
    expect(
      mcuTitles.map((t) => t.chronoOrder).toSet().length,
      mcuTitles.length,
    );
  });

  test('watch orders sort correctly', () {
    final p = MoviesProvider(TmdbService());
    expect(p.watchOrder(WatchOrder.release).first.id, 'iron-man');
    expect(
      p.watchOrder(WatchOrder.chronological).first.id,
      'captain-america-tfa',
    );
  });

  test('quiz scores correct answers', () {
    final q = QuizProvider();
    q.answer(q.current.answer);
    expect(q.score, 1);
  });
}
