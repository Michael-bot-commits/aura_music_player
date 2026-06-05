// widgets/artwork.dart
//
// Artwork — loads a cover by asset key with a shimmer placeholder and an
// optional video badge / product shadow. Mosaic — 4-up grid for playlists.
//
// Artwork lives in assets/artwork/<key>.jpg (declared in pubspec). The
// helper [artProvider] centralises that mapping so the dynamic-colour
// extractor and the views agree on one ImageProvider per track.

import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import 'icons.dart';

ImageProvider artProvider(String key) => AssetImage('assets/artwork/$key.jpg');

class Artwork extends StatelessWidget {
  final String artKey;
  final double size;
  final double radius;
  final bool shadow;
  final bool videoBadge;
  const Artwork(this.artKey,
      {super.key, required this.size, this.radius = R.md, this.shadow = false, this.videoBadge = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: shadow ? artworkShadow : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Image(
                image: artProvider(artKey),
                width: size,
                height: size,
                fit: BoxFit.cover,
                // Shimmer-ish placeholder while the image resolves.
                frameBuilder: (context, child, frame, wasSync) {
                  if (wasSync || frame != null) return child;
                  return Container(color: AppColors.bg3);
                },
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.bg3,
                  alignment: Alignment.center,
                  child: Text(
                    artKey.isNotEmpty ? artKey[0].toUpperCase() : '?',
                    style: AppText.display(size * 0.32),
                  ),
                ),
              ),
            ),
          ),
          if (videoBadge)
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: const Color(0x8C000000),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: const AppIcon('videoBadge', size: 13, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

class Mosaic extends StatelessWidget {
  final List<String> arts;
  final double size;
  final double radius;
  const Mosaic(this.arts, {super.key, required this.size, this.radius = R.sm});

  @override
  Widget build(BuildContext context) {
    final cell = size / 2;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: GridView.count(
          crossAxisCount: 2,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final a in arts.take(4))
              Image(image: artProvider(a), width: cell, height: cell, fit: BoxFit.cover),
          ],
        ),
      ),
    );
  }
}
