import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:rajasthani_ras/app/app_theme.dart';
import 'package:rajasthani_ras/core/cache/theme_image_cache_manager.dart';
import 'package:rajasthani_ras/features/idioms/domain/idiom.dart';
import 'package:rajasthani_ras/features/themes/domain/idiom_theme.dart';
import 'package:rajasthani_ras/features/themes/domain/theme_repository.dart';
import 'package:share_plus/share_plus.dart';

class SharePreviewPage extends StatefulWidget {
  const SharePreviewPage({
    required this.idiom,
    required this.themeRepository,
    super.key,
  });

  final Idiom idiom;
  final ThemeRepository themeRepository;

  @override
  State<SharePreviewPage> createState() => _SharePreviewPageState();
}

class _SharePreviewPageState extends State<SharePreviewPage> {
  final _previewKey = GlobalKey();
  late final Future<List<IdiomTheme>> _themesFuture;
  String? _selectedThemeId;
  bool _imageLoaded = false;
  bool _imageFailed = false;
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _themesFuture = widget.themeRepository.getActiveThemes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview your share')),
      body: FutureBuilder<List<IdiomTheme>>(
        future: _themesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _PreviewMessage(
              icon: Icons.cloud_off_rounded,
              title: 'Themes could not be loaded',
              message: snapshot.error.toString(),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final themes = snapshot.data!;
          if (themes.isEmpty) {
            return const _PreviewMessage(
              icon: Icons.wallpaper_outlined,
              title: 'No themes available',
              message: 'Please try again when a theme has been added.',
            );
          }

          final selectedTheme = themes.firstWhere(
            (theme) => theme.id == _selectedThemeId,
            orElse: () => themes.first,
          );
          return _buildPreview(context, themes, selectedTheme);
        },
      ),
    );
  }

  Widget _buildPreview(
    BuildContext context,
    List<IdiomTheme> themes,
    IdiomTheme selectedTheme,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final previewWidth = constraints.maxWidth < 390
            ? constraints.maxWidth - 40
            : 350.0;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            Center(
              child: RepaintBoundary(
                key: _previewKey,
                child: _ShareCard(
                  idiom: widget.idiom,
                  theme: selectedTheme,
                  width: previewWidth,
                  onImageLoaded: _markImageLoaded,
                  onImageFailed: _markImageFailed,
                ),
              ),
            ),
            if (_imageFailed) ...[
              const SizedBox(height: 10),
              const Text(
                'This theme image could not be loaded. Choose another theme to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.maroon),
              ),
            ],
            const SizedBox(height: 22),
            const Text(
              'CHOOSE A BACKGROUND',
              style: TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: themes.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final theme = themes[index];
                  final selected = theme.id == selectedTheme.id;
                  return _ThemeOption(
                    theme: theme,
                    selected: selected,
                    onTap: () {
                      setState(() {
                        _selectedThemeId = theme.id;
                        _imageLoaded = false;
                        _imageFailed = false;
                      });
                    },
                  );
                },
              ),
            ),
            if (!kIsWeb) ...[
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: _imageLoaded && !_isSharing ? _shareImage : null,
                icon: _isSharing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.ios_share_rounded),
                label: Text(
                  _isSharing ? 'Preparing image…' : 'Share to WhatsApp',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.maroon,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              if (!_imageLoaded && !_imageFailed)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Preparing the background image…',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  void _markImageLoaded() {
    if (mounted && !_imageLoaded) {
      setState(() {
        _imageLoaded = true;
        _imageFailed = false;
      });
    }
  }

  void _markImageFailed() {
    if (mounted && !_imageFailed) {
      setState(() {
        _imageFailed = true;
        _imageLoaded = false;
      });
    }
  }

  Future<void> _shareImage() async {
    setState(() => _isSharing = true);
    try {
      final renderObject = _previewKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        throw StateError('The share preview is not ready to export.');
      }

      final image = await renderObject.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (byteData == null) {
        throw StateError('The share image could not be generated.');
      }

      final bytes = byteData.buffer.asUint8List(
        byteData.offsetInBytes,
        byteData.lengthInBytes,
      );
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              Uint8List.fromList(bytes),
              mimeType: 'image/png',
              name: 'rajasthani-ras.png',
            ),
          ],
        ),
      );
    } on PlatformException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sharing failed: ${error.message ?? error.code}'),
          ),
        );
      }
    } on StateError catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({
    required this.idiom,
    required this.theme,
    required this.width,
    required this.onImageLoaded,
    required this.onImageFailed,
  });

  final Idiom idiom;
  final IdiomTheme theme;
  final double width;
  final VoidCallback onImageLoaded;
  final VoidCallback onImageFailed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width * 1.28,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.maroon,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: theme.imageUrl,
            cacheManager: kIsWeb ? null : ThemeImageCacheManager.instance,
            fit: BoxFit.cover,
            imageBuilder: (context, imageProvider) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => onImageLoaded(),
              );
              return Image(image: imageProvider, fit: BoxFit.cover);
            },
            placeholder: (context, url) => const ColoredBox(
              color: AppColors.maroon,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
            errorWidget: (context, url, error) {
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => onImageFailed(),
              );
              return const ColoredBox(
                color: AppColors.maroon,
                child: Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              );
            },
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x16000000),
                  Color(0x3D000000),
                  Color(0xC4000000),
                ],
                stops: [0, 0.38, 1],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wb_sunny_rounded, color: AppColors.saffron),
                    SizedBox(width: 8),
                    Text(
                      'RAJASTHANI RAS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  idiom.rajasthaniText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    height: 1.5,
                    shadows: [Shadow(blurRadius: 12, color: Colors.black54)],
                  ),
                ),
                const SizedBox(height: 15),
                Container(width: 46, height: 2, color: AppColors.saffron),
                const SizedBox(height: 14),
                Text(
                  idiom.hindiMeaning,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  idiom.englishMeaning,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  theme.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.theme,
    required this.selected,
    required this.onTap,
  });

  final IdiomTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 112,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.terracotta : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: theme.imageUrl,
                cacheManager: kIsWeb ? null : ThemeImageCacheManager.instance,
                fit: BoxFit.cover,
                placeholder: (_, _) => const ColoredBox(
                  color: AppColors.border,
                  child: Icon(Icons.image_outlined, color: AppColors.muted),
                ),
                errorWidget: (_, _, _) => const ColoredBox(
                  color: AppColors.border,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.muted,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  color: Colors.black54,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 4,
                  ),
                  child: Text(
                    theme.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewMessage extends StatelessWidget {
  const _PreviewMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: AppColors.terracotta),
            const SizedBox(height: 14),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
