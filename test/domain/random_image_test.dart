import 'package:flutter_test/flutter_test.dart';
import 'package:aurora_canvas/domain/random_image.dart';

void main() {
  group('RandomImage.fromJson', () {
    test('parses a valid https url', () {
      final image = RandomImage.fromJson({
        'url': 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
      });

      expect(image.url.isAbsolute, isTrue);
      expect(image.url.scheme, anyOf('http', 'https'));
      expect(image.url.toString(), contains('images.unsplash.com'));
    });

    test('throws when url is missing', () {
      expect(() => RandomImage.fromJson({}), throwsA(isA<FormatException>()));
    });

    test('throws when url is empty', () {
      expect(
        () => RandomImage.fromJson({'url': '   '}),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when url is not http/https', () {
      expect(
        () => RandomImage.fromJson({'url': 'ftp://example.com/x'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('throws when url is not parseable', () {
      expect(
        () => RandomImage.fromJson({'url': 'not a url'}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
