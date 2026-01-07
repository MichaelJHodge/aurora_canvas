import 'package:flutter/material.dart';

class SquareImage extends StatelessWidget {
  const SquareImage({
    super.key,
    required this.imageProvider,
    required this.imageRevision,
    required this.isLoading,
    this.errorMessage,
  });

  final ImageProvider? imageProvider;
  final int imageRevision;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenW = MediaQuery.sizeOf(context).width;
    final size = (screenW - 40).clamp(0.0, 380.0);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: theme.colorScheme.surfaceContainerHighest, // Placeholder color
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Layer 1: The Image with Crossfade
              if (imageProvider != null)
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: Image(
                    key: ValueKey(imageRevision),
                    image: imageProvider!,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),

              // Layer 2: Error State (Overlay)
              if (errorMessage != null)
                Container(
                  color: theme.colorScheme.surface.withOpacity(0.9),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.broken_image_rounded,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
