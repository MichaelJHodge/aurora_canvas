import 'dart:async';
import 'dart:typed_data';

import 'package:aurora_canvas/data/random_image_repository.dart';
import 'package:aurora_canvas/domain/random_image.dart';
import 'package:aurora_canvas/presentation/image/random_image_controller.dart';
import 'package:aurora_canvas/presentation/image/random_image_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockRepo extends Mock implements RandomImageRepository {}

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockRepo repo;
  late _MockHttpClient httpClient;

  setUp(() {
    repo = _MockRepo();
    httpClient = _MockHttpClient();

    // mocktail needs a fallback for any() on non-primitive types.
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  Uint8List _fakeThumbBytes() =>
      Uint8List.fromList(List.generate(32, (i) => i));

  group('RandomImageController', () {
    test('starts in initial state', () {
      final c = RandomImageController(repo, httpClient: httpClient);
      expect(c.state.status, LoadStatus.initial);
      expect(c.state.imageProvider, isNull);
      expect(c.state.errorMessage, isNull);
      expect(c.state.hasEverLoaded, isFalse);
    });

    test(
      'successful fetch sets loading then success and updates provider + revision',
      () async {
        when(() => repo.getRandomImage()).thenAnswer(
          (_) async => RandomImage(
            url: Uri.parse(
              'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
            ),
          ),
        );

        // Thumbnail fetch succeeds (200 with bytes)
        when(
          () => httpClient.get(any()),
        ).thenAnswer((_) async => http.Response.bytes(_fakeThumbBytes(), 200));

        final c = RandomImageController(repo, httpClient: httpClient);

        final snapshots = <RandomImageState>[];
        c.addListener(() => snapshots.add(c.state));

        await c.fetchAnother();

        // We expect at least one loading snapshot first.
        expect(snapshots.first.status, LoadStatus.loading);

        expect(c.state.status, LoadStatus.success);
        expect(c.state.hasEverLoaded, isTrue);
        expect(c.state.imageRevision, greaterThan(0));
        expect(c.state.imageProvider, isA<CachedNetworkImageProvider>());
        expect(c.state.errorMessage, isNull);

        final provider = c.state.imageProvider as CachedNetworkImageProvider;

        // Should apply resizing params to the displayed image request.
        expect(provider.url, contains('w=900'));
        expect(provider.url, contains('h=900'));
        expect(provider.url, contains('fit=crop'));
      },
    );

    test(
      'initial failure (no previous load) sets status=error and does not set imageProvider',
      () async {
        when(() => repo.getRandomImage()).thenAnswer(
          (_) async => RandomImage(
            url: Uri.parse('https://images.unsplash.com/photo-abc'),
          ),
        );

        // Thumbnail request returns 404
        when(
          () => httpClient.get(any()),
        ).thenAnswer((_) async => http.Response.bytes(Uint8List(0), 404));

        final c = RandomImageController(repo, httpClient: httpClient);

        await c.fetchAnother();

        expect(c.state.hasEverLoaded, isFalse);
        expect(c.state.status, LoadStatus.error);
        expect(c.state.imageProvider, isNull);
        expect(c.state.isInitialLoadFailure, isTrue);
        expect(c.state.errorMessage, isNotNull);
      },
    );

    test(
      'non-initial failure keeps status=success and sets errorMessage (banner path)',
      () async {
        // First call succeeds.
        when(() => repo.getRandomImage()).thenAnswer(
          (_) async => RandomImage(
            url: Uri.parse('https://images.unsplash.com/photo-1'),
          ),
        );
        when(
          () => httpClient.get(any()),
        ).thenAnswer((_) async => http.Response.bytes(_fakeThumbBytes(), 200));

        final c = RandomImageController(repo, httpClient: httpClient);
        await c.fetchAnother();

        expect(c.state.hasEverLoaded, isTrue);
        expect(c.state.status, LoadStatus.success);
        expect(c.state.imageProvider, isNotNull);

        // Second call fails at thumbnail stage.
        when(() => repo.getRandomImage()).thenAnswer(
          (_) async => RandomImage(
            url: Uri.parse('https://images.unsplash.com/photo-2'),
          ),
        );
        when(
          () => httpClient.get(any()),
        ).thenAnswer((_) async => http.Response.bytes(Uint8List(0), 404));

        await c.fetchAnother();

        // Should NOT knock the UI into full-page error
        expect(c.state.status, LoadStatus.success);
        expect(c.state.imageProvider, isNotNull);
        expect(c.state.showErrorBanner, isTrue);
        expect(c.state.errorMessage, contains('HTTP 404'));
      },
    );

    test('dismissError clears the banner errorMessage', () async {
      // Seed success first
      when(() => repo.getRandomImage()).thenAnswer(
        (_) async =>
            RandomImage(url: Uri.parse('https://images.unsplash.com/photo-1')),
      );
      when(
        () => httpClient.get(any()),
      ).thenAnswer((_) async => http.Response.bytes(_fakeThumbBytes(), 200));

      final c = RandomImageController(repo, httpClient: httpClient);
      await c.fetchAnother();

      // Then fail
      when(() => repo.getRandomImage()).thenAnswer(
        (_) async =>
            RandomImage(url: Uri.parse('https://images.unsplash.com/photo-2')),
      );
      when(
        () => httpClient.get(any()),
      ).thenAnswer((_) async => http.Response.bytes(Uint8List(0), 404));

      await c.fetchAnother();

      expect(c.state.showErrorBanner, isTrue);

      c.dismissError();

      expect(c.state.errorMessage, isNull);
      expect(c.state.showErrorBanner, isFalse);
    });

    test(
      'timeout while fetching thumbnail becomes timeout-friendly message',
      () async {
        when(() => repo.getRandomImage()).thenAnswer(
          (_) async => RandomImage(
            url: Uri.parse('https://images.unsplash.com/photo-1'),
          ),
        );

        when(
          () => httpClient.get(any()),
        ).thenThrow(TimeoutException('timeout'));

        final c = RandomImageController(repo, httpClient: httpClient);

        await c.fetchAnother();

        expect(c.state.status, LoadStatus.error);
        expect(c.state.errorMessage, contains('Timed out'));
      },
    );
  });
}
