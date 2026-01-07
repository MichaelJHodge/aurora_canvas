import 'dart:async';

import 'package:aurora_canvas/data/image_api.dart';
import 'package:aurora_canvas/domain/failures.dart';
import 'package:aurora_canvas/domain/random_image.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    // Needed for mocktail any() on Uri
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  late _MockHttpClient client;
  late RandomImageApi api;

  setUp(() {
    client = _MockHttpClient();
    api = RandomImageApi(client: client);
  });

  test('fetchRandomImage returns RandomImage on 200 with valid JSON', () async {
    when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer(
      (_) async =>
          http.Response('{"url":"https://images.unsplash.com/photo-1"}', 200),
    );

    final res = await api.fetchRandomImage();
    expect(res, isA<RandomImage>());
    expect(res.url.toString(), contains('https://images.unsplash.com/'));
  });

  test('fetchRandomImage throws BadResponseFailure on non-200', () async {
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenAnswer((_) async => http.Response('nope', 500));

    expect(api.fetchRandomImage(), throwsA(isA<BadResponseFailure>()));
  });

  test(
    'fetchRandomImage throws InvalidResponseFailure on invalid JSON shape',
    () async {
      when(
        () => client.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('["not a map"]', 200));

      expect(api.fetchRandomImage(), throwsA(isA<InvalidResponseFailure>()));
    },
  );

  test('fetchRandomImage throws NetworkTimeoutFailure on timeout', () async {
    when(
      () => client.get(any(), headers: any(named: 'headers')),
    ).thenThrow(TimeoutException('timeout'));

    expect(api.fetchRandomImage(), throwsA(isA<NetworkTimeoutFailure>()));
  });

  test(
    'fetchRandomImage throws UnknownFailure on unexpected exception',
    () async {
      when(
        () => client.get(any(), headers: any(named: 'headers')),
      ).thenThrow(Exception('boom'));

      expect(api.fetchRandomImage(), throwsA(isA<UnknownFailure>()));
    },
  );
}
