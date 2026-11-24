import 'package:sembast/sembast.dart';
import 'package:rajasthani_ras/features/favorites/domain/favorites_repository.dart';

class SembastFavoritesRepository implements FavoritesRepository {
  SembastFavoritesRepository(Database database)
    : _database = database,
      _store = stringMapStoreFactory.store('favorite_idioms');

  final Database _database;
  final StoreRef<String, Map<String, Object?>> _store;

  @override
  Stream<Set<String>> watchFavoriteIds() {
    return _store
        .query()
        .onSnapshots(_database)
        .map((records) => records.map((record) => record.key).toSet());
  }

  @override
  Future<void> setFavorite(String idiomId, bool isFavorite) async {
    try {
      if (isFavorite) {
        await _store.record(idiomId).put(_database, {'idiomId': idiomId});
      } else {
        await _store.record(idiomId).delete(_database);
      }
    } on DatabaseException catch (error) {
      throw FavoritesPersistenceException(
        'Could not update favorite: ${error.message}',
      );
    }
  }
}
