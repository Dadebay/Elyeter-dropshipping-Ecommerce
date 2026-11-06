import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('tk'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Elyeter'**
  String get appName;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get navCategory;

  /// No description provided for @navCart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get navCart;

  /// No description provided for @navFavorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get navFavorite;

  /// No description provided for @favoriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoriteTitle;

  /// No description provided for @favoriteEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No Favorites Yet'**
  String get favoriteEmptyTitle;

  /// No description provided for @favoriteEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Save your favorite items and find them here whenever you need them.'**
  String get favoriteEmptyMessage;

  /// No description provided for @favoriteEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get favoriteEmptyAction;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'New updates will appear here.'**
  String get notificationsEmptyMessage;

  /// No description provided for @notificationsOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Updates from Elyeter'**
  String get notificationsOverviewTitle;

  /// No description provided for @notificationsOverviewMessage.
  ///
  /// In en, this message translates to:
  /// **'Offers and important news, all in one place.'**
  String get notificationsOverviewMessage;

  /// No description provided for @notificationsToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notificationsToday;

  /// No description provided for @notificationsYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notificationsYesterday;

  /// No description provided for @notificationsEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier updates'**
  String get notificationsEarlier;

  /// No description provided for @notificationsNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get notificationsNew;

  /// No description provided for @notificationsLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get notificationsLoadMore;

  /// No description provided for @notificationsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get notificationsRefresh;

  /// No description provided for @announcementsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No announcements yet'**
  String get announcementsEmptyTitle;

  /// No description provided for @announcementsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'New announcements will appear here.'**
  String get announcementsEmptyMessage;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get commonSearch;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search product'**
  String get homeSearchHint;

  /// No description provided for @locationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get locationTitle;

  /// No description provided for @locationSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search area or street'**
  String get locationSearchHint;

  /// No description provided for @locationEmpty.
  ///
  /// In en, this message translates to:
  /// **'No matching address'**
  String get locationEmpty;

  /// No description provided for @visualSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search by photo'**
  String get visualSearchTitle;

  /// No description provided for @visualSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Place the product in the frame to scan'**
  String get visualSearchHint;

  /// No description provided for @visualSearchCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get visualSearchCamera;

  /// No description provided for @visualSearchRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get visualSearchRetake;

  /// No description provided for @visualSearchUse.
  ///
  /// In en, this message translates to:
  /// **'Use photo'**
  String get visualSearchUse;

  /// No description provided for @visualSearchGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get visualSearchGallery;

  /// No description provided for @visualSearchNoCamera.
  ///
  /// In en, this message translates to:
  /// **'No camera is available on this device.'**
  String get visualSearchNoCamera;

  /// No description provided for @visualSearchDenied.
  ///
  /// In en, this message translates to:
  /// **'Elyeter needs camera access to search by photo. Allow it in Settings.'**
  String get visualSearchDenied;

  /// No description provided for @visualSearchReady.
  ///
  /// In en, this message translates to:
  /// **'Photo ready — visual search is coming soon.'**
  String get visualSearchReady;

  /// No description provided for @commonOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open {target}'**
  String commonOpenFailed(String target);

  /// No description provided for @orderActiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Active Order'**
  String get orderActiveTitle;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order No. {number}'**
  String orderNumber(String number);

  /// No description provided for @orderRepeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat order'**
  String get orderRepeat;

  /// No description provided for @orderQuestions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get orderQuestions;

  /// No description provided for @orderCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get orderCancel;

  /// No description provided for @orderProgress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Progress'**
  String get orderProgress;

  /// No description provided for @orderStepPlaced.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get orderStepPlaced;

  /// No description provided for @orderStepWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Arrived at China Warehouse'**
  String get orderStepWarehouse;

  /// No description provided for @orderStepShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped to Turkmenistan'**
  String get orderStepShipped;

  /// No description provided for @orderStepArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived in Turkmenistan'**
  String get orderStepArrived;

  /// No description provided for @orderStepDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStepDelivered;

  /// No description provided for @orderStepStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get orderStepStopped;

  /// No description provided for @orderProducts.
  ///
  /// In en, this message translates to:
  /// **'Delivery Products'**
  String get orderProducts;

  /// No description provided for @orderItemSummary.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item for {total}} other{{count} items for {total}}}'**
  String orderItemSummary(int count, String total);

  /// No description provided for @orderPickupPoint.
  ///
  /// In en, this message translates to:
  /// **'Pick-up point'**
  String get orderPickupPoint;

  /// No description provided for @orderSelectAddressTitle.
  ///
  /// In en, this message translates to:
  /// **'Select an address'**
  String get orderSelectAddressTitle;

  /// No description provided for @orderSelectAddressMessage.
  ///
  /// In en, this message translates to:
  /// **'Choose or add an address before placing your order.'**
  String get orderSelectAddressMessage;

  /// No description provided for @orderAddressLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load addresses. Please try again.'**
  String get orderAddressLoadFailed;

  /// No description provided for @orderRecipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get orderRecipient;

  /// No description provided for @orderTime.
  ///
  /// In en, this message translates to:
  /// **'Order Time'**
  String get orderTime;

  /// No description provided for @orderPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get orderPayment;

  /// No description provided for @orderPaymentCard.
  ///
  /// In en, this message translates to:
  /// **'By card / Card payment'**
  String get orderPaymentCard;

  /// No description provided for @orderTotalTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Total'**
  String get orderTotalTitle;

  /// No description provided for @orderProductsTotal.
  ///
  /// In en, this message translates to:
  /// **'Products Total'**
  String get orderProductsTotal;

  /// No description provided for @orderDeliveryLabel.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get orderDeliveryLabel;

  /// No description provided for @orderDeliveryFree.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get orderDeliveryFree;

  /// No description provided for @orderCargo.
  ///
  /// In en, this message translates to:
  /// **'Cargo'**
  String get orderCargo;

  /// No description provided for @orderDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get orderDiscount;

  /// No description provided for @orderDownloadCheck.
  ///
  /// In en, this message translates to:
  /// **'Download Check'**
  String get orderDownloadCheck;

  /// No description provided for @orderCargoNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Cargo cost is calculated after the goods arrive.'**
  String get orderCargoNote;

  /// No description provided for @categoryFilterMaterial.
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get categoryFilterMaterial;

  /// No description provided for @categoryFilterColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get categoryFilterColor;

  /// No description provided for @categoryFilterBrand.
  ///
  /// In en, this message translates to:
  /// **'Brand'**
  String get categoryFilterBrand;

  /// No description provided for @categorySearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get categorySearch;

  /// No description provided for @categoryFilters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get categoryFilters;

  /// No description provided for @categoryOnlyFeatured.
  ///
  /// In en, this message translates to:
  /// **'Featured products only'**
  String get categoryOnlyFeatured;

  /// No description provided for @categorySortTitle.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get categorySortTitle;

  /// No description provided for @categorySortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get categorySortNewest;

  /// No description provided for @categorySortPopular.
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get categorySortPopular;

  /// No description provided for @categoryPriceMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum price'**
  String get categoryPriceMin;

  /// No description provided for @categoryPriceRange.
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get categoryPriceRange;

  /// No description provided for @categoryPriceMax.
  ///
  /// In en, this message translates to:
  /// **'Maximum price'**
  String get categoryPriceMax;

  /// No description provided for @categorySortPriceAsc.
  ///
  /// In en, this message translates to:
  /// **'Price: low to high'**
  String get categorySortPriceAsc;

  /// No description provided for @categorySortPriceDesc.
  ///
  /// In en, this message translates to:
  /// **'Price: high to low'**
  String get categorySortPriceDesc;

  /// No description provided for @categorySortDiscount.
  ///
  /// In en, this message translates to:
  /// **'Biggest discount'**
  String get categorySortDiscount;

  /// No description provided for @categoryApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get categoryApply;

  /// No description provided for @categoryReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get categoryReset;

  /// No description provided for @categoryNoResults.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches these filters'**
  String get categoryNoResults;

  /// No description provided for @categoryProductsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get categoryProductsEmptyTitle;

  /// No description provided for @categoryProductsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'This category has no products right now. Explore another category.'**
  String get categoryProductsEmptyMessage;

  /// No description provided for @categoryNoResultsHint.
  ///
  /// In en, this message translates to:
  /// **'Try removing one of them.'**
  String get categoryNoResultsHint;

  /// No description provided for @categoryFacetSearch.
  ///
  /// In en, this message translates to:
  /// **'Search {facet}'**
  String categoryFacetSearch(String facet);

  /// No description provided for @categorySelectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String categorySelectedCount(int count);

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchClear.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get searchClear;

  /// No description provided for @searchNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get searchNotFoundTitle;

  /// No description provided for @searchNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Please make sure the words are spelled correctly or use fewer or different keywords.'**
  String get searchNotFoundMessage;

  /// No description provided for @searchErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get searchErrorTitle;

  /// No description provided for @searchErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get searchErrorMessage;

  /// No description provided for @searchConnectionErrorTitle.
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get searchConnectionErrorTitle;

  /// No description provided for @searchConnectionErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the server. Please check your internet connection and try again.'**
  String get searchConnectionErrorMessage;

  /// No description provided for @commonSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get commonSeeAll;

  /// No description provided for @commonAddToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Card'**
  String get commonAddToCart;

  /// No description provided for @commonAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get commonAdded;

  /// No description provided for @cartDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get cartDelete;

  /// No description provided for @cartSelectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get cartSelectAll;

  /// No description provided for @cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your Cart Is Empty'**
  String get cartEmpty;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Product'**
  String get cartTitle;

  /// No description provided for @cartEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'You haven’t added any items yet. Explore our collection and find your favorites.'**
  String get cartEmptyMessage;

  /// No description provided for @cartEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get cartEmptyAction;

  /// No description provided for @cartProductCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 Product} other{{count} Product}}'**
  String cartProductCount(int count);

  /// No description provided for @commonCheckout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get commonCheckout;

  /// No description provided for @commonTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get commonTotal;

  /// No description provided for @commonEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get commonEmpty;

  /// No description provided for @productReviewCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 review} other{{count} reviews}}'**
  String productReviewCount(int count);

  /// No description provided for @productOrderCount.
  ///
  /// In en, this message translates to:
  /// **'{count} order'**
  String productOrderCount(int count);

  /// No description provided for @productColor.
  ///
  /// In en, this message translates to:
  /// **'Color: {name}'**
  String productColor(String name);

  /// No description provided for @productSize.
  ///
  /// In en, this message translates to:
  /// **'Ring size: {size}'**
  String productSize(String size);

  /// No description provided for @productArticle.
  ///
  /// In en, this message translates to:
  /// **'Item Article:'**
  String get productArticle;

  /// No description provided for @productPriceDetails.
  ///
  /// In en, this message translates to:
  /// **'Price details'**
  String get productPriceDetails;

  /// No description provided for @productPricePerItem.
  ///
  /// In en, this message translates to:
  /// **'Price per item'**
  String get productPricePerItem;

  /// No description provided for @productRegularPrice.
  ///
  /// In en, this message translates to:
  /// **'Regular price'**
  String get productRegularPrice;

  /// No description provided for @productDiscountPercent.
  ///
  /// In en, this message translates to:
  /// **'{percent}% discount'**
  String productDiscountPercent(int percent);

  /// No description provided for @productCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get productCopy;

  /// No description provided for @productCopied.
  ///
  /// In en, this message translates to:
  /// **'Article copied'**
  String get productCopied;

  /// No description provided for @productShared.
  ///
  /// In en, this message translates to:
  /// **'Product link copied'**
  String get productShared;

  /// No description provided for @productSharePrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get productSharePrice;

  /// No description provided for @productSharePhoto.
  ///
  /// In en, this message translates to:
  /// **'Product photo'**
  String get productSharePhoto;

  /// No description provided for @productShareOpen.
  ///
  /// In en, this message translates to:
  /// **'Open in the Elýeter app'**
  String get productShareOpen;

  /// No description provided for @productShareFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open sharing. Please try again.'**
  String get productShareFailed;

  /// No description provided for @productDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get productDescription;

  /// No description provided for @productReadMore.
  ///
  /// In en, this message translates to:
  /// **'Read More'**
  String get productReadMore;

  /// No description provided for @productReadLess.
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get productReadLess;

  /// No description provided for @productCharacteristics.
  ///
  /// In en, this message translates to:
  /// **'Characteristics'**
  String get productCharacteristics;

  /// No description provided for @productAllCharacteristics.
  ///
  /// In en, this message translates to:
  /// **'All characteristics'**
  String get productAllCharacteristics;

  /// No description provided for @productReviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get productReviews;

  /// No description provided for @reviewEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get reviewEmpty;

  /// No description provided for @reviewWrite.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get reviewWrite;

  /// No description provided for @reviewEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit my review'**
  String get reviewEdit;

  /// No description provided for @reviewDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete my review'**
  String get reviewDelete;

  /// No description provided for @reviewRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get reviewRating;

  /// No description provided for @reviewComment.
  ///
  /// In en, this message translates to:
  /// **'Your review (optional)'**
  String get reviewComment;

  /// No description provided for @reviewIntro.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with this product.'**
  String get reviewIntro;

  /// No description provided for @reviewRatingPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap a star to choose your rating'**
  String get reviewRatingPrompt;

  /// No description provided for @reviewRatingPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get reviewRatingPoor;

  /// No description provided for @reviewRatingFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get reviewRatingFair;

  /// No description provided for @reviewRatingGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get reviewRatingGood;

  /// No description provided for @reviewRatingVeryGood.
  ///
  /// In en, this message translates to:
  /// **'Very good'**
  String get reviewRatingVeryGood;

  /// No description provided for @reviewRatingExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get reviewRatingExcellent;

  /// No description provided for @reviewCommentHint.
  ///
  /// In en, this message translates to:
  /// **'What did you like? What could be better?'**
  String get reviewCommentHint;

  /// No description provided for @reviewHowRate.
  ///
  /// In en, this message translates to:
  /// **'How would you rate this product?'**
  String get reviewHowRate;

  /// No description provided for @reviewSubmit.
  ///
  /// In en, this message translates to:
  /// **'Send review'**
  String get reviewSubmit;

  /// No description provided for @reviewAnonymous.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get reviewAnonymous;

  /// No description provided for @reviewLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get reviewLoadMore;

  /// No description provided for @reviewLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load reviews.'**
  String get reviewLoadError;

  /// No description provided for @reviewActionError.
  ///
  /// In en, this message translates to:
  /// **'Could not update your review.'**
  String get reviewActionError;

  /// No description provided for @reviewSaved.
  ///
  /// In en, this message translates to:
  /// **'Review saved'**
  String get reviewSaved;

  /// No description provided for @reviewDeleted.
  ///
  /// In en, this message translates to:
  /// **'Review deleted'**
  String get reviewDeleted;

  /// No description provided for @reviewDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete your review?'**
  String get reviewDeleteConfirm;

  /// No description provided for @reviewDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'You can write a new review later.'**
  String get reviewDeleteMessage;

  /// No description provided for @reviewHelpful.
  ///
  /// In en, this message translates to:
  /// **'Helpful'**
  String get reviewHelpful;

  /// No description provided for @reviewSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get reviewSortBy;

  /// No description provided for @reviewRatingFilter.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get reviewRatingFilter;

  /// No description provided for @reviewSortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get reviewSortNewest;

  /// No description provided for @reviewSortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get reviewSortOldest;

  /// No description provided for @reviewSortMostLiked.
  ///
  /// In en, this message translates to:
  /// **'Most helpful'**
  String get reviewSortMostLiked;

  /// No description provided for @reviewSortMostDisliked.
  ///
  /// In en, this message translates to:
  /// **'Least helpful'**
  String get reviewSortMostDisliked;

  /// No description provided for @reviewSortWithPhotos.
  ///
  /// In en, this message translates to:
  /// **'With photos'**
  String get reviewSortWithPhotos;

  /// No description provided for @reviewSortWithoutPhotos.
  ///
  /// In en, this message translates to:
  /// **'Without photos'**
  String get reviewSortWithoutPhotos;

  /// No description provided for @reviewAllRatings.
  ///
  /// In en, this message translates to:
  /// **'All ratings'**
  String get reviewAllRatings;

  /// No description provided for @reviewAddPhotos.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get reviewAddPhotos;

  /// No description provided for @reviewPhotoLimit.
  ///
  /// In en, this message translates to:
  /// **'Up to 5 photos'**
  String get reviewPhotoLimit;

  /// No description provided for @reviewPhotoUploadError.
  ///
  /// In en, this message translates to:
  /// **'Could not upload the photo.'**
  String get reviewPhotoUploadError;

  /// No description provided for @reviewNoMatches.
  ///
  /// In en, this message translates to:
  /// **'No reviews match these filters'**
  String get reviewNoMatches;

  /// No description provided for @reviewHiddenNotice.
  ///
  /// In en, this message translates to:
  /// **'Your review is hidden from others'**
  String get reviewHiddenNotice;

  /// No description provided for @reviewHelpfulCount.
  ///
  /// In en, this message translates to:
  /// **'Helpful ({count})'**
  String reviewHelpfulCount(int count);

  /// No description provided for @productRatingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ratings'**
  String productRatingCount(int count);

  /// No description provided for @productReadAllReviews.
  ///
  /// In en, this message translates to:
  /// **'Read all reviews'**
  String get productReadAllReviews;

  /// No description provided for @orderActive.
  ///
  /// In en, this message translates to:
  /// **'Active Order'**
  String get orderActive;

  /// No description provided for @orderCompleted.
  ///
  /// In en, this message translates to:
  /// **'Order Completed'**
  String get orderCompleted;

  /// No description provided for @orderCancelled.
  ///
  /// In en, this message translates to:
  /// **'Order Cancelled'**
  String get orderCancelled;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orderStatusCancelled;

  /// No description provided for @orderCancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel this order?'**
  String get orderCancelTitle;

  /// No description provided for @orderCancelMessage.
  ///
  /// In en, this message translates to:
  /// **'Once cancelled, an order cannot be restored. You can place it again from your cart.'**
  String get orderCancelMessage;

  /// No description provided for @orderCancelKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep order'**
  String get orderCancelKeep;

  /// No description provided for @orderCancelConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel order'**
  String get orderCancelConfirm;

  /// No description provided for @orderRepeatDone.
  ///
  /// In en, this message translates to:
  /// **'Items added to your cart'**
  String get orderRepeatDone;

  /// No description provided for @orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'This order could not be loaded'**
  String get orderNotFound;

  /// No description provided for @orderComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get orderComment;

  /// No description provided for @orderStatusNew.
  ///
  /// In en, this message translates to:
  /// **'Waiting for a call'**
  String get orderStatusNew;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusOrdered.
  ///
  /// In en, this message translates to:
  /// **'Ordered'**
  String get orderStatusOrdered;

  /// No description provided for @orderStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get orderStatusCompleted;

  /// No description provided for @orderReceiptTitle.
  ///
  /// In en, this message translates to:
  /// **'Order receipt'**
  String get orderReceiptTitle;

  /// No description provided for @orderReceiptItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get orderReceiptItems;

  /// No description provided for @orderReceiptQty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get orderReceiptQty;

  /// No description provided for @orderReceiptPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get orderReceiptPrice;

  /// No description provided for @orderReceiptAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get orderReceiptAmount;

  /// No description provided for @orderReceiptThanks.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your order'**
  String get orderReceiptThanks;

  /// No description provided for @orderReceiptFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the receipt'**
  String get orderReceiptFailed;

  /// No description provided for @orderTrackRefresh.
  ///
  /// In en, this message translates to:
  /// **'Updates every 15 seconds'**
  String get orderTrackRefresh;

  /// No description provided for @orderTrackNoPoint.
  ///
  /// In en, this message translates to:
  /// **'No delivery point was set'**
  String get orderTrackNoPoint;

  /// No description provided for @orderTrackMapPoint.
  ///
  /// In en, this message translates to:
  /// **'Delivery point on the map'**
  String get orderTrackMapPoint;

  /// No description provided for @orderTrackNoCourier.
  ///
  /// In en, this message translates to:
  /// **'Live courier location and arrival time are not available yet.'**
  String get orderTrackNoCourier;

  /// No description provided for @orderTrackCancelled.
  ///
  /// In en, this message translates to:
  /// **'This order was cancelled.'**
  String get orderTrackCancelled;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order history'**
  String get orderHistory;

  /// No description provided for @orderHistoryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get orderHistoryEmptyTitle;

  /// No description provided for @orderHistoryEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Your orders will appear here after you place one.'**
  String get orderHistoryEmptyMessage;

  /// No description provided for @activeOrdersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No active orders'**
  String get activeOrdersEmptyTitle;

  /// No description provided for @activeOrdersEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Orders in progress will appear here.'**
  String get activeOrdersEmptyMessage;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderStatusDelivered;

  /// No description provided for @orderItemsFor.
  ///
  /// In en, this message translates to:
  /// **'{count} items for {amount}'**
  String orderItemsFor(int count, String amount);

  /// No description provided for @orderItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No products} =1{1 product} other{{count} products}}'**
  String orderItemCount(int count);

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get onboardingWelcome;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You can quickly and securely log in to your account.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onboardingStart;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get settingsLanguageDialogTitle;

  /// No description provided for @settingsLanguageDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose the language you\'d like to use.'**
  String get settingsLanguageDialogSubtitle;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @errorServer.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorServer;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get errorNetwork;

  /// No description provided for @errorTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request took too long.'**
  String get errorTimeout;

  /// No description provided for @errorUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'Please sign in to continue.'**
  String get errorUnauthorized;

  /// No description provided for @errorNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find what you were looking for.'**
  String get errorNotFound;

  /// No description provided for @errorCache.
  ///
  /// In en, this message translates to:
  /// **'Could not read saved data.'**
  String get errorCache;

  /// No description provided for @errorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error.'**
  String get errorUnknown;

  /// No description provided for @profileEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEditProfile;

  /// No description provided for @profileAllOrders.
  ///
  /// In en, this message translates to:
  /// **'All Orders'**
  String get profileAllOrders;

  /// No description provided for @profileOrderCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No orders} =1{1 Order} other{{count} Orders}}'**
  String profileOrderCount(int count);

  /// No description provided for @profileSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get profileSectionGeneral;

  /// No description provided for @profileSectionOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get profileSectionOther;

  /// No description provided for @profileSectionContact.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get profileSectionContact;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profileActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'Active orders'**
  String get profileActiveOrders;

  /// No description provided for @profileSavedLocations.
  ///
  /// In en, this message translates to:
  /// **'My saved locations'**
  String get profileSavedLocations;

  /// No description provided for @addressListTitle.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addressListTitle;

  /// No description provided for @addressAddWork.
  ///
  /// In en, this message translates to:
  /// **'Add Work Address'**
  String get addressAddWork;

  /// No description provided for @addressAddHome.
  ///
  /// In en, this message translates to:
  /// **'Add Home Address'**
  String get addressAddHome;

  /// No description provided for @addressAddNew.
  ///
  /// In en, this message translates to:
  /// **'Add New Address'**
  String get addressAddNew;

  /// No description provided for @addressNameWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get addressNameWork;

  /// No description provided for @addressNameHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get addressNameHome;

  /// No description provided for @addressEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get addressEdit;

  /// No description provided for @addressMakeDefault.
  ///
  /// In en, this message translates to:
  /// **'Make default'**
  String get addressMakeDefault;

  /// No description provided for @addressDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get addressDelete;

  /// No description provided for @addressMapLocation.
  ///
  /// In en, this message translates to:
  /// **'Location on map'**
  String get addressMapLocation;

  /// No description provided for @addressMapHint.
  ///
  /// In en, this message translates to:
  /// **'Street, building, city'**
  String get addressMapHint;

  /// No description provided for @addressApartmentFlat.
  ///
  /// In en, this message translates to:
  /// **'Apartment / Flat'**
  String get addressApartmentFlat;

  /// No description provided for @addressApartmentHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 35/1'**
  String get addressApartmentHint;

  /// No description provided for @addressFloor.
  ///
  /// In en, this message translates to:
  /// **'Floor'**
  String get addressFloor;

  /// No description provided for @addressFloorHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 3'**
  String get addressFloorHint;

  /// No description provided for @addressNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Address name'**
  String get addressNameLabel;

  /// No description provided for @addressSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save address'**
  String get addressSaveButton;

  /// No description provided for @addressResolving.
  ///
  /// In en, this message translates to:
  /// **'Finding address…'**
  String get addressResolving;

  /// No description provided for @addressTypeHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get addressTypeHome;

  /// No description provided for @addressTypeWork.
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get addressTypeWork;

  /// No description provided for @addressTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get addressTypeOther;

  /// No description provided for @addressPointRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a point on the map first.'**
  String get addressPointRequired;

  /// No description provided for @addressNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an address name.'**
  String get addressNameRequired;

  /// No description provided for @addressLocationApproximate.
  ///
  /// In en, this message translates to:
  /// **'Location is approximate. Move the pin to the exact spot.'**
  String get addressLocationApproximate;

  /// No description provided for @addressLocationFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not get your location. Choose it on the map.'**
  String get addressLocationFailed;

  /// No description provided for @addressLocationServiceOff.
  ///
  /// In en, this message translates to:
  /// **'Location is turned off. Turn it on in settings, or choose the spot on the map.'**
  String get addressLocationServiceOff;

  /// No description provided for @addressLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location access is not allowed. Allow it in settings, or choose the spot on the map.'**
  String get addressLocationPermissionDenied;

  /// No description provided for @addressOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get addressOpenSettings;

  /// No description provided for @addressLookupFailed.
  ///
  /// In en, this message translates to:
  /// **'Street address unavailable. Type the address manually.'**
  String get addressLookupFailed;

  /// No description provided for @addressEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses yet'**
  String get addressEmptyTitle;

  /// No description provided for @addressEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Tap + to save your first delivery address.'**
  String get addressEmptyMessage;

  /// No description provided for @addressDeleteDone.
  ///
  /// In en, this message translates to:
  /// **'Address deleted.'**
  String get addressDeleteDone;

  /// No description provided for @profileOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order history'**
  String get profileOrderHistory;

  /// No description provided for @profileAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get profileAnnouncements;

  /// No description provided for @profileDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get profileDarkMode;

  /// No description provided for @profileAboutApp.
  ///
  /// In en, this message translates to:
  /// **'About the app'**
  String get profileAboutApp;

  /// No description provided for @profileFaq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get profileFaq;

  /// No description provided for @profileTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get profileTerms;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get profilePrivacy;

  /// No description provided for @staticPageEmpty.
  ///
  /// In en, this message translates to:
  /// **'Content will appear here when it is available.'**
  String get staticPageEmpty;

  /// No description provided for @profileWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get profileWhatsapp;

  /// No description provided for @profileInstagram.
  ///
  /// In en, this message translates to:
  /// **'Instagram'**
  String get profileInstagram;

  /// No description provided for @profileTiktok.
  ///
  /// In en, this message translates to:
  /// **'TikTok'**
  String get profileTiktok;

  /// No description provided for @profileCallTitle.
  ///
  /// In en, this message translates to:
  /// **'Call us with any question:'**
  String get profileCallTitle;

  /// No description provided for @profileCallAction.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get profileCallAction;

  /// No description provided for @profileCallHours.
  ///
  /// In en, this message translates to:
  /// **'Calls are answered every day of the week, 09:00 - 19:00'**
  String get profileCallHours;

  /// No description provided for @profileVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String profileVersion(String version);

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get profileSignOut;

  /// No description provided for @profileSignOutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get profileSignOutTitle;

  /// No description provided for @profileSignOutMessage.
  ///
  /// In en, this message translates to:
  /// **'You will need your phone number to sign in again.'**
  String get profileSignOutMessage;

  /// No description provided for @profileGuestTitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to your account'**
  String get profileGuestTitle;

  /// No description provided for @profileGuestMessage.
  ///
  /// In en, this message translates to:
  /// **'Clothing, products, home goods and more to order'**
  String get profileGuestMessage;

  /// No description provided for @profileGuestAction.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get profileGuestAction;

  /// No description provided for @authSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// No description provided for @authSignInRequiredTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in required'**
  String get authSignInRequiredTitle;

  /// No description provided for @authSignInRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Sign in to use this part of the app.'**
  String get authSignInRequiredMessage;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginPhoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginPhoneTitle;

  /// No description provided for @loginPhoneMessage.
  ///
  /// In en, this message translates to:
  /// **'You can quickly and securely log in to your account by entering your phone number.'**
  String get loginPhoneMessage;

  /// No description provided for @loginPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get loginPhoneLabel;

  /// No description provided for @loginPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Your phone number'**
  String get loginPhoneHint;

  /// No description provided for @loginSendCode.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get loginSendCode;

  /// No description provided for @loginLegalNotice.
  ///
  /// In en, this message translates to:
  /// **'By using Elyeter, you agree to the Terms of use and Privacy policy.'**
  String get loginLegalNotice;

  /// No description provided for @loginReadTerms.
  ///
  /// In en, this message translates to:
  /// **'Read the terms'**
  String get loginReadTerms;

  /// No description provided for @loginCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get loginCodeTitle;

  /// No description provided for @loginCodeMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter the code sent to {phone}'**
  String loginCodeMessage(String phone);

  /// No description provided for @loginCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirmation code'**
  String get loginCodeLabel;

  /// No description provided for @loginVerify.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get loginVerify;

  /// No description provided for @loginResend.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get loginResend;

  /// No description provided for @loginResendCountdown.
  ///
  /// In en, this message translates to:
  /// **'Resend code {time}'**
  String loginResendCountdown(String time);

  /// No description provided for @loginResendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds} s'**
  String loginResendIn(int seconds);

  /// No description provided for @loginChangePhone.
  ///
  /// In en, this message translates to:
  /// **'Change number'**
  String get loginChangePhone;

  /// No description provided for @loginSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You are signed in'**
  String get loginSignedIn;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageTurkmen.
  ///
  /// In en, this message translates to:
  /// **'Türkmençe'**
  String get settingsLanguageTurkmen;

  /// No description provided for @settingsLanguageRussian.
  ///
  /// In en, this message translates to:
  /// **'Русский'**
  String get settingsLanguageRussian;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get editProfileTitle;

  /// No description provided for @editProfileName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get editProfileName;

  /// No description provided for @editProfileNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get editProfileNameHint;

  /// No description provided for @editProfilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get editProfilePhone;

  /// No description provided for @editProfilePhoneNote.
  ///
  /// In en, this message translates to:
  /// **'Contact support to change your number'**
  String get editProfilePhoneNote;

  /// No description provided for @editProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get editProfilePhoto;

  /// No description provided for @editProfilePhotoCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get editProfilePhotoCamera;

  /// No description provided for @editProfilePhotoGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get editProfilePhotoGallery;

  /// No description provided for @editProfilePhotoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get editProfilePhotoRemove;

  /// No description provided for @editProfilePhotoTooLarge.
  ///
  /// In en, this message translates to:
  /// **'This photo could not be reduced below 1 MB. Choose another photo.'**
  String get editProfilePhotoTooLarge;

  /// No description provided for @editProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get editProfileSaved;

  /// No description provided for @editProfileNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get editProfileNameRequired;

  /// No description provided for @editProfilePhotoHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the photo to change it'**
  String get editProfilePhotoHint;

  /// No description provided for @editProfileNameCounter.
  ///
  /// In en, this message translates to:
  /// **'{count}/40'**
  String editProfileNameCounter(int count);

  /// No description provided for @editProfileNothingChanged.
  ///
  /// In en, this message translates to:
  /// **'Nothing to save yet'**
  String get editProfileNothingChanged;

  /// No description provided for @aboutTagline.
  ///
  /// In en, this message translates to:
  /// **'Everything from the big marketplaces, delivered to Turkmenistan.'**
  String get aboutTagline;

  /// No description provided for @legalUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {date}'**
  String legalUpdated(String date);

  /// No description provided for @faqTitle.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faqTitle;

  /// No description provided for @faqQ1.
  ///
  /// In en, this message translates to:
  /// **'How do I place an order?'**
  String get faqQ1;

  /// No description provided for @faqA1.
  ///
  /// In en, this message translates to:
  /// **'Add what you want to the cart, open the Cart tab and tap Checkout. The total, including delivery, is shown before you confirm.'**
  String get faqA1;

  /// No description provided for @faqQ2.
  ///
  /// In en, this message translates to:
  /// **'How long does delivery take?'**
  String get faqQ2;

  /// No description provided for @faqA2.
  ///
  /// In en, this message translates to:
  /// **'Items in local stock arrive in 1–3 days. Orders from partner marketplaces take 10–20 days, depending on the seller.'**
  String get faqA2;

  /// No description provided for @faqQ3.
  ///
  /// In en, this message translates to:
  /// **'How do I track my order?'**
  String get faqQ3;

  /// No description provided for @faqA3.
  ///
  /// In en, this message translates to:
  /// **'Open Profile → Active orders. Every step from confirmation to delivery is listed there.'**
  String get faqA3;

  /// No description provided for @faqQ4.
  ///
  /// In en, this message translates to:
  /// **'Can I cancel an order?'**
  String get faqQ4;

  /// No description provided for @faqA4.
  ///
  /// In en, this message translates to:
  /// **'Yes, while it is still marked Confirmed. Once it has shipped, call the operator and we will help.'**
  String get faqA4;

  /// No description provided for @faqQ5.
  ///
  /// In en, this message translates to:
  /// **'How do returns work?'**
  String get faqQ5;

  /// No description provided for @faqA5.
  ///
  /// In en, this message translates to:
  /// **'Call the operator within 3 days of delivery. Unused items in their original packaging are accepted.'**
  String get faqA5;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsTitle;

  /// No description provided for @termsS1.
  ///
  /// In en, this message translates to:
  /// **'Using the app'**
  String get termsS1;

  /// No description provided for @termsB1.
  ///
  /// In en, this message translates to:
  /// **'By using Elyeter you accept these terms. If you do not agree with them, please stop using the app.'**
  String get termsB1;

  /// No description provided for @termsS2.
  ///
  /// In en, this message translates to:
  /// **'Orders and prices'**
  String get termsS2;

  /// No description provided for @termsB2.
  ///
  /// In en, this message translates to:
  /// **'Prices are shown in TMT and may change until an order is confirmed. Availability at partner marketplaces is outside our control.'**
  String get termsB2;

  /// No description provided for @termsS3.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get termsS3;

  /// No description provided for @termsB3.
  ///
  /// In en, this message translates to:
  /// **'Delivery times are estimates, not guarantees. Customs and seller delays can extend them.'**
  String get termsB3;

  /// No description provided for @termsS4.
  ///
  /// In en, this message translates to:
  /// **'Returns'**
  String get termsS4;

  /// No description provided for @termsB4.
  ///
  /// In en, this message translates to:
  /// **'Unused items in original packaging can be returned within 3 days of delivery. Made-to-order and personal-care items cannot.'**
  String get termsB4;

  /// No description provided for @termsS5.
  ///
  /// In en, this message translates to:
  /// **'Your account'**
  String get termsS5;

  /// No description provided for @termsB5.
  ///
  /// In en, this message translates to:
  /// **'Your phone number identifies your account. Keep it up to date — orders and delivery calls go to it.'**
  String get termsB5;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyTitle;

  /// No description provided for @privacyS1.
  ///
  /// In en, this message translates to:
  /// **'What we collect'**
  String get privacyS1;

  /// No description provided for @privacyB1.
  ///
  /// In en, this message translates to:
  /// **'Your name, phone number, delivery address and order history. Nothing else is required to use Elyeter.'**
  String get privacyB1;

  /// No description provided for @privacyS2.
  ///
  /// In en, this message translates to:
  /// **'Why we use it'**
  String get privacyS2;

  /// No description provided for @privacyB2.
  ///
  /// In en, this message translates to:
  /// **'To deliver your orders, keep you updated about them and answer you when you contact support.'**
  String get privacyB2;

  /// No description provided for @privacyS3.
  ///
  /// In en, this message translates to:
  /// **'Who we share it with'**
  String get privacyS3;

  /// No description provided for @privacyB3.
  ///
  /// In en, this message translates to:
  /// **'Only couriers and payment providers, and only the part they need to complete your order. We never sell your data.'**
  String get privacyB3;

  /// No description provided for @privacyS4.
  ///
  /// In en, this message translates to:
  /// **'How long we keep it'**
  String get privacyS4;

  /// No description provided for @privacyB4.
  ///
  /// In en, this message translates to:
  /// **'While your account exists, plus the period accounting rules require for completed orders.'**
  String get privacyB4;

  /// No description provided for @privacyS5.
  ///
  /// In en, this message translates to:
  /// **'Your rights'**
  String get privacyS5;

  /// No description provided for @privacyB5.
  ///
  /// In en, this message translates to:
  /// **'Call the operator to get a copy of your data or ask for your account to be deleted.'**
  String get privacyB5;

  /// No description provided for @categoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categoryTitle;

  /// No description provided for @errorOtpRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Please wait before asking for a new code.'**
  String get errorOtpRateLimited;

  /// No description provided for @errorOtpInvalid.
  ///
  /// In en, this message translates to:
  /// **'That code is not right.'**
  String get errorOtpInvalid;

  /// No description provided for @errorOtpTooManyAttempts.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Request a new code.'**
  String get errorOtpTooManyAttempts;

  /// No description provided for @errorOtpExpired.
  ///
  /// In en, this message translates to:
  /// **'The code has expired. Request a new one.'**
  String get errorOtpExpired;

  /// No description provided for @errorUserBlocked.
  ///
  /// In en, this message translates to:
  /// **'This account has been blocked.'**
  String get errorUserBlocked;

  /// No description provided for @errorVariantRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose an option before ordering.'**
  String get errorVariantRequired;

  /// No description provided for @errorItemsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Some items are no longer available.'**
  String get errorItemsUnavailable;

  /// No description provided for @errorPriceChanged.
  ///
  /// In en, this message translates to:
  /// **'The total has changed. Please check it again.'**
  String get errorPriceChanged;

  /// No description provided for @errorSupplierUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The supplier is not responding. Try again in a couple of minutes.'**
  String get errorSupplierUnavailable;

  /// No description provided for @errorCannotCancel.
  ///
  /// In en, this message translates to:
  /// **'This order can no longer be cancelled.'**
  String get errorCannotCancel;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Please slow down.'**
  String get errorTooManyRequests;

  /// No description provided for @errorValidation.
  ///
  /// In en, this message translates to:
  /// **'Please check the details you entered.'**
  String get errorValidation;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete your account?'**
  String get profileDeleteTitle;

  /// No description provided for @profileDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This is permanent. Your account and everything in it is removed from Elyeter and cannot be restored.'**
  String get profileDeleteMessage;

  /// No description provided for @profileDeleteLossOrders.
  ///
  /// In en, this message translates to:
  /// **'Your order history'**
  String get profileDeleteLossOrders;

  /// No description provided for @profileDeleteLossProfile.
  ///
  /// In en, this message translates to:
  /// **'Your name, photo and saved details'**
  String get profileDeleteLossProfile;

  /// No description provided for @profileDeleteLossAccess.
  ///
  /// In en, this message translates to:
  /// **'Access to the account on this number'**
  String get profileDeleteLossAccess;

  /// No description provided for @profileDeleteAccountOn.
  ///
  /// In en, this message translates to:
  /// **'Account: {phone}'**
  String profileDeleteAccountOn(String phone);

  /// No description provided for @profileDeleteKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep my account'**
  String get profileDeleteKeep;

  /// No description provided for @profileDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get profileDeleteConfirm;

  /// No description provided for @profileDeleteDone.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get profileDeleteDone;

  /// No description provided for @commonOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @errorPaymentBankFailed.
  ///
  /// In en, this message translates to:
  /// **'The bank didn\'t accept the payment. Try later or choose another bank.'**
  String get errorPaymentBankFailed;

  /// No description provided for @errorPreOrderAlreadyPaid.
  ///
  /// In en, this message translates to:
  /// **'This order has already been paid.'**
  String get errorPreOrderAlreadyPaid;

  /// No description provided for @errorPreOrderNotPayable.
  ///
  /// In en, this message translates to:
  /// **'This order can no longer be paid online.'**
  String get errorPreOrderNotPayable;

  /// No description provided for @errorBankNotFound.
  ///
  /// In en, this message translates to:
  /// **'This bank is not available right now. Choose another one.'**
  String get errorBankNotFound;

  /// No description provided for @errorProductRequestInvalidLink.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find an AliExpress product link in this text.'**
  String get errorProductRequestInvalidLink;

  /// No description provided for @paymentTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentTitle;

  /// No description provided for @paymentChooseBank.
  ///
  /// In en, this message translates to:
  /// **'Choose a bank'**
  String get paymentChooseBank;

  /// No description provided for @paymentChooseBankHint.
  ///
  /// In en, this message translates to:
  /// **'You\'ll enter your card details on the bank\'s page.'**
  String get paymentChooseBankHint;

  /// No description provided for @paymentNoBanks.
  ///
  /// In en, this message translates to:
  /// **'Online payment is not available right now.'**
  String get paymentNoBanks;

  /// No description provided for @paymentPayOnlineTitle.
  ///
  /// In en, this message translates to:
  /// **'Pay online'**
  String get paymentPayOnlineTitle;

  /// No description provided for @paymentPayOnlineMessage.
  ///
  /// In en, this message translates to:
  /// **'Pay for the order by card now — no need to wait for the call.'**
  String get paymentPayOnlineMessage;

  /// No description provided for @paymentPay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get paymentPay;

  /// No description provided for @paymentPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid online'**
  String get paymentPaid;

  /// No description provided for @paymentChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking payment…'**
  String get paymentChecking;

  /// No description provided for @paymentCheckingMessage.
  ///
  /// In en, this message translates to:
  /// **'This takes a few seconds.'**
  String get paymentCheckingMessage;

  /// No description provided for @paymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get paymentSuccess;

  /// No description provided for @paymentSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your order is paid. Thank you!'**
  String get paymentSuccessMessage;

  /// No description provided for @paymentFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentFailed;

  /// No description provided for @paymentFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'The bank declined the payment. You can try again or choose another bank.'**
  String get paymentFailedMessage;

  /// No description provided for @paymentPending.
  ///
  /// In en, this message translates to:
  /// **'Payment is being checked'**
  String get paymentPending;

  /// No description provided for @paymentPendingMessage.
  ///
  /// In en, this message translates to:
  /// **'The bank hasn\'t confirmed it yet. The order will be marked as paid as soon as it does.'**
  String get paymentPendingMessage;

  /// No description provided for @paymentNotCompletedMessage.
  ///
  /// In en, this message translates to:
  /// **'The payment wasn\'t completed. If money was taken from your card, the order will be marked as paid within a few minutes.'**
  String get paymentNotCompletedMessage;

  /// No description provided for @paymentTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get paymentTryAgain;

  /// No description provided for @productRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Send us a link'**
  String get productRequestTitle;

  /// No description provided for @productRequestMessage.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t find a product? Paste an AliExpress link and we\'ll add it to the catalog.'**
  String get productRequestMessage;

  /// No description provided for @productRequestHint.
  ///
  /// In en, this message translates to:
  /// **'AliExpress link or share text'**
  String get productRequestHint;

  /// No description provided for @productRequestPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get productRequestPaste;

  /// No description provided for @productRequestSend.
  ///
  /// In en, this message translates to:
  /// **'Send link'**
  String get productRequestSend;

  /// No description provided for @productRequestSendAnother.
  ///
  /// In en, this message translates to:
  /// **'Send another link'**
  String get productRequestSendAnother;

  /// No description provided for @productRequestMine.
  ///
  /// In en, this message translates to:
  /// **'My product requests'**
  String get productRequestMine;

  /// No description provided for @productRequestSearchAction.
  ///
  /// In en, this message translates to:
  /// **'Send a link to the product'**
  String get productRequestSearchAction;

  /// No description provided for @productRequestLoadingTitle.
  ///
  /// In en, this message translates to:
  /// **'Loading the product…'**
  String get productRequestLoadingTitle;

  /// No description provided for @productRequestLoadingMessage.
  ///
  /// In en, this message translates to:
  /// **'This usually takes up to a minute.'**
  String get productRequestLoadingMessage;

  /// No description provided for @productRequestLaterTitle.
  ///
  /// In en, this message translates to:
  /// **'We\'ll notify you'**
  String get productRequestLaterTitle;

  /// No description provided for @productRequestLaterMessage.
  ///
  /// In en, this message translates to:
  /// **'It\'s taking a little longer. We\'ll send you a notification when the product is available.'**
  String get productRequestLaterMessage;

  /// No description provided for @productRequestReviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get productRequestReviewTitle;

  /// No description provided for @productRequestReviewMessage.
  ///
  /// In en, this message translates to:
  /// **'The product is under review. We\'ll notify you when it\'s available.'**
  String get productRequestReviewMessage;

  /// No description provided for @productRequestRejectedTitle.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get productRequestRejectedTitle;

  /// No description provided for @productRequestRejectedMessage.
  ///
  /// In en, this message translates to:
  /// **'Sorry, we can\'t sell this product.'**
  String get productRequestRejectedMessage;

  /// No description provided for @productRequestFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load'**
  String get productRequestFailedTitle;

  /// No description provided for @productRequestFailedMessage.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load the product from AliExpress. It may have been removed from sale.'**
  String get productRequestFailedMessage;

  /// No description provided for @productRequestAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Product added'**
  String get productRequestAvailableTitle;

  /// No description provided for @productRequestAvailableMessage.
  ///
  /// In en, this message translates to:
  /// **'The product is in the catalog. Find it in My product requests.'**
  String get productRequestAvailableMessage;

  /// No description provided for @productRequestStatusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get productRequestStatusProcessing;

  /// No description provided for @productRequestStatusInReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get productRequestStatusInReview;

  /// No description provided for @productRequestStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get productRequestStatusAvailable;

  /// No description provided for @productRequestStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get productRequestStatusRejected;

  /// No description provided for @productRequestStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Not loaded'**
  String get productRequestStatusFailed;

  /// No description provided for @productRequestEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No requests yet'**
  String get productRequestEmptyTitle;

  /// No description provided for @errorImageSearchInvalidImage.
  ///
  /// In en, this message translates to:
  /// **'Use a JPEG, PNG or WebP photo.'**
  String get errorImageSearchInvalidImage;

  /// No description provided for @errorImageSearchInProgress.
  ///
  /// In en, this message translates to:
  /// **'The previous search is still being sent. Please wait.'**
  String get errorImageSearchInProgress;

  /// No description provided for @errorImageSearchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Search is temporarily unavailable. Try again later.'**
  String get errorImageSearchUnavailable;

  /// No description provided for @imageSearchTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo search'**
  String get imageSearchTitle;

  /// No description provided for @imageSearchSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching for more…'**
  String get imageSearchSearching;

  /// No description provided for @imageSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing similar yet'**
  String get imageSearchEmpty;

  /// No description provided for @imageSearchRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Search limit reached. Try again in {minutes} min.'**
  String imageSearchRateLimited(int minutes);

  /// No description provided for @imageSearchInReview.
  ///
  /// In en, this message translates to:
  /// **'Your photo has been processed. {count} more products are being checked by a moderator — we will send a notification.'**
  String imageSearchInReview(int count);

  /// No description provided for @imageSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load products from AliExpress.'**
  String get imageSearchFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'tk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'tk':
      return AppLocalizationsTk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
