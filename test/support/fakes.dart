import 'dart:convert';
import 'dart:typed_data';

import 'package:aurora_canvas/presentation/image/image_feature.dart';
import 'package:flutter/material.dart';

/// 1×1 transparent PNG.
Uint8List oneByOnePngBytes() {
  const b64 =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAA'
      'AAC0lEQVR42mP8/x8AAwMB/6X9lC0AAAAASUVORK5CYII=';
  return base64Decode(b64);
}

ImageProvider testImageProvider() => MemoryImage(oneByOnePngBytes());

class FakeRandomImageController extends ChangeNotifier
    implements RandomImageController {
  FakeRandomImageController(this._state);

  RandomImageState _state;

  int fetchAnotherCalls = 0;
  int dismissErrorCalls = 0;
  int initCalls = 0;

  @override
  RandomImageState get state => _state;

  set state(RandomImageState value) {
    _state = value;
    notifyListeners();
  }

  @override
  Future<void> init() async {
    initCalls++;
    // Do nothing in tests; we’ll set state directly.
  }

  @override
  Future<void> fetchAnother() async {
    fetchAnotherCalls++;
  }

  @override
  void dismissError() {
    dismissErrorCalls++;
    state = state.copyWith(errorMessage: null);
  }

  @override
  Color blendedBackgroundForTheme(ThemeData theme) => theme.colorScheme.surface;
}
