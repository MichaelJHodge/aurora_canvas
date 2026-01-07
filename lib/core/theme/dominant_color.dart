import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Computes a reasonably “dominant” color from image bytes.

/// This approach:
/// 1) Decodes a small image (we fetch a thumbnail).
/// 2) Samples pixels on a grid.
/// 3) Picks the most frequent HSV-ish bucket (biased toward saturated/brighter colors).
Future<Color?> dominantColorFromBytes(
  Uint8List bytes, {
  int sampleGrid = 42,
}) async {
  final ui.Image img;
  try {
    img = await decodeImageFromList(bytes);
  } catch (_) {
    return null;
  }

  try {
    final byteData = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) return null;

    final data = byteData.buffer.asUint8List();
    final w = img.width;
    final h = img.height;

    // Grid sampling step.
    final stepX = math.max(1, (w / sampleGrid).floor());
    final stepY = math.max(1, (h / sampleGrid).floor());

    // HSV buckets: hue 12 bins, sat 3 bins, val 3 bins.
    const hueBins = 12;
    const satBins = 3;
    const valBins = 3;

    int bucketIndex(int hb, int sb, int vb) =>
        (hb * satBins * valBins) + (sb * valBins) + vb;

    final counts = List<int>.filled(hueBins * satBins * valBins, 0);

    // Store sums to compute an average color for the winning bucket.
    final sumR = List<int>.filled(counts.length, 0);
    final sumG = List<int>.filled(counts.length, 0);
    final sumB = List<int>.filled(counts.length, 0);

    for (int y = 0; y < h; y += stepY) {
      for (int x = 0; x < w; x += stepX) {
        final i = (y * w + x) * 4;

        final r = data[i];
        final g = data[i + 1];
        final b = data[i + 2];
        final a = data[i + 3];

        if (a < 40) continue;

        final color = Color.fromARGB(a, r, g, b);
        final hsv = HSVColor.fromColor(color);

        if (hsv.saturation < 0.08) continue;
        if (hsv.value < 0.10) continue;

        final hb = ((hsv.hue / 360.0) * hueBins).floor().clamp(0, hueBins - 1);
        final sb = (hsv.saturation * satBins).floor().clamp(0, satBins - 1);
        final vb = (hsv.value * valBins).floor().clamp(0, valBins - 1);

        final idx = bucketIndex(hb, sb, vb);

        final weight =
            1 + (hsv.saturation * 2).round() + (hsv.value * 2).round();

        counts[idx] += weight;
        sumR[idx] += r * weight;
        sumG[idx] += g * weight;
        sumB[idx] += b * weight;
      }
    }

    int best = -1;
    int bestCount = 0;
    for (int i = 0; i < counts.length; i++) {
      if (counts[i] > bestCount) {
        bestCount = counts[i];
        best = i;
      }
    }

    if (best <= -1 || bestCount == 0) return null;

    final rr = (sumR[best] / bestCount).round().clamp(0, 255);
    final gg = (sumG[best] / bestCount).round().clamp(0, 255);
    final bb = (sumB[best] / bestCount).round().clamp(0, 255);

    final base = Color.fromARGB(255, rr, gg, bb);
    final hsl = HSLColor.fromColor(base);

    return hsl.withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0)).toColor();
  } finally {
    img.dispose();
  }
}
