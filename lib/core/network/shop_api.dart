import '../../features/product/data/models/product_model.dart';
import '../../features/product/domain/entities/product.dart';
import 'api_client.dart';
import 'api_endpoints.dart';
import 'api_response.dart';

/// The smaller public and account endpoints that do not need a separate
/// catalogue repository. All responses are unwrapped by [ApiClient].
class ShopApi {
  ShopApi(this._client);

  final ApiClient _client;

  Future<List<ShopBanner>> banners() async =>
      parseList(await _client.get(ApiEndpoints.banners), ShopBanner.fromJson);

  /// `GET /home` — the background picture of the home header, or null when
  /// none is set and the bundled one applies.
  Future<String?> homeBackground() async {
    final data = await _client.get(ApiEndpoints.home);
    final url = data is Map<String, dynamic> ? data['background_image'] : null;
    return url is String && url.isNotEmpty ? url : null;
  }

  Future<Set<String>> favoriteIds() async {
    final data = await _client.get(ApiEndpoints.favoriteIds);
    if (data is! List) return {};
    return data.whereType<num>().map((id) => id.toInt().toString()).toSet();
  }

  Future<Paginated<Product>> favorites({int page = 1, int size = 20}) async {
    final data = await _client.get(
      ApiEndpoints.favorites,
      queryParameters: {'page': page, 'size': size},
    );
    return Paginated.fromJson(data, ProductModel.fromJson);
  }

  Future<bool> setFavorite(int productId, {required bool favorite}) async {
    final path = ApiEndpoints.favorite(productId);
    final data = favorite
        ? await _client.post(path)
        : await _client.delete(path);
    return asMap(data).boolVal('is_favorite');
  }

  Future<List<SavedLocation>> locations() async => parseList(
    await _client.get(ApiEndpoints.locations),
    SavedLocation.fromJson,
  );

  Future<SavedLocation> createLocation(Map<String, dynamic> values) async =>
      SavedLocation.fromJson(
        asMap(await _client.post(ApiEndpoints.locations, data: values)),
      );

  Future<SavedLocation> updateLocation(
    int id,
    Map<String, dynamic> values,
  ) async => SavedLocation.fromJson(
    asMap(await _client.patch(ApiEndpoints.location(id), data: values)),
  );

  Future<void> deleteLocation(int id) async =>
      _client.delete(ApiEndpoints.location(id));

  Future<void> setDefaultLocation(int id) async =>
      _client.post(ApiEndpoints.defaultLocation(id));

  Future<List<StaticPage>> pages() async =>
      parseList(await _client.get(ApiEndpoints.pages), StaticPage.fromJson);

  Future<StaticPage> page(String slug) async =>
      StaticPage.fromJson(asMap(await _client.get(ApiEndpoints.page(slug))));

  Future<ShopContacts> contacts() async =>
      ShopContacts.fromJson(asMap(await _client.get(ApiEndpoints.contacts)));

  Future<Paginated<ShopNotification>> notifications({
    int page = 1,
    int size = 20,
  }) async {
    final data = await _client.get(
      ApiEndpoints.notifications,
      queryParameters: {'page': page, 'size': size},
    );
    return Paginated.fromJson(data, ShopNotification.fromJson);
  }
}

class ShopBanner {
  const ShopBanner({
    required this.id,
    required this.image,
    required this.targetType,
    this.title,
    this.target,
  });

  factory ShopBanner.fromJson(Map<String, dynamic> json) => ShopBanner(
    id: json.intVal('id'),
    title: json.strOrNull('title'),
    image: json.str('image'),
    targetType: json.str('target_type'),
    target: json.strOrNull('target'),
  );

  final int id;
  final String? title;
  final String image;
  final String targetType;
  final String? target;
}

class SavedLocation {
  const SavedLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
    this.type = 'other',
    this.address,
    this.details,
  });

  factory SavedLocation.fromJson(Map<String, dynamic> json) => SavedLocation(
    id: json.intVal('id'),
    name: json.str('name'),
    latitude: json.doubleOrNull('latitude') ?? 0,
    longitude: json.doubleOrNull('longitude') ?? 0,
    isDefault: json.boolVal('is_default'),
    type: json.str('type', 'other'),
    address: json.strOrNull('address'),
    details: json.strOrNull('details'),
  );

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final String type;
  final String? address;
  final String? details;
}

class StaticPage {
  const StaticPage({required this.slug, required this.title, this.body});

  factory StaticPage.fromJson(Map<String, dynamic> json) => StaticPage(
    slug: json.str('slug'),
    title: json.str('title'),
    body: json.strOrNull('body'),
  );

  final String slug;
  final String title;
  final String? body;
}

class ShopContacts {
  const ShopContacts({
    this.phonePrimary,
    this.phoneSecondary,
    this.whatsappUrl,
    this.telegramUrl,
    this.instagramUrl,
    this.tiktokUrl,
    this.imoUrl,
  });

  factory ShopContacts.fromJson(Map<String, dynamic> json) => ShopContacts(
    phonePrimary: json.strOrNull('phone_primary'),
    phoneSecondary: json.strOrNull('phone_secondary'),
    whatsappUrl: json.strOrNull('whatsapp_url'),
    telegramUrl: json.strOrNull('telegram_url'),
    instagramUrl: json.strOrNull('instagram_url'),
    tiktokUrl: json.strOrNull('tiktok_url'),
    imoUrl: json.strOrNull('imo_url'),
  );

  final String? phonePrimary;
  final String? phoneSecondary;
  final String? whatsappUrl;
  final String? telegramUrl;
  final String? instagramUrl;
  final String? tiktokUrl;
  final String? imoUrl;
}

class ShopNotification {
  const ShopNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.targetType,
    this.target,
    this.createdAt,
  });

  factory ShopNotification.fromJson(Map<String, dynamic> json) =>
      ShopNotification(
        id: json.intVal('id'),
        title: json.str('title'),
        body: json.str('body'),
        targetType: json.str('target_type', 'none'),
        target: json.strOrNull('target'),
        createdAt: json.dateOrNull('created_at'),
      );

  final int id;
  final String title;
  final String body;
  final String targetType;
  final String? target;
  final DateTime? createdAt;
}
