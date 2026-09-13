import 'package:flutter/material.dart';

/// A rounded thumbnail for a meditation/breathing session card. A tinted
/// background with a soft icon glyph so a slow-loading photo never reads as
/// a blank "white block" (Image.network paints nothing until its first
/// frame decodes, which can take ~1s over the network), and a brief fade-in
/// once it does land instead of an abrupt pop.
class SessionThumbnail extends StatelessWidget {
  final String? imageUrl;
  final Color color;
  final double size;
  final double radius;
  const SessionThumbnail({super.key, this.imageUrl, required this.color, this.size = 56, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(radius)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // A white icon at low opacity barely showed up against these pale
          // tint backgrounds — read as "still blank" rather than "loading a
          // real placeholder". A dark, more opaque icon actually reads.
          Icon(Icons.self_improvement_rounded, size: size * 0.5, color: Colors.black.withValues(alpha: 0.22)),
          if (imageUrl != null)
            Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded) return child;
                return AnimatedOpacity(
                  opacity: frame == null ? 0 : 1,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: child,
                );
              },
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
