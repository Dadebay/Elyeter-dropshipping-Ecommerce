import 'package:dio/dio.dart';
import 'package:elyeter/core/network/api_client.dart';
import 'package:elyeter/features/product/data/datasources/product_remote_data_source.dart';
import 'package:elyeter/features/product/domain/entities/product_query.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingClient extends ApiClient {
  _RecordingClient() : super(Dio());

  final requests = <({String path, Map<String, dynamic> query})>[];

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    requests.add((path: path, query: queryParameters ?? {}));
    return {
      'items': <dynamic>[],
      'totalCount': 0,
      'page': queryParameters?['page'] ?? 1,
    };
  }
}

void main() {
  test(
    'product list sends supported numeric category and brand filters',
    () async {
      final client = _RecordingClient();
      await ProductRemoteDataSourceImpl(client).list(
        query: const ProductQuery(categoryId: 18, brandId: 1531),
        page: 1,
        size: 10,
      );

      expect(client.requests, hasLength(1));
      expect(client.requests.single.path, '/products');
      expect(client.requests.single.query, {
        'page': 1,
        'size': 10,
        'sort': 'new',
        'category_id': 18,
        'brand_id': 1531,
      });
    },
  );

  test('multiple brands each use brand_id in separate requests', () async {
    final client = _RecordingClient();
    await ProductRemoteDataSourceImpl(client).list(
      query: const ProductQuery(categoryId: 18, brandIds: [1531, 2448]),
      page: 1,
      size: 10,
    );

    expect(client.requests, hasLength(2));
    expect(
      client.requests.map((request) => request.query['brand_id']),
      containsAll([1531, 2448]),
    );
    expect(
      client.requests.every(
        (request) =>
            request.query['category_id'] == 18 &&
            !request.query.containsKey('category_slug') &&
            !request.query.containsKey('brand_slug'),
      ),
      isTrue,
    );
  });
}
