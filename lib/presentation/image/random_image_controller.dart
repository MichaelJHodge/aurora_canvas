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
import 'package:flutter/foundation.dart';
import '../../domain/random_image.dart';

class RandomImageController extends ChangeNotifier {
  RandomImageController(this._repo, {http.Client? httpClient})
    : _http = httpClient ?? http.Client(),
      _ownsHttpClient = httpClient == null;

  final RandomImageRepository _repo;
  final http.Client _http;
  final bool _ownsHttpClient;

  RandomImageState _state = RandomImageState.initial();
  RandomImageState get state => _state;

  String? _lastImageId;

  Future<void> init() async {
    if (_state.status != LoadStatus.initial) return;
    await fetchAnother();
  }

  Future<void> fetchAnother({BuildContext? context}) async {
    if (_state.isFetching) return;

    // IMPORTANT:
    // - We set loading, but we DO NOT clear errorMessage here.
    //   This prevents the “it instantly worked” feeling after an error
    //   (the error overlay stays until we actually have a good new image).
    _state = _state.copyWith(status: LoadStatus.loading);
    notifyListeners();

    try {
      // Try a few times to avoid duplicates / broken Unsplash URLs.
      const maxAttempts = 5;

      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        RandomImage img = await _repo.getRandomImage();

        // Avoid duplicates (best-effort)
        int dedupeAttempts = 0;
        while (img.url.toString() == _lastImageId && dedupeAttempts < 3) {
          img = await _repo.getRandomImage();
          dedupeAttempts++;
        }

        final displayUrl = _withQuery(img.url, {
          'w': '900',
          'h': '900',
          'fit': 'crop',
          'auto': 'format',
          'q': '85',
        });

        final thumbUrl = _withQuery(img.url, {
          'w': '140',
          'h': '140',
          'fit': 'crop',
          'auto': 'format',
          'q': '60',
        });

        try {
          // 1) Fetch bytes ourselves so 404s are handled as normal failures
          //    (NO Flutter image pipeline exceptions / spam).
          final displayBytes = await _fetchImageBytes(displayUrl);
          final thumbBytes = await _fetchImageBytes(thumbUrl);

          // 2) Now we can safely build a provider that can’t 404.
          final provider = MemoryImage(displayBytes);

          // 3) Optional precache (now safe, because it’s memory-backed).
          if (context != null && context.mounted) {
            await precacheImage(provider, context);
          }

          // 4) Compute scheme
          final brightness =
              WidgetsBinding.instance.platformDispatcher.platformBrightness;

          final scheme = await colorSchemeFromImageBytes(
            bytes: thumbBytes,
            brightness: brightness,
          );

          _lastImageId = img.url.toString();

          _state = _state.copyWith(
            imageProvider: provider,
            imageRevision: _state.imageRevision + 1,
            status: LoadStatus.success,
            errorMessage: null,
            hasEverLoaded: true,
            scheme: scheme,
            fallbackBackground: scheme?.primaryContainer,
          );
          notifyListeners();
          return; // success, stop retrying
        } on AppFailure {
          // Broken URL / timeout / etc. Try another image.
          continue;
        } on TimeoutException {
          continue;
        } catch (_) {
          // Treat any other unexpected image fetch failure as “try another”.
          continue;
        }
      }

      // If all attempts failed:
      throw const NetworkTimeoutFailure();
    } catch (e) {
      final msg = _friendlyError(e);

      // If we’ve already shown an image once, keep the old image visible
      // and just surface the error overlay on top.
      final firstFailure = !_state.hasEverLoaded;

      _state = _state.copyWith(
        status: firstFailure ? LoadStatus.error : LoadStatus.success,
        errorMessage: msg,
      );
      notifyListeners();
    } finally {
      // Make sure we leave loading state if we didn't early-return.
      if (_state.status == LoadStatus.loading) {
        _state = _state.copyWith(
          status: _state.hasEverLoaded ? LoadStatus.success : LoadStatus.error,
        );
        notifyListeners();
      }
    }
  }

  Future<Uint8List> _fetchImageBytes(Uri url) async {
    final res = await _http.get(url).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200 || res.bodyBytes.isEmpty) {
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
      return 'Couldn’t load that one. Let’s try another.';
    }
    if (e is InvalidResponseFailure) {
      return 'Received an invalid response from the server.';
    }
    if (e is TimeoutException) {
      return 'Timed out loading an image. Please try again.';
    }
    return 'Couldn’t load that one. Let’s try another.';
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

  @override
  void dispose() {
    if (_ownsHttpClient) _http.close();
    super.dispose();
  }
}
