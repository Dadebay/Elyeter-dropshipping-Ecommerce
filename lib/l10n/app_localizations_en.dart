// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Elyeter';

  @override
  String get navHome => 'Home';

  @override
  String get navCategory => 'Category';

  @override
  String get navCart => 'Cart';

  @override
  String get navFavorite => 'Favorite';

  @override
  String get favoriteTitle => 'Favorites';

  @override
  String get favoriteEmptyTitle => 'No Favorites Yet';

  @override
  String get favoriteEmptyMessage =>
      'Save your favorite items and find them here whenever you need them.';

  @override
  String get favoriteEmptyAction => 'Explore';

  @override
  String get navProfile => 'Profile';

  @override
  String get commonRetry => 'Retry';

  @override
  String get notificationsEmptyTitle => 'No notifications yet';

  @override
  String get notificationsEmptyMessage => 'New updates will appear here.';

  @override
  String get notificationsOverviewTitle => 'Updates from Elyeter';

  @override
  String get notificationsOverviewMessage =>
      'Offers and important news, all in one place.';

  @override
  String get notificationsToday => 'Today';

  @override
  String get notificationsYesterday => 'Yesterday';

  @override
  String get notificationsEarlier => 'Earlier updates';

  @override
  String get notificationsNew => 'New';

  @override
  String get notificationsLoadMore => 'Load more';

  @override
  String get notificationsRefresh => 'Refresh';

  @override
  String get announcementsEmptyTitle => 'No announcements yet';

  @override
  String get announcementsEmptyMessage => 'New announcements will appear here.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonSave => 'Save';

  @override
  String get commonSearch => 'Search';

  @override
  String get homeSearchHint => 'Search product';

  @override
  String get locationTitle => 'Delivery address';

  @override
  String get locationSearchHint => 'Search area or street';

  @override
  String get locationEmpty => 'No matching address';

  @override
  String get visualSearchTitle => 'Search by photo';

  @override
  String get visualSearchHint => 'Place the product in the frame to scan';

  @override
  String get visualSearchCamera => 'Take a photo';

  @override
  String get visualSearchRetake => 'Retake';

  @override
  String get visualSearchUse => 'Use photo';

  @override
  String get visualSearchGallery => 'Choose from gallery';

  @override
  String get visualSearchNoCamera => 'No camera is available on this device.';

  @override
  String get visualSearchDenied =>
      'Elyeter needs camera access to search by photo. Allow it in Settings.';

  @override
  String get visualSearchReady => 'Photo ready — visual search is coming soon.';

  @override
  String commonOpenFailed(String target) {
    return 'Could not open $target';
  }

  @override
  String get orderActiveTitle => 'Active Order';

  @override
  String orderNumber(String number) {
    return 'Order No. $number';
  }

  @override
  String get orderRepeat => 'Repeat order';

  @override
  String get orderQuestions => 'Questions';

  @override
  String get orderCancel => 'Cancel';

  @override
  String get orderProgress => 'Delivery Progress';

  @override
  String get orderStepPlaced => 'Order Placed';

  @override
  String get orderStepWarehouse => 'Arrived at China Warehouse';

  @override
  String get orderStepShipped => 'Shipped to Turkmenistan';

  @override
  String get orderStepArrived => 'Arrived in Turkmenistan';

  @override
  String get orderStepDelivered => 'Delivered';

  @override
  String get orderStepStopped => 'Stopped';

  @override
  String get orderProducts => 'Delivery Products';

  @override
  String orderItemSummary(int count, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items for $total',
      one: '1 item for $total',
    );
    return '$_temp0';
  }

  @override
  String get orderPickupPoint => 'Pick-up point';

  @override
  String get orderSelectAddressTitle => 'Select an address';

  @override
  String get orderSelectAddressMessage =>
      'Choose or add an address before placing your order.';

  @override
  String get orderAddressLoadFailed =>
      'Could not load addresses. Please try again.';

  @override
  String get orderRecipient => 'Recipient';

  @override
  String get orderTime => 'Order Time';

  @override
  String get orderPayment => 'Payment Method';

  @override
  String get orderPaymentCard => 'By card / Card payment';

  @override
  String get orderTotalTitle => 'Order Total';

  @override
  String get orderProductsTotal => 'Products Total';

  @override
  String get orderDeliveryLabel => 'Delivery';

  @override
  String get orderDeliveryFree => 'Free';

  @override
  String get orderCargo => 'Cargo';

  @override
  String get orderDiscount => 'Discount';

  @override
  String get orderDownloadCheck => 'Download Check';

  @override
  String get orderCargoNote =>
      'Note: Cargo cost is calculated after the goods arrive.';

  @override
  String get categoryFilterMaterial => 'Material';

  @override
  String get categoryFilterColor => 'Color';

  @override
  String get categoryFilterBrand => 'Brand';

  @override
  String get categorySearch => 'Search';

  @override
  String get categoryFilters => 'Filters';

  @override
  String get categoryOnlyFeatured => 'Featured products only';

  @override
  String get categorySortTitle => 'Sort by';

  @override
  String get categorySortNewest => 'Newest';

  @override
  String get categorySortPopular => 'Popular';

  @override
  String get categoryPriceMin => 'Minimum price';

  @override
  String get categoryPriceRange => 'Price range';

  @override
  String get categoryPriceMax => 'Maximum price';

  @override
  String get categorySortPriceAsc => 'Price: low to high';

  @override
  String get categorySortPriceDesc => 'Price: high to low';

  @override
  String get categorySortDiscount => 'Biggest discount';

  @override
  String get categoryApply => 'Apply';

  @override
  String get categoryReset => 'Reset';

  @override
  String get categoryNoResults => 'Nothing matches these filters';

  @override
  String get categoryProductsEmptyTitle => 'No products yet';

  @override
  String get categoryProductsEmptyMessage =>
      'This category has no products right now. Explore another category.';

  @override
  String get categoryNoResultsHint => 'Try removing one of them.';

  @override
  String categoryFacetSearch(String facet) {
    return 'Search $facet';
  }

  @override
  String categorySelectedCount(int count) {
    return '$count selected';
  }

  @override
  String get searchTitle => 'Search';

  @override
  String get searchClear => 'Clear search';

  @override
  String get searchNotFoundTitle => 'Not found';

  @override
  String get searchNotFoundMessage =>
      'Please make sure the words are spelled correctly or use fewer or different keywords.';

  @override
  String get searchErrorTitle => 'Error';

  @override
  String get searchErrorMessage => 'An error occurred. Please try again.';

  @override
  String get searchConnectionErrorTitle => 'Connection Error';

  @override
  String get searchConnectionErrorMessage =>
      'Unable to connect to the server. Please check your internet connection and try again.';

  @override
  String get commonSeeAll => 'See all';

  @override
  String get commonAddToCart => 'Add to Card';

  @override
  String get commonAdded => 'Added';

  @override
  String get cartDelete => 'Delete';

  @override
  String get cartSelectAll => 'Select All';

  @override
  String get cartEmpty => 'Your Cart Is Empty';

  @override
  String get cartTitle => 'Product';

  @override
  String get cartEmptyMessage =>
      'You haven’t added any items yet. Explore our collection and find your favorites.';

  @override
  String get cartEmptyAction => 'Shopping';

  @override
  String cartProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Product',
      one: '1 Product',
    );
    return '$_temp0';
  }

  @override
  String get commonCheckout => 'Checkout';

  @override
  String get commonTotal => 'Total';

  @override
  String get commonEmpty => 'Nothing here yet';

  @override
  String productReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reviews',
      one: '1 review',
    );
    return '$_temp0';
  }

  @override
  String productOrderCount(int count) {
    return '$count order';
  }

  @override
  String productColor(String name) {
    return 'Color: $name';
  }

  @override
  String productSize(String size) {
    return 'Ring size: $size';
  }

  @override
  String get productArticle => 'Item Article:';

  @override
  String get productPriceDetails => 'Price details';

  @override
  String get productPricePerItem => 'Price per item';

  @override
  String get productRegularPrice => 'Regular price';

  @override
  String productDiscountPercent(int percent) {
    return '$percent% discount';
  }

  @override
  String get productCopy => 'Copy';

  @override
  String get productCopied => 'Article copied';

  @override
  String get productShared => 'Product link copied';

  @override
  String get productSharePrice => 'Price';

  @override
  String get productSharePhoto => 'Product photo';

  @override
  String get productShareOpen => 'Open in the Elýeter app';

  @override
  String get productShareFailed => 'Could not open sharing. Please try again.';

  @override
  String get productDescription => 'Description';

  @override
  String get productReadMore => 'Read More';

  @override
  String get productReadLess => 'Show less';

  @override
  String get productCharacteristics => 'Characteristics';

  @override
  String get productAllCharacteristics => 'All characteristics';

  @override
  String get productReviews => 'Reviews';

  @override
  String get reviewEmpty => 'No reviews yet';

  @override
  String get reviewWrite => 'Write a review';

  @override
  String get reviewEdit => 'Edit my review';

  @override
  String get reviewDelete => 'Delete my review';

  @override
  String get reviewRating => 'Your rating';

  @override
  String get reviewComment => 'Your review (optional)';

  @override
  String get reviewIntro => 'Share your experience with this product.';

  @override
  String get reviewRatingPrompt => 'Tap a star to choose your rating';

  @override
  String get reviewRatingPoor => 'Poor';

  @override
  String get reviewRatingFair => 'Fair';

  @override
  String get reviewRatingGood => 'Good';

  @override
  String get reviewRatingVeryGood => 'Very good';

  @override
  String get reviewRatingExcellent => 'Excellent';

  @override
  String get reviewCommentHint => 'What did you like? What could be better?';

  @override
  String get reviewHowRate => 'How would you rate this product?';

  @override
  String get reviewSubmit => 'Send review';

  @override
  String get reviewAnonymous => 'Customer';

  @override
  String get reviewLoadMore => 'Load more';

  @override
  String get reviewLoadError => 'Could not load reviews.';

  @override
  String get reviewActionError => 'Could not update your review.';

  @override
  String get reviewSaved => 'Review saved';

  @override
  String get reviewDeleted => 'Review deleted';

  @override
  String get reviewDeleteConfirm => 'Delete your review?';

  @override
  String get reviewDeleteMessage => 'You can write a new review later.';

  @override
  String get reviewHelpful => 'Helpful';

  @override
  String get reviewSortBy => 'Sort by';

  @override
  String get reviewRatingFilter => 'Rating';

  @override
  String get reviewSortNewest => 'Newest first';

  @override
  String get reviewSortOldest => 'Oldest first';

  @override
  String get reviewSortMostLiked => 'Most helpful';

  @override
  String get reviewSortMostDisliked => 'Least helpful';

  @override
  String get reviewSortWithPhotos => 'With photos';

  @override
  String get reviewSortWithoutPhotos => 'Without photos';

  @override
  String get reviewAllRatings => 'All ratings';

  @override
  String get reviewAddPhotos => 'Add photos';

  @override
  String get reviewPhotoLimit => 'Up to 5 photos';

  @override
  String get reviewPhotoUploadError => 'Could not upload the photo.';

  @override
  String get reviewNoMatches => 'No reviews match these filters';

  @override
  String get reviewHiddenNotice => 'Your review is hidden from others';

  @override
  String reviewHelpfulCount(int count) {
    return 'Helpful ($count)';
  }

  @override
  String productRatingCount(int count) {
    return '$count ratings';
  }

  @override
  String get productReadAllReviews => 'Read all reviews';

  @override
  String get orderActive => 'Active Order';

  @override
  String get orderCompleted => 'Order Completed';

  @override
  String get orderCancelled => 'Order Cancelled';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get orderCancelTitle => 'Cancel this order?';

  @override
  String get orderCancelMessage =>
      'Once cancelled, an order cannot be restored. You can place it again from your cart.';

  @override
  String get orderCancelKeep => 'Keep order';

  @override
  String get orderCancelConfirm => 'Cancel order';

  @override
  String get orderRepeatDone => 'Items added to your cart';

  @override
  String get orderNotFound => 'This order could not be loaded';

  @override
  String get orderComment => 'Comment';

  @override
  String get orderStatusNew => 'Waiting for a call';

  @override
  String get orderStatusConfirmed => 'Confirmed';

  @override
  String get orderStatusOrdered => 'Ordered';

  @override
  String get orderStatusCompleted => 'Completed';

  @override
  String get orderReceiptTitle => 'Order receipt';

  @override
  String get orderReceiptItems => 'Items';

  @override
  String get orderReceiptQty => 'Qty';

  @override
  String get orderReceiptPrice => 'Price';

  @override
  String get orderReceiptAmount => 'Amount';

  @override
  String get orderReceiptThanks => 'Thank you for your order';

  @override
  String get orderReceiptFailed => 'Could not create the receipt';

  @override
  String get orderTrackRefresh => 'Updates every 15 seconds';

  @override
  String get orderTrackNoPoint => 'No delivery point was set';

  @override
  String get orderTrackMapPoint => 'Delivery point on the map';

  @override
  String get orderTrackNoCourier =>
      'Live courier location and arrival time are not available yet.';

  @override
  String get orderTrackCancelled => 'This order was cancelled.';

  @override
  String get orderHistory => 'Order history';

  @override
  String get orderHistoryEmptyTitle => 'No orders yet';

  @override
  String get orderHistoryEmptyMessage =>
      'Your orders will appear here after you place one.';

  @override
  String get activeOrdersEmptyTitle => 'No active orders';

  @override
  String get activeOrdersEmptyMessage => 'Orders in progress will appear here.';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String orderItemsFor(int count, String amount) {
    return '$count items for $amount';
  }

  @override
  String orderItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count products',
      one: '1 product',
      zero: 'No products',
    );
    return '$_temp0';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get onboardingWelcome => 'Welcome!';

  @override
  String get onboardingSubtitle =>
      'You can quickly and securely log in to your account.';

  @override
  String get onboardingStart => 'Get started';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageDialogTitle => 'Change language';

  @override
  String get settingsLanguageDialogSubtitle =>
      'Choose the language you\'d like to use.';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get errorServer => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'No internet connection.';

  @override
  String get errorTimeout => 'The request took too long.';

  @override
  String get errorUnauthorized => 'Please sign in to continue.';

  @override
  String get errorNotFound => 'We couldn\'t find what you were looking for.';

  @override
  String get errorCache => 'Could not read saved data.';

  @override
  String get errorUnknown => 'Unexpected error.';

  @override
  String get profileEditProfile => 'Edit profile';

  @override
  String get profileAllOrders => 'All Orders';

  @override
  String profileOrderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Orders',
      one: '1 Order',
      zero: 'No orders',
    );
    return '$_temp0';
  }

  @override
  String get profileSectionGeneral => 'General';

  @override
  String get profileSectionOther => 'Other';

  @override
  String get profileSectionContact => 'Contact Us';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get profileActiveOrders => 'Active orders';

  @override
  String get profileSavedLocations => 'My saved locations';

  @override
  String get addressListTitle => 'Addresses';

  @override
  String get addressAddWork => 'Add Work Address';

  @override
  String get addressAddHome => 'Add Home Address';

  @override
  String get addressAddNew => 'Add New Address';

  @override
  String get addressNameWork => 'Work';

  @override
  String get addressNameHome => 'Home';

  @override
  String get addressEdit => 'Edit';

  @override
  String get addressMakeDefault => 'Make default';

  @override
  String get addressDelete => 'Delete';

  @override
  String get addressMapLocation => 'Location on map';

  @override
  String get addressMapHint => 'Street, building, city';

  @override
  String get addressApartmentFlat => 'Apartment / Flat';

  @override
  String get addressApartmentHint => 'e.g. 35/1';

  @override
  String get addressFloor => 'Floor';

  @override
  String get addressFloorHint => 'e.g. 3';

  @override
  String get addressNameLabel => 'Address name';

  @override
  String get addressSaveButton => 'Save address';

  @override
  String get addressResolving => 'Finding address…';

  @override
  String get addressTypeHome => 'Home';

  @override
  String get addressTypeWork => 'Work';

  @override
  String get addressTypeOther => 'Other';

  @override
  String get addressPointRequired => 'Choose a point on the map first.';

  @override
  String get addressNameRequired => 'Enter an address name.';

  @override
  String get addressLocationApproximate =>
      'Location is approximate. Move the pin to the exact spot.';

  @override
  String get addressLocationFailed =>
      'Could not get your location. Choose it on the map.';

  @override
  String get addressLookupFailed =>
      'Street address unavailable. Coordinates added; enter the address manually.';

  @override
  String get addressEmptyTitle => 'No saved addresses yet';

  @override
  String get addressEmptyMessage =>
      'Tap + to save your first delivery address.';

  @override
  String get addressDeleteDone => 'Address deleted.';

  @override
  String get profileOrderHistory => 'Order history';

  @override
  String get profileAnnouncements => 'Announcements';

  @override
  String get profileDarkMode => 'Dark mode';

  @override
  String get profileAboutApp => 'About the app';

  @override
  String get profileFaq => 'FAQ';

  @override
  String get profileTerms => 'Terms of use';

  @override
  String get profilePrivacy => 'Privacy policy';

  @override
  String get staticPageEmpty =>
      'Content will appear here when it is available.';

  @override
  String get profileWhatsapp => 'WhatsApp';

  @override
  String get profileInstagram => 'Instagram';

  @override
  String get profileTiktok => 'TikTok';

  @override
  String get profileCallTitle => 'Call us with any question:';

  @override
  String get profileCallAction => 'Call operator';

  @override
  String get profileCallHours =>
      'Calls are answered every day of the week, 09:00 - 19:00';

  @override
  String profileVersion(String version) {
    return 'Version $version';
  }

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileSignOutTitle => 'Sign out?';

  @override
  String get profileSignOutMessage =>
      'You will need your phone number to sign in again.';

  @override
  String get profileGuestTitle => 'Log in to your account';

  @override
  String get profileGuestMessage =>
      'Clothing, products, home goods and more to order';

  @override
  String get profileGuestAction => 'Sign In';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignInRequiredTitle => 'Sign in required';

  @override
  String get authSignInRequiredMessage =>
      'Sign in to use this part of the app.';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginPhoneTitle => 'Sign in';

  @override
  String get loginPhoneMessage =>
      'You can quickly and securely log in to your account by entering your phone number.';

  @override
  String get loginPhoneLabel => 'Phone number';

  @override
  String get loginPhoneHint => 'Your phone number';

  @override
  String get loginSendCode => 'Continue';

  @override
  String get loginLegalNotice =>
      'By using Elyeter, you agree to the Terms of use and Privacy policy.';

  @override
  String get loginReadTerms => 'Read the terms';

  @override
  String get loginCodeTitle => 'Verification';

  @override
  String loginCodeMessage(String phone) {
    return 'Enter the code sent to $phone';
  }

  @override
  String get loginCodeLabel => 'Confirmation code';

  @override
  String get loginVerify => 'Continue';

  @override
  String get loginResend => 'Resend code';

  @override
  String loginResendCountdown(String time) {
    return 'Resend code $time';
  }

  @override
  String loginResendIn(int seconds) {
    return 'Resend in $seconds s';
  }

  @override
  String get loginChangePhone => 'Change number';

  @override
  String get loginSignedIn => 'You are signed in';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageTurkmen => 'Türkmençe';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get editProfileTitle => 'Edit profile';

  @override
  String get editProfileName => 'Full name';

  @override
  String get editProfileNameHint => 'Your name';

  @override
  String get editProfilePhone => 'Phone number';

  @override
  String get editProfilePhoneNote => 'Contact support to change your number';

  @override
  String get editProfilePhoto => 'Change photo';

  @override
  String get editProfilePhotoCamera => 'Take a photo';

  @override
  String get editProfilePhotoGallery => 'Choose from gallery';

  @override
  String get editProfilePhotoRemove => 'Remove photo';

  @override
  String get editProfilePhotoTooLarge =>
      'This photo could not be reduced below 1 MB. Choose another photo.';

  @override
  String get editProfileSaved => 'Profile updated';

  @override
  String get editProfileNameRequired => 'Please enter your name';

  @override
  String get editProfilePhotoHint => 'Tap the photo to change it';

  @override
  String editProfileNameCounter(int count) {
    return '$count/40';
  }

  @override
  String get editProfileNothingChanged => 'Nothing to save yet';

  @override
  String get aboutTagline =>
      'Everything from the big marketplaces, delivered to Turkmenistan.';

  @override
  String legalUpdated(String date) {
    return 'Last updated: $date';
  }

  @override
  String get faqTitle => 'FAQ';

  @override
  String get faqQ1 => 'How do I place an order?';

  @override
  String get faqA1 =>
      'Add what you want to the cart, open the Cart tab and tap Checkout. The total, including delivery, is shown before you confirm.';

  @override
  String get faqQ2 => 'How long does delivery take?';

  @override
  String get faqA2 =>
      'Items in local stock arrive in 1–3 days. Orders from partner marketplaces take 10–20 days, depending on the seller.';

  @override
  String get faqQ3 => 'How do I track my order?';

  @override
  String get faqA3 =>
      'Open Profile → Active orders. Every step from confirmation to delivery is listed there.';

  @override
  String get faqQ4 => 'Can I cancel an order?';

  @override
  String get faqA4 =>
      'Yes, while it is still marked Confirmed. Once it has shipped, call the operator and we will help.';

  @override
  String get faqQ5 => 'How do returns work?';

  @override
  String get faqA5 =>
      'Call the operator within 3 days of delivery. Unused items in their original packaging are accepted.';

  @override
  String get termsTitle => 'Terms of use';

  @override
  String get termsS1 => 'Using the app';

  @override
  String get termsB1 =>
      'By using Elyeter you accept these terms. If you do not agree with them, please stop using the app.';

  @override
  String get termsS2 => 'Orders and prices';

  @override
  String get termsB2 =>
      'Prices are shown in TMT and may change until an order is confirmed. Availability at partner marketplaces is outside our control.';

  @override
  String get termsS3 => 'Delivery';

  @override
  String get termsB3 =>
      'Delivery times are estimates, not guarantees. Customs and seller delays can extend them.';

  @override
  String get termsS4 => 'Returns';

  @override
  String get termsB4 =>
      'Unused items in original packaging can be returned within 3 days of delivery. Made-to-order and personal-care items cannot.';

  @override
  String get termsS5 => 'Your account';

  @override
  String get termsB5 =>
      'Your phone number identifies your account. Keep it up to date — orders and delivery calls go to it.';

  @override
  String get privacyTitle => 'Privacy policy';

  @override
  String get privacyS1 => 'What we collect';

  @override
  String get privacyB1 =>
      'Your name, phone number, delivery address and order history. Nothing else is required to use Elyeter.';

  @override
  String get privacyS2 => 'Why we use it';

  @override
  String get privacyB2 =>
      'To deliver your orders, keep you updated about them and answer you when you contact support.';

  @override
  String get privacyS3 => 'Who we share it with';

  @override
  String get privacyB3 =>
      'Only couriers and payment providers, and only the part they need to complete your order. We never sell your data.';

  @override
  String get privacyS4 => 'How long we keep it';

  @override
  String get privacyB4 =>
      'While your account exists, plus the period accounting rules require for completed orders.';

  @override
  String get privacyS5 => 'Your rights';

  @override
  String get privacyB5 =>
      'Call the operator to get a copy of your data or ask for your account to be deleted.';

  @override
  String get categoryTitle => 'Categories';

  @override
  String get errorOtpRateLimited => 'Please wait before asking for a new code.';

  @override
  String get errorOtpInvalid => 'That code is not right.';

  @override
  String get errorOtpTooManyAttempts =>
      'Too many attempts. Request a new code.';

  @override
  String get errorOtpExpired => 'The code has expired. Request a new one.';

  @override
  String get errorUserBlocked => 'This account has been blocked.';

  @override
  String get errorVariantRequired => 'Choose an option before ordering.';

  @override
  String get errorItemsUnavailable => 'Some items are no longer available.';

  @override
  String get errorPriceChanged =>
      'The total has changed. Please check it again.';

  @override
  String get errorSupplierUnavailable =>
      'The supplier is not responding. Try again in a couple of minutes.';

  @override
  String get errorCannotCancel => 'This order can no longer be cancelled.';

  @override
  String get errorTooManyRequests => 'Too many requests. Please slow down.';

  @override
  String get errorValidation => 'Please check the details you entered.';

  @override
  String get profileDeleteAccount => 'Delete account';

  @override
  String get profileDeleteTitle => 'Delete your account?';

  @override
  String get profileDeleteMessage =>
      'This is permanent. Your account and everything in it is removed from Elyeter and cannot be restored.';

  @override
  String get profileDeleteLossOrders => 'Your order history';

  @override
  String get profileDeleteLossProfile => 'Your name, photo and saved details';

  @override
  String get profileDeleteLossAccess => 'Access to the account on this number';

  @override
  String profileDeleteAccountOn(String phone) {
    return 'Account: $phone';
  }

  @override
  String get profileDeleteKeep => 'Keep my account';

  @override
  String get profileDeleteConfirm => 'Delete permanently';

  @override
  String get profileDeleteDone => 'Your account has been deleted.';

  @override
  String get commonOk => 'OK';

  @override
  String get errorPaymentBankFailed =>
      'The bank didn\'t accept the payment. Try later or choose another bank.';

  @override
  String get errorPreOrderAlreadyPaid => 'This order has already been paid.';

  @override
  String get errorPreOrderNotPayable =>
      'This order can no longer be paid online.';

  @override
  String get errorBankNotFound =>
      'This bank is not available right now. Choose another one.';

  @override
  String get errorProductRequestInvalidLink =>
      'We couldn\'t find an AliExpress product link in this text.';

  @override
  String get paymentTitle => 'Payment';

  @override
  String get paymentChooseBank => 'Choose a bank';

  @override
  String get paymentChooseBankHint =>
      'You\'ll enter your card details on the bank\'s page.';

  @override
  String get paymentNoBanks => 'Online payment is not available right now.';

  @override
  String get paymentPayOnlineTitle => 'Pay online';

  @override
  String get paymentPayOnlineMessage =>
      'Pay for the order by card now — no need to wait for the call.';

  @override
  String get paymentPay => 'Pay';

  @override
  String get paymentPaid => 'Paid online';

  @override
  String get paymentChecking => 'Checking payment…';

  @override
  String get paymentCheckingMessage => 'This takes a few seconds.';

  @override
  String get paymentSuccess => 'Payment successful';

  @override
  String get paymentSuccessMessage => 'Your order is paid. Thank you!';

  @override
  String get paymentFailed => 'Payment failed';

  @override
  String get paymentFailedMessage =>
      'The bank declined the payment. You can try again or choose another bank.';

  @override
  String get paymentPending => 'Payment is being checked';

  @override
  String get paymentPendingMessage =>
      'The bank hasn\'t confirmed it yet. The order will be marked as paid as soon as it does.';

  @override
  String get paymentNotCompletedMessage =>
      'The payment wasn\'t completed. If money was taken from your card, the order will be marked as paid within a few minutes.';

  @override
  String get paymentTryAgain => 'Try again';

  @override
  String get productRequestTitle => 'Send us a link';

  @override
  String get productRequestMessage =>
      'Didn\'t find a product? Paste an AliExpress link and we\'ll add it to the catalog.';

  @override
  String get productRequestHint => 'AliExpress link or share text';

  @override
  String get productRequestPaste => 'Paste';

  @override
  String get productRequestSend => 'Send link';

  @override
  String get productRequestSendAnother => 'Send another link';

  @override
  String get productRequestMine => 'My product requests';

  @override
  String get productRequestSearchAction => 'Send a link to the product';

  @override
  String get productRequestLoadingTitle => 'Loading the product…';

  @override
  String get productRequestLoadingMessage =>
      'This usually takes up to a minute.';

  @override
  String get productRequestLaterTitle => 'We\'ll notify you';

  @override
  String get productRequestLaterMessage =>
      'It\'s taking a little longer. We\'ll send you a notification when the product is available.';

  @override
  String get productRequestReviewTitle => 'Under review';

  @override
  String get productRequestReviewMessage =>
      'The product is under review. We\'ll notify you when it\'s available.';

  @override
  String get productRequestRejectedTitle => 'Not available';

  @override
  String get productRequestRejectedMessage =>
      'Sorry, we can\'t sell this product.';

  @override
  String get productRequestFailedTitle => 'Couldn\'t load';

  @override
  String get productRequestFailedMessage =>
      'Couldn\'t load the product from AliExpress. It may have been removed from sale.';

  @override
  String get productRequestAvailableTitle => 'Product added';

  @override
  String get productRequestAvailableMessage =>
      'The product is in the catalog. Find it in My product requests.';

  @override
  String get productRequestStatusProcessing => 'Loading';

  @override
  String get productRequestStatusInReview => 'Under review';

  @override
  String get productRequestStatusAvailable => 'Available';

  @override
  String get productRequestStatusRejected => 'Rejected';

  @override
  String get productRequestStatusFailed => 'Not loaded';

  @override
  String get productRequestEmptyTitle => 'No requests yet';

  @override
  String get errorImageSearchInvalidImage => 'Use a JPEG, PNG or WebP photo.';

  @override
  String get errorImageSearchInProgress =>
      'The previous search is still being sent. Please wait.';

  @override
  String get errorImageSearchUnavailable =>
      'Search is temporarily unavailable. Try again later.';

  @override
  String get imageSearchTitle => 'Photo search';

  @override
  String get imageSearchSearching => 'Searching for more…';

  @override
  String get imageSearchEmpty => 'Nothing similar yet';

  @override
  String imageSearchRateLimited(int minutes) {
    return 'Search limit reached. Try again in $minutes min.';
  }
}
