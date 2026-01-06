import 'package:flutter/material.dart';

/// Keeps background readable by blending an image-derived color with theme surface.
Color blendBackgroundForTheme({
  required ThemeData theme,
  required Color base,
  double surfaceBlend = 0.2,
}) {
  return Color.lerp(base, theme.colorScheme.surface, surfaceBlend) ?? base;
}
