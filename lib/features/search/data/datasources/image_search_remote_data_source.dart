import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/image_search.dart';
import '../models/image_search_model.dart';

abstract interface class ImageSearchRemoteDataSource {
  Future<ImageSearch> create(String path);
  Future<ImageSearch> byId(int id);
}

class ImageSearchRemoteDataSourceImpl implements ImageSearchRemoteDataSource {
  ImageSearchRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<ImageSearch> create(String path) async {
    final lower = path.toLowerCase();
    final type = lower.endsWith('.png')
        ? DioMediaType('image', 'png')
        : lower.endsWith('.webp')
        ? DioMediaType('image', 'webp')
        : DioMediaType('image', 'jpeg');
    final data = await _client.post(
      ApiEndpoints.imageSearch,
      data: FormData.fromMap({
        'file': await MultipartFile.fromFile(
          path,
          filename: path.split('/').last,
          contentType: type,
        ),
      }),
      // The server asks the marketplace before it answers.
      receiveTimeout: const Duration(seconds: 60),
    );
    return ImageSearchModel.fromJson(asMap(data));
  }

  @override
  Future<ImageSearch> byId(int id) async {
    final data = await _client.get(ApiEndpoints.imageSearchById(id));
    return ImageSearchModel.fromJson(asMap(data));
  }
}
