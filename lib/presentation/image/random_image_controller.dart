import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/theme/background_blend.dart';
import '../../core/theme/image_color_scheme.dart';
import '../../data/random_image_repository.dart';
import '../../domain/failures.dart';
import 'random_image_state.dart';

class RandomImageController extends ChangeNotifier {
  RandomImageController(this._repo, {http.Client? httpClient})
    : _http = httpClient ?? http.Client(),
      _ownsHttpClient = httpClient == null;

  final RandomImageRepository _repo;
  final http.Client _http;

  RandomImageState _state = RandomImageState.initial();
  RandomImageState get state => _state;
  final bool _ownsHttpClient;
  Timer? _errorAutoDismissTimer;

  Future<void> init() async {
    if (_state.status != LoadStatus.initial) return;
    await fetchAnother();
  }

  void dismissError() {
    _errorAutoDismissTimer?.cancel();
    _errorAutoDismissTimer = null;

    if (_state.errorMessage == null) return;
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }

  Future<void> fetchAnother() async {
    if (_state.isFetching) return;

    // Start loading; keep current image visible.
    _state = _state.copyWith(status: LoadStatus.loading, errorMessage: null);
    notifyListeners();

    try {
      final img = await _repo.getRandomImage();

      // 1) Validate image quickly + compute scheme from a small thumb.
      final thumbBytes = await _fetchThumbnailBytes(img.url);

      // 2) For the actual displayed image, request a reasonable size from Unsplash
      //    (prevents huge downloads on mobile).
      final displayUrl = _withQuery(img.url, {
        'w': '900',
        'h': '900',
        'fit': 'crop',
        'auto': 'format',
        'q': '80',
      });

      final provider = CachedNetworkImageProvider(displayUrl.toString());

      // Swap immediately (still "loading" so overlay can show)
      _state = _state.copyWith(
        imageProvider: provider,
        imageRevision: _state.imageRevision + 1,
      );
      notifyListeners();

      // Best-effort color scheme
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;

      final scheme = await colorSchemeFromImageBytes(
        bytes: thumbBytes,
        brightness: brightness,
      );

      if (scheme != null) {
        _state = _state.copyWith(
          scheme: scheme,
          fallbackBackground: scheme.primaryContainer,
        );
        notifyListeners();
      }

      _state = _state.copyWith(
        status: LoadStatus.success,
        errorMessage: null,
        hasEverLoaded: true,
      );
      notifyListeners();
    } catch (e) {
      final msg = _friendlyError(e);

      final isFirstFailure = !_state.hasEverLoaded;

      _state = _state.copyWith(
        status: isFirstFailure ? LoadStatus.error : LoadStatus.success,
        errorMessage: isFirstFailure ? msg : msg,
      );
      notifyListeners();

      // If it's not the initial load failure, auto-dismiss banner (no snackbar).
      if (!isFirstFailure) {
        _errorAutoDismissTimer?.cancel();
        _errorAutoDismissTimer = Timer(const Duration(seconds: 4), () {
          // Only dismiss if the same error is still showing.
          if (_state.errorMessage == msg) dismissError();
        });
      }

      // NOTE: We intentionally do NOT rethrow anymore.
      // The UI will show the banner (and auto-dismiss it), avoiding double error UI.
    }
  }

  Color blendedBackgroundForTheme(ThemeData theme) {
    if (!_state.hasEverLoaded) {
      return initialAuroraBackground(theme);
    }

    return blendedBackground(
      theme: theme,
      imageScheme: _state.scheme,
      fallback: _state.fallbackBackground,
    );
  }

  Future<Uint8List> _fetchThumbnailBytes(Uri imageUrl) async {
    final thumb = _withQuery(imageUrl, {
      'w': '240',
      'h': '240',
      'fit': 'crop',
      'auto': 'format',
      'q': '60',
    });

    final res = await _http.get(thumb).timeout(const Duration(seconds: 10));

    if (res.statusCode != 200 || res.bodyBytes.isEmpty) {
      // Treat broken Unsplash links as failures so we never swap to a broken image.
      throw BadResponseFailure(res.statusCode);
    }

    return res.bodyBytes;
  }

  Uri _withQuery(Uri base, Map<String, String> add) {
    final merged = Map<String, String>.from(base.queryParameters);
    merged.addAll(add);
    return base.replace(queryParameters: merged);
  }

  String _friendlyError(Object e) {
    if (e is NetworkTimeoutFailure) {
      return 'Timed out loading an image. Please try again.';
    }
    if (e is BadResponseFailure) {
      return 'Couldn’t load that image (HTTP ${e.statusCode}). Tap Another to try again.';
    }
    if (e is InvalidResponseFailure) {
      return 'Received an invalid response from the server.';
    }
    if (e is TimeoutException) {
      return 'Timed out loading an image. Please try again.';
    }
    return 'Couldn’t load a new image. Please try again.';
  }

  @override
  void dispose() {
    _errorAutoDismissTimer?.cancel();
    _errorAutoDismissTimer = null;

    if (_ownsHttpClient) {
      _http.close();
    }
    super.dispose();
  }
}
