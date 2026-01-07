import 'package:flutter/material.dart';

enum LoadStatus { initial, loading, success, error }

class RandomImageState {
  const RandomImageState({
    required this.status,
    required this.imageProvider,
    required this.imageRevision,
    required this.fallbackBackground,
    required this.scheme,
    required this.errorMessage,
    required this.hasEverLoaded,
  });

  factory RandomImageState.initial() => RandomImageState(
    status: LoadStatus.initial,
    imageProvider: null,
    imageRevision: 0,
    fallbackBackground: Colors.black,
    scheme: null,
    errorMessage: null,
    hasEverLoaded: false,
  );

  final LoadStatus status;
  final ImageProvider? imageProvider;
  final int imageRevision;

  final Color fallbackBackground;
  final ColorScheme? scheme;

  final String? errorMessage;

  final bool hasEverLoaded;

  bool get isFetching => status == LoadStatus.loading;

  bool get isInitialLoadFailure => status == LoadStatus.error && !hasEverLoaded;

  bool get showErrorBanner => errorMessage != null && hasEverLoaded;

  static const Object _unset = Object();

  RandomImageState copyWith({
    LoadStatus? status,
    ImageProvider? imageProvider,
    int? imageRevision,
    Color? fallbackBackground,
    ColorScheme? scheme,
    Object? errorMessage = _unset,
    bool? hasEverLoaded,
  }) {
    return RandomImageState(
      status: status ?? this.status,
      imageProvider: imageProvider ?? this.imageProvider,
      imageRevision: imageRevision ?? this.imageRevision,
      fallbackBackground: fallbackBackground ?? this.fallbackBackground,
      scheme: scheme ?? this.scheme,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      hasEverLoaded: hasEverLoaded ?? this.hasEverLoaded,
    );
  }
}
