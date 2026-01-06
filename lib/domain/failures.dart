sealed class AppFailure implements Exception {
  const AppFailure();
}

class NetworkTimeoutFailure extends AppFailure {
  const NetworkTimeoutFailure();
}

class BadResponseFailure extends AppFailure {
  final int statusCode;
  const BadResponseFailure(this.statusCode);
}

class InvalidResponseFailure extends AppFailure {
  const InvalidResponseFailure();
}

class UnknownFailure extends AppFailure {
  final Object error;
  const UnknownFailure(this.error);
}
