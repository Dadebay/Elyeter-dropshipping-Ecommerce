/// Route names and paths. Navigate with `context.goNamed(AppRoutes.cart.name)`
/// so a path change never breaks call sites.
enum AppRoutes {
  onboarding('/onboarding', 'onboarding'),
  home('/', 'home'),
  category('/category', 'category'),
  cart('/cart', 'cart'),
  favorite('/favorite', 'favorite'),
  profile('/profile', 'profile'),

  // Pushed on top of the shell
  productDetail('product/:id', 'product-detail'),
  productReviews('product/:id/reviews', 'product-reviews'),
  marketplace('marketplace/:id', 'marketplace'),
  categoryDetail('category/:id', 'category-detail'),
  brand('brand/:id', 'brand'),
  search('/search', 'search'),
  imageSearch('/image-search', 'image-search'),
  orders('orders', 'orders'),
  checkout('checkout', 'checkout'),
  orderDetail('/order/:id', 'order-detail'),
  orderTrack('/order/:id/track', 'order-track'),
  activeOrders('active-orders', 'active-orders'),
  announcements('announcements', 'announcements'),
  editProfile('edit', 'edit-profile'),
  notifications('notifications', 'notifications'),
  addresses('addresses', 'addresses'),
  productRequests('product-requests', 'product-requests'),
  settings('settings', 'settings'),
  faq('faq', 'faq'),
  terms('terms', 'terms'),
  privacy('privacy', 'privacy'),
  staticPage('pages/:slug', 'static-page'),
  login('/login', 'login');

  const AppRoutes(this.path, this.name);

  final String path;
  final String name;
}
