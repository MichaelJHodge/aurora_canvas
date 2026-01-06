import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class SquareImage extends StatelessWidget {
  const SquareImage({
    super.key,
    required this.imageUrl,
    required this.placeholderUrl,
    required this.isInitialLoading,
  });

  final String? imageUrl;
  final String? placeholderUrl;
  final bool isInitialLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final screenW = MediaQuery.sizeOf(context).width;
    final size = (screenW - 40).clamp(220, 360).toDouble();

    return Semantics(
      label: 'Random image',
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: size,
          height: size,
          color: theme.colorScheme.surface.withOpacity(0.6),
          alignment: Alignment.center,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (imageUrl == null) {
      return isInitialLoading
          ? const CircularProgressIndicator()
          : const Icon(Icons.image_not_supported, size: 40);
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: CachedNetworkImage(
        key: ValueKey(imageUrl),
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, _) {
          if (placeholderUrl != null) {
            return CachedNetworkImage(
              imageUrl: placeholderUrl!,
              fit: BoxFit.cover,
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
        errorWidget: (context, _, __) =>
            const Icon(Icons.broken_image_outlined, size: 40),
        fadeInDuration: const Duration(milliseconds: 250),
      ),
    );
  }
}
