/// Every backend path in one place — no raw strings inside data sources.
///
/// Mirrors `elyeter-mobile-api.md`; paths are relative to
/// [AppEnvironment.apiBaseUrl].
abstract final class ApiEndpoints {
  // ------------------------------------------------------------- auth --
  static const sendCode = '/auth/send-code';
  static const verifyCode = '/auth/verify-code';
  static const me = '/auth/me';
  static const fcmToken = '/auth/fcm-token';

  // ---------------------------------------------------------- catalog --
  static const banners = '/banners';
  static const categoriesTree = '/categories/tree';
  static String category(int id) => '/categories/$id';

  static const products = '/products';
  static String product(int id) => '/products/$id';
  static String productVariants(int id) => '/products/$id/variants';
  static String productReviews(int id) => '/products/$id/reviews';
  static String myProductReview(int id) => '/products/$id/reviews/me';
  static const reviewImages = '/reviews/images';
  static String reviewReaction(int productId, int reviewId) =>
      '/products/$productId/reviews/$reviewId/reaction';

  static const searchSuggest = '/search/suggest';
  static const imageSearch = '/image-search';
  static String imageSearchById(int id) => '/image-search/$id';

  static const marketplaces = '/marketplaces';
  static const home = '/home';

  // ----------------------------------------------------------- brands --
  static const brands = '/brands';
  static String brand(int id) => '/brands/$id';

  // ------------------------------------------------------- pre-orders --
  static const preOrders = '/pre-orders';
  static const preOrderCheck = '/pre-orders/check';
  static String preOrder(int id) => '/pre-orders/$id';
  static String cancelPreOrder(int id) => '/pre-orders/$id/cancel';

  // --------------------------------------------------------- payments --
  static const banks = '/banks';
  static const payments = '/payments';
  static String payment(int id) => '/payments/$id';

  // ------------------------------------------------- product requests --
  static const productRequests = '/product-requests';
  static String productRequest(int id) => '/product-requests/$id';

  static const favorites = '/favorites';
  static const favoriteIds = '/favorites/ids';
  static String favorite(int productId) => '/favorites/$productId';

  static const locations = '/locations';
  static String location(int id) => '/locations/$id';
  static String defaultLocation(int id) => '/locations/$id/default';

  static const pages = '/pages';
  static String page(String slug) => '/pages/$slug';
  static const contacts = '/contacts';
  static const notifications = '/notifications';
}
