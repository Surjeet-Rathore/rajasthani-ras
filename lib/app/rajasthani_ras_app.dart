import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rajasthani_ras/app/app_theme.dart';
import 'package:rajasthani_ras/features/favorites/domain/favorites_repository.dart';
import 'package:rajasthani_ras/features/idioms/domain/idiom_repository.dart';
import 'package:rajasthani_ras/features/idioms/presentation/bloc/idiom_cubit.dart';
import 'package:rajasthani_ras/features/idioms/presentation/pages/dashboard_page.dart';
import 'package:rajasthani_ras/features/themes/domain/theme_repository.dart';

class RajasthaniRasApp extends StatelessWidget {
  const RajasthaniRasApp({
    this.idiomRepository,
    this.favoritesRepository,
    this.themeRepository,
    this.showAds = false,
    this.configurationMissing = false,
    this.startupError,
    super.key,
  });

  final IdiomRepository? idiomRepository;
  final FavoritesRepository? favoritesRepository;
  final ThemeRepository? themeRepository;
  final bool showAds;
  final bool configurationMissing;
  final String? startupError;

  @override
  Widget build(BuildContext context) {
    final idiomRepository = this.idiomRepository;
    final favoritesRepository = this.favoritesRepository;
    final themeRepository = this.themeRepository;

    final Widget home;
    if (startupError != null) {
      home = FirebaseSetupPage(errorMessage: startupError);
    } else if (configurationMissing) {
      home = const FirebaseSetupPage();
    } else if (idiomRepository == null ||
        favoritesRepository == null ||
        themeRepository == null) {
      home = const FirebaseSetupPage(
        errorMessage: 'The app services have not been configured.',
      );
    } else {
      home = RepositoryProvider<ThemeRepository>.value(
        value: themeRepository,
        child: BlocProvider(
          create: (_) => IdiomCubit(
            idiomRepository: idiomRepository,
            favoritesRepository: favoritesRepository,
          )..start(),
          child: DashboardPage(showAds: showAds),
        ),
      );
    }

    return MaterialApp(
      title: 'Rajasthani Ras',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: home,
    );
  }
}

class FirebaseSetupPage extends StatelessWidget {
  const FirebaseSetupPage({this.errorMessage, super.key});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.terracotta,
                  size: 44,
                ),
                const SizedBox(height: 20),
                Text(
                  errorMessage == null
                      ? 'Connect your Firebase project'
                      : 'Firebase needs attention',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  errorMessage ??
                      'Add the Firebase app settings as dart-define values to load idioms and themes.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (errorMessage == null) ...[
                  const SizedBox(height: 20),
                  const SelectableText(
                    'FIREBASE_API_KEY\n'
                    'FIREBASE_APP_ID\n'
                    'FIREBASE_MESSAGING_SENDER_ID\n'
                    'FIREBASE_PROJECT_ID',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
