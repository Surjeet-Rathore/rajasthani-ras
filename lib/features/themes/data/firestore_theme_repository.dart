import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rajasthani_ras/features/themes/domain/idiom_theme.dart';
import 'package:rajasthani_ras/features/themes/domain/theme_repository.dart';

class FirestoreThemeRepository implements ThemeRepository {
  FirestoreThemeRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<List<IdiomTheme>> getActiveThemes() async {
    final snapshot = await _firestore
        .collection('themes')
        .where('isActive', isEqualTo: true)
        .get();
    final themes =
        snapshot.docs
            .map(
              (document) =>
                  IdiomTheme.fromFirestore(document.id, document.data()),
            )
            .toList()
          ..sort(
            (first, second) => first.sortOrder.compareTo(second.sortOrder),
          );
    return themes;
  }
}
