import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ThemeImageCacheManager extends CacheManager {
  ThemeImageCacheManager._()
    : super(
        Config(
          'rajasthani_theme_images',
          stalePeriod: const Duration(days: 365),
          maxNrOfCacheObjects: 500,
        ),
      );

  static final ThemeImageCacheManager instance = ThemeImageCacheManager._();
}
