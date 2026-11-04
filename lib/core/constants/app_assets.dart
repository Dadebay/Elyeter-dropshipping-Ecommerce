/// Asset paths — never type an asset string inline.
abstract final class AppAssets {
  static const _icons = 'assets/icons';
  static const _images = 'assets/images';

  // Bottom navigation
  static const iconHome = '$_icons/nav_home.svg';
  static const iconCategory = '$_icons/category.svg';
  static const iconCart = '$_icons/cart.svg';
  static const iconShoppingBagOutline = '$_icons/shopping_bag_outline.svg';
  static const iconCartPlus = '$_icons/cart_plus.svg';
  static const iconCopy = '$_icons/copy.svg';
  static const iconCartMinus = '$_icons/cart_minus.svg';
  static const iconCartCheck = '$_icons/cart_check.svg';
  static const iconFavorite = '$_icons/heart.svg';
  static const iconProfile = '$_icons/people.svg';

  // Product card favourite toggle. Both are two-tone and carry their own
  // white body, so they are drawn as supplied — never tinted.
  /// White person silhouette, drawn over a tinted disc as a reviewer avatar.
  static const iconReviewUser = '$_icons/review_user.svg';

  static const iconFavoriteEmpty = '$_icons/favorite_empty.svg';
  static const iconFavoriteFull = '$_icons/favorite_full.svg';

  /// Ticket-shaped badge behind the discount percentage on a product card.
  /// The `-20%` baked into the file is drawn in the same green as its
  /// background, so only the shape shows — the number is drawn over it.
  static const iconDiscountBanner = '$_icons/discount_banner.svg';

  // Product detail's floating app bar.
  static const iconBack = '$_icons/back.svg';
  static const iconShare = '$_icons/share.svg';
  static const iconHeartLine = '$_icons/heart_line.svg';

  // Order detail. Each carries its own grey, so they are drawn as supplied.
  static const iconRepeatOrder = '$_icons/repeat_order.svg';
  static const iconBubbleQuestion = '$_icons/bubble_question.svg';
  static const iconCircleX = '$_icons/circle_x.svg';
  // Rendered from order_cancelled.svg at 8x resolution. Its blend modes are
  // not reproduced correctly by flutter_svg on device.
  static const imageOrderCancelled = '$_images/order_cancelled.png';
  static const iconPencil = '$_icons/pencil.svg';
  static const iconUser = '$_icons/user.svg';
  static const iconCalendar = '$_icons/calendar.svg';
  static const iconWallet = '$_icons/wallet.svg';
  static const iconReceipt = '$_icons/receipt.svg';

  // Search bar
  static const iconSearch = '$_icons/search.svg';
  static const iconCamera = '$_icons/camera.svg';
  static const iconSearchNotFound = '$_icons/search_not_found.svg';
  static const iconSearchError = '$_icons/search_error.svg';
  static const iconSearchConnectionError =
      '$_icons/search_connection_error.svg';

  // Home
  static const logoWhite = '$_images/logo_white.svg';
  static const logoYellow = '$_images/logo_yellow.svg';
  static const onboardingGradient = '$_images/onboarding_gradient.svg';
  static const homeBackground = '$_images/background.png';
  static const emptyShoppingBag = '$_images/order_history_empty_3d_cutout.png';
  static const cartEmpty3d = '$_images/cart_empty_3d.png';
  static const cartEmptyIllustration = '$_images/cart_empty_illustration.png';
  static const favoriteEmptyIllustration =
      '$_images/favorite_empty_illustration.png';
  static const guestUserAvatar = '$_images/guest_user_avatar.png';
  static const iconMapPin = '$_icons/map_pin.svg';
  static const iconAddressMapPin = '$_icons/address_map_pin.svg';
  static const iconCurrentLocation = '$_icons/current_location.svg';
  static const iconOtpNotification = '$_icons/otp_notification.svg';
  static const iconLoginBag = '$_icons/login_bag.svg';
  static const iconAddressWork = '$_icons/address_work.svg';
  static const iconAddressHome = '$_icons/address_home.svg';
  static const iconAddressLocation = '$_icons/address_location.svg';

  // Partner marketplaces, in the order the design shows them.
  static const _magazynes = '$_images/magazynes';
  static const marketAliexpress = '$_magazynes/1.svg';
  static const marketAlibaba = '$_magazynes/2.svg';
  static const marketTaobao = '$_magazynes/3.svg';
  static const market1688 = '$_magazynes/4.svg';

  static const iconCubic = '$_icons/cubic.svg';

  // Profile rows
  static const iconBell = '$_icons/bell.svg';
  static const iconDocumentCheck = '$_icons/document_check.svg';
  static const iconPinLocation = '$_icons/pin_location.svg';
  static const iconClock = '$_icons/clock.svg';
  static const iconNews = '$_icons/news.svg';
  static const iconGlobe = '$_icons/globe.svg';
  static const iconChevronGrabberVertical =
      '$_icons/chevron_grabber_vertical.svg';
  static const iconMoon = '$_icons/moon.svg';
  static const iconPhone = '$_icons/phone.svg';
  static const iconQuestion = '$_icons/question_bubble.svg';
  static const iconLock = '$_icons/lock.svg';
  static const iconInstagram = '$_icons/instagram.svg';
  static const iconTiktok = '$_icons/tiktok.svg';
  static const iconWhatsapp = '$_icons/whatsapp.svg';

  /// Generic tile art, for a category with no picture of its own.
  static const categoryImage = '$_images/category_image.png';
}
