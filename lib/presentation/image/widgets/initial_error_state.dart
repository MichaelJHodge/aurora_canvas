import 'package:flutter/material.dart';

class InitialErrorState extends StatelessWidget {
  const InitialErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      liveRegion: true,
      label: 'Error loading image. $message',
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Card(
          elevation: 0,
          color: theme.colorScheme.surface.withValues(alpha: 0.75),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.25)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 36,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                ),
                const SizedBox(height: 10),
                Text(
                  'Couldn’t load an image',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: 160,
                  height: 44,
                  child: FilledButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
