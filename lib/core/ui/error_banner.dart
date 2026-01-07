import 'package:flutter/material.dart';

/// Generic banner for surfacing non-blocking errors.
/// Provide actions to make it reusable across screens.
class ErrorBanner extends StatelessWidget {
  const ErrorBanner({
    super.key,
    required this.message,
    this.icon = Icons.error_outline,
    this.actions = const [],
    this.onDismiss,
  });

  final String message;
  final IconData icon;
  final List<Widget> actions;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      liveRegion: true,
      label: 'Error: $message',
      child: Material(
        color: theme.colorScheme.errorContainer.withOpacity(0.92),
        elevation: 2,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.onErrorContainer),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (actions.isNotEmpty) Wrap(spacing: 4, children: actions),
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: Icon(
                    Icons.close,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  tooltip: 'Dismiss',
                ),
            ],
          ),
        ),
      ),
    );
  }
}
