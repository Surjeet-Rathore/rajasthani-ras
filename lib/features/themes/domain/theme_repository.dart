import 'package:rajasthani_ras/features/themes/domain/idiom_theme.dart';

abstract interface class ThemeRepository {
  Future<List<IdiomTheme>> getActiveThemes();
}
