class RandomImage {
  final Uri url;

  RandomImage({required this.url});

  factory RandomImage.fromJson(Map<String, dynamic> json) {
    final raw = json['url'];
    if (raw is! String || raw.trim().isEmpty) {
      throw const FormatException('Missing "url"');
    }

    final uri = Uri.tryParse(raw.trim());
    if (uri == null ||
        !uri.isAbsolute ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw const FormatException('Invalid "url"');
    }

    return RandomImage(url: uri);
  }
}
