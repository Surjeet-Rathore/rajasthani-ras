import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rajasthani_ras/app/app_theme.dart';
import 'package:rajasthani_ras/features/ads/presentation/widgets/banner_ad_slot.dart';
import 'package:rajasthani_ras/features/idioms/domain/idiom.dart';
import 'package:rajasthani_ras/features/idioms/presentation/bloc/idiom_cubit.dart';
import 'package:rajasthani_ras/features/themes/domain/theme_repository.dart';
import 'package:rajasthani_ras/features/themes/presentation/pages/share_preview_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({this.showAds = false, super.key});

  final bool showAds;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return BlocListener<IdiomCubit, IdiomState>(
      listenWhen: (previous, current) =>
          previous.favoriteError != current.favoriteError &&
          current.favoriteError != null,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.favoriteError!)));
        context.read<IdiomCubit>().clearFavoriteError();
      },
      child: Scaffold(
        body: SafeArea(
          child: _selectedTab == 0
              ? _HomeContent(
                  showAds: widget.showAds,
                  onOpenFavorites: () {
                    setState(() => _selectedTab = 1);
                    context.read<IdiomCubit>()
                      ..selectCategory(null)
                      ..setSearchQuery('');
                  },
                )
              : _FavoritesContent(showAds: widget.showAds),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedTab,
          onDestinationSelected: (index) {
            setState(() => _selectedTab = index);
            context.read<IdiomCubit>()
              ..selectCategory(null)
              ..setSearchQuery('');
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded),
              label: 'Explore',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border_rounded),
              selectedIcon: Icon(Icons.favorite_rounded),
              label: 'Saved',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.showAds, required this.onOpenFavorites});

  final bool showAds;
  final VoidCallback onOpenFavorites;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IdiomCubit, IdiomState>(
      builder: (context, state) {
        final cubit = context.read<IdiomCubit>();
        final idioms = state.visibleIdioms();
        return _PageScrollView(
          children: [
            _DashboardHeader(onOpenFavorites: onOpenFavorites),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: cubit.setSearchQuery,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Search sayings or meanings',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const _SectionHeading(
              eyebrow: 'EXPLORE BY MOOD',
              title: 'Pick your kind of wisdom',
            ),
            const SizedBox(height: 14),
            _CategoryStrip(
              selectedId: state.categoryId,
              onSelected: cubit.selectCategory,
            ),
            const SizedBox(height: 28),
            _SectionHeading(
              eyebrow: state.categoryId == null
                  ? 'FROM THE FOLKLORE'
                  : 'CATEGORY',
              title: state.categoryId == null
                  ? 'Sayings to keep close'
                  : _categoryTitle(state.categoryId!),
            ),
            const SizedBox(height: 14),
            _IdiomResults(
              state: state,
              idioms: idioms,
              emptyMessage: state.searchQuery.isNotEmpty
                  ? 'No sayings match that search yet.'
                  : 'No sayings in this category yet.',
            ),
            if (showAds) const BannerAdSlot(),
            const SizedBox(height: 28),
          ],
        );
      },
    );
  }
}

class _FavoritesContent extends StatelessWidget {
  const _FavoritesContent({required this.showAds});

  final bool showAds;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IdiomCubit, IdiomState>(
      builder: (context, state) {
        return _PageScrollView(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 28, 20, 22),
              child: _SectionHeading(
                eyebrow: 'YOUR PERSONAL COLLECTION',
                title: 'Saved sayings',
              ),
            ),
            _IdiomResults(
              state: state,
              idioms: state.visibleIdioms(favoritesOnly: true),
              emptyMessage: 'Save a saying and it will be waiting here.',
              favoritesOnly: true,
            ),
            if (showAds) const BannerAdSlot(),
          ],
        );
      },
    );
  }
}

class _PageScrollView extends StatelessWidget {
  const _PageScrollView({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: ListView(padding: EdgeInsets.zero, children: children),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.onOpenFavorites});

  final VoidCallback onOpenFavorites;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: AppColors.terracotta,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.wb_sunny_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'RAJASTHANI RAS',
                  style: TextStyle(
                    color: AppColors.maroon,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              IconButton(
                onPressed: onOpenFavorites,
                tooltip: 'Saved sayings',
                icon: const Icon(Icons.bookmark_border_rounded),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.maroon, AppColors.terracotta],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -9,
                  top: -19,
                  child: Icon(
                    Icons.wb_sunny_outlined,
                    size: 112,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Padharo सा!',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'A little Rajasthan in every saying.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.86),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const _FolkMotif(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FolkMotif extends StatelessWidget {
  const _FolkMotif();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      children: [
        for (var index = 0; index < 5; index++)
          Container(
            width: index.isEven ? 8 : 5,
            height: index.isEven ? 8 : 5,
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: const BoxDecoration(
              color: AppColors.saffron,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: const TextStyle(
              color: AppColors.terracotta,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _CategoryStrip extends StatelessWidget {
  const _CategoryStrip({required this.selectedId, required this.onSelected});

  final String? selectedId;
  final ValueChanged<String?> onSelected;

  static const _categories = [
    ('funny', 'Funny', Icons.sentiment_very_satisfied_rounded),
    ('wisdom', 'Wisdom', Icons.lightbulb_outline_rounded),
    ('relationships', 'Relationships', Icons.diversity_3_rounded),
    ('work_life', 'Work & life', Icons.work_outline_rounded),
    ('advice', 'Advice', Icons.tips_and_updates_outlined),
    ('culture_festivals', 'Culture', Icons.festival_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 43,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        children: [
          _CategoryChip(
            label: 'All',
            icon: Icons.grid_view_rounded,
            selected: selectedId == null,
            onTap: () => onSelected(null),
          ),
          for (final (id, label, icon) in _categories)
            _CategoryChip(
              label: label,
              icon: icon,
              selected: selectedId == id,
              onTap: () => onSelected(id),
            ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        avatar: Icon(icon, size: 16),
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.saffron.withValues(alpha: 0.28),
        side: BorderSide(
          color: selected ? AppColors.saffron : AppColors.border,
        ),
        labelStyle: TextStyle(
          color: selected ? AppColors.maroon : AppColors.ink,
          fontWeight: FontWeight.w600,
        ),
        showCheckmark: false,
      ),
    );
  }
}

class _IdiomResults extends StatelessWidget {
  const _IdiomResults({
    required this.state,
    required this.idioms,
    required this.emptyMessage,
    this.favoritesOnly = false,
  });

  final IdiomState state;
  final List<Idiom> idioms;
  final String emptyMessage;
  final bool favoritesOnly;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(36),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: _MessageCard(
          icon: Icons.cloud_off_rounded,
          title: 'Could not load sayings',
          message: state.errorMessage!,
        ),
      );
    }
    if (idioms.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: _MessageCard(
          icon: favoritesOnly
              ? Icons.bookmark_border_rounded
              : Icons.auto_awesome_outlined,
          title: favoritesOnly ? 'Your collection is waiting' : 'Coming soon',
          message: emptyMessage,
        ),
      );
    }

    return Column(
      children: [
        for (final idiom in idioms)
          _IdiomCard(
            idiom: idiom,
            isFavorite: state.favoriteIds.contains(idiom.id),
          ),
      ],
    );
  }
}

class _IdiomCard extends StatelessWidget {
  const _IdiomCard({required this.idiom, required this.isFavorite});

  final Idiom idiom;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.fromLTRB(18, 17, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  idiom.rajasthaniText,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 20, height: 1.45),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: isFavorite ? 'Remove from saved' : 'Save saying',
                onPressed: () =>
                    context.read<IdiomCubit>().toggleFavorite(idiom),
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? AppColors.terracotta : AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(idiom.hindiMeaning, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 3),
          Text(
            idiom.englishMeaning,
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          if (idiom.romanTransliteration?.isNotEmpty == true) ...[
            const SizedBox(height: 5),
            Text(
              idiom.romanTransliteration!,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                final themeRepository = RepositoryProvider.of<ThemeRepository>(
                  context,
                );
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SharePreviewPage(
                      idiom: idiom,
                      themeRepository: themeRepository,
                    ),
                  ),
                );
              },
              icon: Icon(
                kIsWeb ? Icons.visibility_outlined : Icons.ios_share_rounded,
                size: 17,
              ),
              label: Text(kIsWeb ? 'Preview' : 'Preview & share'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.terracotta, size: 30),
          const SizedBox(height: 11),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

String _categoryTitle(String categoryId) {
  return switch (categoryId) {
    'funny' => 'Funny sayings',
    'wisdom' => 'Everyday wisdom',
    'relationships' => 'People & relationships',
    'work_life' => 'Work & life',
    'advice' => 'Advice worth keeping',
    'culture_festivals' => 'Culture & festivals',
    _ => 'Sayings',
  };
}
