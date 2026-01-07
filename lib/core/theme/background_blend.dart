import 'package:flutter/material.dart';

/// Produces a background color that:
/// - feels immersive (uses image scheme)
/// - still respects readability (blends toward surface)
Color blendedBackground({
  required ThemeData theme,
  required ColorScheme? imageScheme,
  required Color fallback,
}) {
  final base =
      imageScheme?.primaryContainer ?? imageScheme?.surfaceTint ?? fallback;

  // Slightly bias toward theme surface to keep text/buttons readable.
  return Color.lerp(base, theme.colorScheme.surface, 0.22) ?? base;
}

/// A “wow” initial background (not flat grey).
Color initialAuroraBackground(ThemeData theme) {
  final cs = theme.colorScheme;
  // Keep it cohesive with theme + vibrant even on first load.
  return Color.lerp(cs.primaryContainer, cs.tertiaryContainer, 0.45) ??
      cs.primaryContainer;
}
