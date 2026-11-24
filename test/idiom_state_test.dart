import 'package:flutter_test/flutter_test.dart';
import 'package:rajasthani_ras/features/idioms/domain/idiom.dart';
import 'package:rajasthani_ras/features/idioms/presentation/bloc/idiom_cubit.dart';

void main() {
  const idioms = [
    Idiom(
      id: 'wisdom-1',
      rajasthaniText: 'ऊँट के मुँह में जीरा',
      hindiMeaning: 'आवश्यकता के मुकाबले बहुत कम',
      englishMeaning: 'A tiny amount compared with what is needed.',
      categoryId: 'wisdom',
    ),
    Idiom(
      id: 'funny-1',
      rajasthaniText: 'Sample funny saying',
      hindiMeaning: 'एक मज़ेदार कहावत',
      englishMeaning: 'A humorous saying.',
      categoryId: 'funny',
    ),
  ];

  test('filters idioms by category and searches translated meanings', () {
    const state = IdiomState(
      idioms: idioms,
      categoryId: 'wisdom',
      searchQuery: 'TINY amount',
    );

    expect(state.visibleIdioms().map((idiom) => idiom.id), ['wisdom-1']);
  });

  test('filters the saved sayings list', () {
    const state = IdiomState(idioms: idioms, favoriteIds: {'funny-1'});

    expect(state.visibleIdioms(favoritesOnly: true).map((idiom) => idiom.id), [
      'funny-1',
    ]);
  });
}
