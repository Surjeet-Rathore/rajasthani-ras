import 'package:rajasthani_ras/features/idioms/domain/idiom.dart';

abstract interface class IdiomRepository {
  Stream<List<Idiom>> watchIdioms();
}
