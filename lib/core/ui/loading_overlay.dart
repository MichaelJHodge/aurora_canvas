import 'package:flutter/material.dart';

/// A lightweight overlay that can be placed in a Stack above any content.
/// Best used to indicate in-place loading without collapsing layout.
class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.isVisible,
    this.borderRadius = 16,
    this.scrimOpacity = 0.12,
    this.indicator,
  });

  final bool isVisible;
  final double borderRadius;
  final double scrimOpacity;
  final Widget? indicator;

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: ColoredBox(
            color: Colors.black.withOpacity(scrimOpacity),
            child: Center(
              child:
                  indicator ??
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
