import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rajasthani_ras/app/rajasthani_ras_app.dart';
import 'package:rajasthani_ras/core/config/firebase_config.dart';
import 'package:rajasthani_ras/core/database/favorites_database.dart';
import 'package:rajasthani_ras/features/favorites/data/sembast_favorites_repository.dart';
import 'package:rajasthani_ras/features/idioms/data/firestore_idiom_repository.dart';
import 'package:rajasthani_ras/features/themes/data/firestore_theme_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final options = FirebaseConfig.fromEnvironment();
  if (options == null) {
    runApp(const RajasthaniRasApp(configurationMissing: true));
    return;
  }

  try {
    await Firebase.initializeApp(options: options);
  } on FirebaseException catch (error) {
    runApp(
      RajasthaniRasApp(
        startupError:
            'Firebase initialization failed: ${error.message ?? error.code}',
      ),
    );
    return;
  }

  final showAds =
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  if (showAds) {
    try {
      await MobileAds.instance.initialize();
    } on PlatformException catch (error) {
      debugPrint('Google Mobile Ads initialization failed: ${error.message}');
    }
  }

  final database = await FavoritesDatabase.open();
  final firestore = FirebaseFirestore.instance;

  runApp(
    RajasthaniRasApp(
      idiomRepository: FirestoreIdiomRepository(firestore),
      favoritesRepository: SembastFavoritesRepository(database.database),
      themeRepository: FirestoreThemeRepository(firestore),
      showAds: showAds,
    ),
  );
}
