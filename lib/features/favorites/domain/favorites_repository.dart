abstract interface class FavoritesRepository {
  Stream<Set<String>> watchFavoriteIds();

  Future<void> setFavorite(String idiomId, bool isFavorite);
}

class FavoritesPersistenceException implements Exception {
  const FavoritesPersistenceException(this.message);

  final String message;

  @override
  String toString() => message;
}
