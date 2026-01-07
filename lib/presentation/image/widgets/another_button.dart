import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnotherButton extends StatelessWidget {
  const AnotherButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  static const buttonKey = Key('another_button');
  static const spinnerKey = Key('another_button_spinner');

  void _handlePress() {
    if (isLoading) return;
    HapticFeedback.lightImpact();
    onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 160,
      height: 52,
      child: FilledButton(
        key: buttonKey,

        onPressed: isLoading ? null : _handlePress,
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: theme.colorScheme.surface.withOpacity(0.88),
          foregroundColor: theme.colorScheme.onSurface,
          side: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.12),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    key: spinnerKey,
                    strokeWidth: 2.5,
                    color: Colors.black54,
                  ),
                )
              : Text(
                  'Another',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }
}
