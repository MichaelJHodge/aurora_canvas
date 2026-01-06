import '../domain/random_image.dart';
import 'image_api.dart';

class RandomImageRepository {
  final RandomImageApi _api;
  RandomImageRepository(this._api);

  Future<RandomImage> getRandomImage() => _api.fetchRandomImage();
}
