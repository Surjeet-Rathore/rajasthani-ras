import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rajasthani_ras/app/rajasthani_ras_app.dart';
import 'package:rajasthani_ras/features/favorites/data/sembast_favorites_repository.dart';
import 'package:rajasthani_ras/features/idioms/domain/idiom.dart';
import 'package:rajasthani_ras/features/idioms/domain/idiom_repository.dart';
import 'package:rajasthani_ras/features/themes/domain/idiom_theme.dart';
import 'package:rajasthani_ras/features/themes/domain/theme_repository.dart';
import 'package:sembast/sembast_memory.dart';

void main() {
  testWidgets('shows Firebase setup guidance when configuration is missing', (
    tester,
  ) async {
    await tester.pumpWidget(const RajasthaniRasApp(configurationMissing: true));

    expect(find.text('Connect your Firebase project'), findsOneWidget);
    expect(find.textContaining('FIREBASE_API_KEY'), findsOneWidget);
  });

  testWidgets('loads sayings and saves a favorite locally', (tester) async {
    final database = await newDatabaseFactoryMemory().openDatabase(
      'widget-test',
    );
    addTearDown(database.close);

    await tester.pumpWidget(
      RajasthaniRasApp(
        idiomRepository: _FakeIdiomRepository(),
        favoritesRepository: SembastFavoritesRepository(database),
        themeRepository: _FakeThemeRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('A little Rajasthan in every saying.'), findsOneWidget);
    await tester.drag(find.byType(ListView).first, const Offset(0, -680));
    await tester.pumpAndSettle();
    expect(find.text('ऊँट के मुँह में जीरा'), findsOneWidget);

    await tester.tap(find.byTooltip('Save saying'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Remove from saved'), findsOneWidget);
  });
}

class _FakeIdiomRepository implements IdiomRepository {
  @override
  Stream<List<Idiom>> watchIdioms() => Stream.value(const [
    Idiom(
      id: 'wisdom-1',
      rajasthaniText: 'ऊँट के मुँह में जीरा',
      hindiMeaning: 'आवश्यकता के मुकाबले बहुत कम',
      englishMeaning: 'A tiny amount compared with what is needed.',
      categoryId: 'wisdom',
    ),
  ]);
}

class _FakeThemeRepository implements ThemeRepository {
  @override
  Future<List<IdiomTheme>> getActiveThemes() async => const [];
}
