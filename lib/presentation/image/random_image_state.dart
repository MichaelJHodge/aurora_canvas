import 'package:flutter/material.dart';

enum LoadStatus { initial, loading, success, error }

@immutable
class RandomImageState {
  final LoadStatus status;
  final Uri? imageUrl;
  final Uri? previousImageUrl;

  final ColorScheme? scheme;
  final Color fallbackBackground;

  final String? errorMessage;

  const RandomImageState({
    required this.status,
    required this.imageUrl,
    required this.previousImageUrl,
    required this.scheme,
    required this.fallbackBackground,
    required this.errorMessage,
  });

  factory RandomImageState.initial() => const RandomImageState(
    status: LoadStatus.initial,
    imageUrl: null,
    previousImageUrl: null,
    scheme: null,
    fallbackBackground: Colors.black,
    errorMessage: null,
  );

  bool get isFetching => status == LoadStatus.loading;

  bool get hasImage => imageUrl != null;

  bool get showErrorBanner => (errorMessage?.isNotEmpty ?? false);

  bool get isInitialLoadFailure =>
      status == LoadStatus.error && imageUrl == null;

  RandomImageState copyWith({
    LoadStatus? status,
    Uri? imageUrl,
    Uri? previousImageUrl,
    ColorScheme? scheme,
    Color? fallbackBackground,
    String? errorMessage,
  }) {
    return RandomImageState(
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      previousImageUrl: previousImageUrl ?? this.previousImageUrl,
      scheme: scheme ?? this.scheme,
      fallbackBackground: fallbackBackground ?? this.fallbackBackground,
      errorMessage: errorMessage,
    );
  }
}
