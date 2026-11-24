import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rajasthani_ras/features/idioms/domain/idiom.dart';
import 'package:rajasthani_ras/features/idioms/domain/idiom_repository.dart';

class FirestoreIdiomRepository implements IdiomRepository {
  FirestoreIdiomRepository(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Stream<List<Idiom>> watchIdioms() {
    return _firestore
        .collection('idioms')
        .where('isPublished', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          final idioms =
              snapshot.docs
                  .map(
                    (document) =>
                        Idiom.fromFirestore(document.id, document.data()),
                  )
                  .toList()
                ..sort(
                  (first, second) =>
                      first.sortOrder.compareTo(second.sortOrder),
                );
          return idioms;
        });
  }
}
