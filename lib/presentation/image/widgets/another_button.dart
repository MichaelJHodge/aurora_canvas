import 'package:flutter/material.dart';

class AnotherButton extends StatelessWidget {
  const AnotherButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  // Stable keys for widget tests.
  static const buttonKey = Key('another_button');
  static const loadingKey = ValueKey('another_button_loading');
  static const spinnerKey = Key('another_button_spinner');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Semantics(
      button: true,
      label: isLoading ? 'Loading another image' : 'Load another image',
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isLoading ? 0.85 : 1,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 160),
          scale: isLoading ? 0.98 : 1.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                if (!isLoading)
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            child: SizedBox(
              width: 180,
              height: 48,
              child: FilledButton(
                key: buttonKey,
                onPressed: isLoading ? null : onPressed,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: isLoading
                      ? const _LoadingLabel(key: loadingKey)
                      : const Text('Another'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingLabel extends StatelessWidget {
  const _LoadingLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // FittedBox prevents RenderFlex overflow in tight layouts (like widget tests).
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              key: AnotherButton.spinnerKey,
              strokeWidth: 2,
              color: cs.onPrimary,
            ),
          ),
          const SizedBox(width: 10),
          const Text('Loading…'),
        ],
      ),
    );
  }
}
