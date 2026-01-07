import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';

import 'package:aurora_canvas/data/random_image_repository.dart';
import 'package:aurora_canvas/domain/random_image.dart';
import 'package:aurora_canvas/presentation/image/random_image_controller.dart';
import 'package:aurora_canvas/presentation/image/random_image_state.dart';
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

  Uint8List _fakeBytes() => Uint8List.fromList(List.generate(64, (i) => i));

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

        // Your controller uses the injected httpClient for its thumbnail fetch
        when(
          () => httpClient.get(any()),
        ).thenAnswer((_) async => http.Response.bytes(_fakeBytes(), 200));

        final c = RandomImageController(repo, httpClient: httpClient);

        final snapshots = <RandomImageState>[];
        c.addListener(() => snapshots.add(c.state));

        await c.fetchAnother();

        expect(snapshots, isNotEmpty);
        expect(snapshots.first.status, LoadStatus.loading);

        expect(c.state.status, LoadStatus.success);
        expect(c.state.hasEverLoaded, isTrue);
        expect(c.state.imageRevision, greaterThan(0));
        expect(c.state.imageProvider, isNotNull);
        expect(c.state.errorMessage, isNull);

        expect(c.state.imageProvider, isA<MemoryImage>());
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
      'non-initial failure keeps status=success and sets errorMessage (non-blocking error path)',
      () async {
        // First call succeeds.
        when(() => repo.getRandomImage()).thenAnswer(
          (_) async => RandomImage(
            url: Uri.parse('https://images.unsplash.com/photo-1'),
          ),
        );
        when(
          () => httpClient.get(any()),
        ).thenAnswer((_) async => http.Response.bytes(_fakeBytes(), 200));

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
        expect(c.state.errorMessage, isNotNull);
        // showErrorBanner depends on your state rules; keep if still true in your impl.
        expect(c.state.showErrorBanner, isTrue);
      },
    );

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
        expect(c.state.errorMessage, isNotNull);
        expect(c.state.errorMessage!.toLowerCase(), contains('timed'));
      },
    );
  });
}
