import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/failures.dart';
import '../domain/random_image.dart';

class RandomImageApi {
  RandomImageApi({http.Client? client})
    : _client = client ?? http.Client(),
      _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;

  static final Uri _endpoint = Uri.parse(
    'https://november7-730026606190.europe-west1.run.app/image',
  );

  void dispose() {
    if (_ownsClient) _client.close();
  }

  Future<RandomImage> fetchRandomImage() async {
    try {
      final res = await _client
          .get(_endpoint, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        throw BadResponseFailure(res.statusCode);
      }

      final decoded = jsonDecode(res.body);
      if (decoded is! Map<String, dynamic>) {
        throw const InvalidResponseFailure();
      }

      return RandomImage.fromJson(decoded);
    } on TimeoutException {
      throw const NetworkTimeoutFailure();
    } on FormatException {
      throw const InvalidResponseFailure();
    } on AppFailure {
      rethrow;
    } catch (e, st) {
      Error.throwWithStackTrace(UnknownFailure(e), st);
    }
  }
}
