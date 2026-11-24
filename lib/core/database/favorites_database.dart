import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

class FavoritesDatabase {
  FavoritesDatabase._(this.database);

  final Database database;

  static Future<FavoritesDatabase> open() async {
    final Database database;
    if (kIsWeb) {
      database = await databaseFactoryWeb.openDatabase('rajasthani_ras.db');
    } else {
      final directory = await getApplicationSupportDirectory();
      await directory.create(recursive: true);
      database = await databaseFactoryIo.openDatabase(
        path.join(directory.path, 'rajasthani_ras.db'),
      );
    }

    return FavoritesDatabase._(database);
  }

  Future<void> close() => database.close();
}
