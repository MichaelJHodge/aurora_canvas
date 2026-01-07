import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'dominant_color.dart';

Future<ColorScheme?> colorSchemeFromImageBytes({
  required Uint8List bytes,
  required Brightness brightness,
}) async {
  final dominant = await dominantColorFromBytes(bytes);
  if (dominant == null) return null;

  return ColorScheme.fromSeed(seedColor: dominant, brightness: brightness);
}
