import 'package:flutter/material.dart';

class AnotherButton extends StatelessWidget {
  const AnotherButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Load another image',
      child: SizedBox(
        width: 180,
        height: 48,
        child: FilledButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Another'),
        ),
      ),
    );
  }
}
