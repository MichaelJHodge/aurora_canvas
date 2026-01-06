import 'package:flutter/material.dart';

import '../../core/theme/background_blend.dart';
import '../../core/theme/image_color_scheme.dart';
import '../../data/random_image_repository.dart';
import '../../domain/failures.dart';
import 'random_image_state.dart';

class RandomImageController extends ChangeNotifier {
  RandomImageController(this._repo);

  final RandomImageRepository _repo;

  RandomImageState _state = RandomImageState.initial();
  RandomImageState get state => _state;

  Future<void> init() async {
    if (_state.status != LoadStatus.initial) return;
    await fetchAnother();
  }

  void dismissError() {
    if (_state.errorMessage == null) return;
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  Future<void> fetchAnother() async {
    if (_state.isFetching) return;

    _state = _state.copyWith(status: LoadStatus.loading, errorMessage: null);
    notifyListeners();

    try {
      final img = await _repo.getRandomImage();

      _state = _state.copyWith(
        previousImageUrl: _state.imageUrl,
        imageUrl: img.url,
      );
      notifyListeners();

      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;

      final scheme = await ImageColorScheme.fromUrl(
        img.url,
        brightness: brightness,
        sampleSize: 128,
      );

      if (scheme != null) {
        _state = _state.copyWith(
          scheme: scheme,
          fallbackBackground: scheme.surfaceTint,
        );
      }

      _state = _state.copyWith(status: LoadStatus.success, errorMessage: null);
      notifyListeners();
    } catch (e) {
      final msg = _friendlyError(e);
      final newStatus = _state.imageUrl == null
          ? LoadStatus.error
          : LoadStatus.success;

      _state = _state.copyWith(status: newStatus, errorMessage: msg);
      notifyListeners();
      rethrow;
    }
  }

  String _friendlyError(Object e) {
    if (e is NetworkTimeoutFailure) {
      return 'Timed out loading an image. Please try again.';
    }
    if (e is BadResponseFailure) {
      return 'Server returned ${e.statusCode}. Please try again.';
    }
    if (e is InvalidResponseFailure) {
      return 'Received an invalid response from the server.';
    }
    return 'Couldn’t load a new image. Please try again.';
  }

  Color blendedBackgroundForTheme(ThemeData theme) {
    final base = _state.scheme?.surfaceTint ?? _state.fallbackBackground;
    return blendBackgroundForTheme(theme: theme, base: base);
  }
}
