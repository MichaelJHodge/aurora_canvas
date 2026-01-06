import 'package:flutter/material.dart';

/// Computes a ColorScheme from an image URL.
/// Best-effort: returns null if the image can't be fetched/decoded.
class ImageColorScheme {
  static Future<ColorScheme?> fromUrl(
    Uri imageUrl, {
    required Brightness brightness,
    int sampleSize = 128,
  }) async {
    try {
      final provider = ResizeImage(
        NetworkImage(imageUrl.toString()),
        width: sampleSize,
        height: sampleSize,
        allowUpscaling: false,
      );

      return await ColorScheme.fromImageProvider(
        provider: provider,
        brightness: brightness,
      );
    } catch (_) {
      return null;
    }
  }
}
