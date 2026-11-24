import 'package:flutter_test/flutter_test.dart';
import 'package:rajasthani_ras/features/favorites/data/sembast_favorites_repository.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  test('favorite ids remain available to a new repository instance', () async {
    final database = await newDatabaseFactoryMemory().openDatabase(
      'favorites-test',
    );
    addTearDown(database.close);
    final firstRepository = SembastFavoritesRepository(database);

    await firstRepository.setFavorite('idiom-1', true);

    final secondRepository = SembastFavoritesRepository(database);
    expect(await secondRepository.watchFavoriteIds().first, {'idiom-1'});

    await secondRepository.setFavorite('idiom-1', false);
    expect(await secondRepository.watchFavoriteIds().first, isEmpty);
  });
}
