// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkmen (`tk`).
class AppLocalizationsTk extends AppLocalizations {
  AppLocalizationsTk([String locale = 'tk']) : super(locale);

  @override
  String get appName => 'Elyeter';

  @override
  String get navHome => 'Baş sahypa';

  @override
  String get navCategory => 'Bölümler';

  @override
  String get navCart => 'Sebet';

  @override
  String get navFavorite => 'Halanlarym';

  @override
  String get favoriteTitle => 'Halanlarym';

  @override
  String get favoriteEmptyTitle => 'Halan harytlaryňyz ýok';

  @override
  String get favoriteEmptyMessage =>
      'Halan harytlaryňyzy saklaň we gerek bolanda şu ýerden tapyň.';

  @override
  String get favoriteEmptyAction => 'Göz aýla';

  @override
  String get navProfile => 'Profil';

  @override
  String get commonRetry => 'Gaýtadan synanyş';

  @override
  String get notificationsEmptyTitle => 'Heniz bildiriş ýok';

  @override
  String get notificationsEmptyMessage =>
      'Täze bildirişler şu ýerde peýda bolar.';

  @override
  String get notificationsOverviewTitle => 'Elyeter-den täzelikler';

  @override
  String get notificationsOverviewMessage =>
      'Teklipler we möhüm habarlar bir ýerde.';

  @override
  String get notificationsToday => 'Şu gün';

  @override
  String get notificationsYesterday => 'Düýn';

  @override
  String get notificationsEarlier => 'Öňki bildirişler';

  @override
  String get notificationsNew => 'Täze';

  @override
  String get notificationsLoadMore => 'Has köp görkez';

  @override
  String get notificationsRefresh => 'Täzele';

  @override
  String get announcementsEmptyTitle => 'Heniz habar ýok';

  @override
  String get announcementsEmptyMessage => 'Täze habarlar şu ýerde peýda bolar.';

  @override
  String get commonCancel => 'Ýatyr';

  @override
  String get commonClose => 'Ýap';

  @override
  String get commonSave => 'Ýatda sakla';

  @override
  String get commonSearch => 'Gözleg';

  @override
  String get homeSearchHint => 'Haryt gözle';

  @override
  String get locationTitle => 'Eltip bermek salgysy';

  @override
  String get locationSearchHint => 'Etrap ýa-da köçe gözle';

  @override
  String get locationEmpty => 'Salgy tapylmady';

  @override
  String get visualSearchTitle => 'Surat boýunça gözleg';

  @override
  String get visualSearchHint => 'Skanirlemek üçin harydy çarçuwa ýerleşdiriň';

  @override
  String get visualSearchCamera => 'Surat al';

  @override
  String get visualSearchRetake => 'Täzeden al';

  @override
  String get visualSearchUse => 'Suraty ulan';

  @override
  String get visualSearchGallery => 'Galereýadan saýla';

  @override
  String get visualSearchNoCamera => 'Bu enjamda kamera ýok.';

  @override
  String get visualSearchDenied =>
      'Surat boýunça gözlemek üçin Elyeter-e kamera rugsady gerek. Sazlamalardan rugsat beriň.';

  @override
  String get visualSearchReady =>
      'Surat taýýar — surat boýunça gözleg tiz wagtda.';

  @override
  String commonOpenFailed(String target) {
    return '$target açyp bolmady';
  }

  @override
  String get orderActiveTitle => 'Işjeň sargyt';

  @override
  String orderNumber(String number) {
    return 'Sargyt № $number';
  }

  @override
  String get orderRepeat => 'Sargydy gaýtala';

  @override
  String get orderQuestions => 'Soraglar';

  @override
  String get orderCancel => 'Ýatyr';

  @override
  String get orderProgress => 'Eltip berişiň barşy';

  @override
  String get orderStepPlaced => 'Sargyt kabul edildi';

  @override
  String get orderStepWarehouse => 'Hytaý ammaryna geldi';

  @override
  String get orderStepShipped => 'Türkmenistana ugradyldy';

  @override
  String get orderStepArrived => 'Türkmenistana geldi';

  @override
  String get orderStepDelivered => 'Eltildi';

  @override
  String get orderStepStopped => 'Togtadyldy';

  @override
  String get orderProducts => 'Eltilýän harytlar';

  @override
  String orderItemSummary(int count, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count haryt $total',
      one: '1 haryt $total',
    );
    return '$_temp0';
  }

  @override
  String get orderPickupPoint => 'Almak nokady';

  @override
  String get orderSelectAddressTitle => 'Salgyny saýlaň';

  @override
  String get orderSelectAddressMessage =>
      'Sargyt bermezden öň salgy saýlaň ýa-da täze salgy goşuň.';

  @override
  String get orderAddressLoadFailed =>
      'Salgylary ýükläp bolmady. Gaýtadan synanyşyň.';

  @override
  String get orderRecipient => 'Alyjy';

  @override
  String get orderTime => 'Sargyt wagty';

  @override
  String get orderPayment => 'Töleg usuly';

  @override
  String get orderPaymentCard => 'Kart bilen / Kart tölegi';

  @override
  String get orderTotalTitle => 'Sargydyň jemi';

  @override
  String get orderProductsTotal => 'Harytlaryň jemi';

  @override
  String get orderDeliveryLabel => 'Eltip berme';

  @override
  String get orderDeliveryFree => 'Mugt';

  @override
  String get orderCargo => 'Kargo';

  @override
  String get orderDiscount => 'Arzanladyş';

  @override
  String get orderDownloadCheck => 'Çeki ýükle';

  @override
  String get orderCargoNote =>
      'Bellik: Kargo bahasy haryt gelenden soň hasaplanylýar.';

  @override
  String get categoryFilterMaterial => 'Material';

  @override
  String get categoryFilterColor => 'Reňk';

  @override
  String get categoryFilterBrand => 'Marka';

  @override
  String get categorySearch => 'Gözleg';

  @override
  String get categoryFilters => 'Süzgüçler';

  @override
  String get categoryOnlyFeatured => 'Diňe öňe çykarylan harytlar';

  @override
  String get categorySortTitle => 'Tertipleme';

  @override
  String get categorySortNewest => 'Iň täzeler';

  @override
  String get categorySortPopular => 'Meşhur';

  @override
  String get categoryPriceMin => 'Iň pes baha';

  @override
  String get categoryPriceRange => 'Baha aralygy';

  @override
  String get categoryPriceMax => 'Iň ýokary baha';

  @override
  String get categorySortPriceAsc => 'Baha: arzandan gymmada';

  @override
  String get categorySortPriceDesc => 'Baha: gymmatdan arzana';

  @override
  String get categorySortDiscount => 'Iň uly arzanladyş';

  @override
  String get categoryApply => 'Ulan';

  @override
  String get categoryReset => 'Arassala';

  @override
  String get categoryNoResults => 'Bu süzgüçlere hiç zat gabat gelmedi';

  @override
  String get categoryProductsEmptyTitle => 'Häzirlikçe haryt ýok';

  @override
  String get categoryProductsEmptyMessage =>
      'Bu kategoriýada häzir haryt ýok. Beýleki kategoriýalara serediň.';

  @override
  String get categoryNoResultsHint => 'Birini aýryp görüň.';

  @override
  String categoryFacetSearch(String facet) {
    return 'Gözleg: $facet';
  }

  @override
  String categorySelectedCount(int count) {
    return '$count saýlandy';
  }

  @override
  String get searchTitle => 'Gözleg';

  @override
  String get searchClear => 'Gözlegi arassala';

  @override
  String get searchNotFoundTitle => 'Tapylmady';

  @override
  String get searchNotFoundMessage =>
      'Sözleriň dogry ýazylandygyny barlaň ýa-da başga açar sözleri ulanyp görüň.';

  @override
  String get searchErrorTitle => 'Ýalňyşlyk';

  @override
  String get searchErrorMessage => 'Ýalňyşlyk ýüze çykdy. Täzeden synanyşyň.';

  @override
  String get searchConnectionErrorTitle => 'Baglanyşyk ýalňyşlygy';

  @override
  String get searchConnectionErrorMessage =>
      'Serwere birigip bolmady. Internet birikmesini barlap, täzeden synanyşyň.';

  @override
  String get commonSeeAll => 'Hemmesi';

  @override
  String get commonAddToCart => 'Sebede goş';

  @override
  String get commonAdded => 'Goşuldy';

  @override
  String get cartDelete => 'Poz';

  @override
  String get cartSelectAll => 'Hemmesini saýla';

  @override
  String get cartEmpty => 'Sebediňiz boş';

  @override
  String get cartTitle => 'Önümler';

  @override
  String get cartEmptyMessage =>
      'Heniz hiç zat goşmadyňyz. Harytlara göz aýlap, halanlaryňyzy tapyň.';

  @override
  String get cartEmptyAction => 'Söwda et';

  @override
  String cartProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count haryt',
      one: '1 haryt',
    );
    return '$_temp0';
  }

  @override
  String get commonCheckout => 'Sargyt et';

  @override
  String get commonTotal => 'Jemi';

  @override
  String get commonEmpty => 'Bu ýerde entek hiç zat ýok';

  @override
  String productReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teswir',
      one: '1 teswir',
    );
    return '$_temp0';
  }

  @override
  String productOrderCount(int count) {
    return '$count sargyt';
  }

  @override
  String productColor(String name) {
    return 'Reňk: $name';
  }

  @override
  String productSize(String size) {
    return 'Ýüzük ölçegi: $size';
  }

  @override
  String get productArticle => 'Haryt kody:';

  @override
  String get productPriceDetails => 'Baha barada';

  @override
  String get productPricePerItem => 'Bir harydyň bahasy';

  @override
  String get productRegularPrice => 'Adaty baha';

  @override
  String productDiscountPercent(int percent) {
    return '$percent% arzanladyş';
  }

  @override
  String get productCopy => 'Göçür';

  @override
  String get productCopied => 'Haryt kody göçürildi';

  @override
  String get productShared => 'Haryt salgysy göçürildi';

  @override
  String get productSharePrice => 'Bahasy';

  @override
  String get productSharePhoto => 'Harydyň suraty';

  @override
  String get productShareOpen => 'Elýeter programmasynda aç';

  @override
  String get productShareFailed =>
      'Paýlaşmak penjiresini açyp bolmady. Täzeden synanyşyň.';

  @override
  String get productDescription => 'Beýany';

  @override
  String get productReadMore => 'Dowamyny oka';

  @override
  String get productReadLess => 'Gysgalt';

  @override
  String get productCharacteristics => 'Häsiýetleri';

  @override
  String get productAllCharacteristics => 'Ähli häsiýetleri';

  @override
  String get productReviews => 'Teswirler';

  @override
  String get reviewEmpty => 'Entek teswir ýok';

  @override
  String get reviewWrite => 'Teswir ýaz';

  @override
  String get reviewEdit => 'Teswirimi üýtget';

  @override
  String get reviewDelete => 'Teswirimi poz';

  @override
  String get reviewRating => 'Siziň bahaňyz';

  @override
  String get reviewComment => 'Teswiriňiz (hökmany däl)';

  @override
  String get reviewIntro => 'Haryt baradaky pikiriňizi paýlaşyň.';

  @override
  String get reviewRatingPrompt => 'Baha bermek üçin ýyldyza basyň';

  @override
  String get reviewRatingPoor => 'Erbet';

  @override
  String get reviewRatingFair => 'Kanagatlanarly';

  @override
  String get reviewRatingGood => 'Gowy';

  @override
  String get reviewRatingVeryGood => 'Örän gowy';

  @override
  String get reviewRatingExcellent => 'Ajaýyp';

  @override
  String get reviewCommentHint =>
      'Näme göwnüňize ýarady? Nämäni gowulandyryp bolar?';

  @override
  String get reviewHowRate => 'Bu haryda nähili baha berýärsiňiz?';

  @override
  String get reviewSubmit => 'Teswiri iber';

  @override
  String get reviewAnonymous => 'Alyjy';

  @override
  String get reviewLoadMore => 'Ýene görkez';

  @override
  String get reviewLoadError => 'Teswirleri ýükläp bolmady.';

  @override
  String get reviewActionError => 'Teswiri üýtgedip bolmady.';

  @override
  String get reviewSaved => 'Teswir ýazdyryldy';

  @override
  String get reviewDeleted => 'Teswir pozuldy';

  @override
  String get reviewDeleteConfirm => 'Teswiriňiz pozulsynmy?';

  @override
  String get reviewDeleteMessage => 'Soňra täze teswir ýazyp bilersiňiz.';

  @override
  String get reviewHelpful => 'Peýdaly';

  @override
  String get reviewSortBy => 'Tertiplemek';

  @override
  String get reviewRatingFilter => 'Baha';

  @override
  String get reviewSortNewest => 'Täzeler ilki';

  @override
  String get reviewSortOldest => 'Köneler ilki';

  @override
  String get reviewSortMostLiked => 'Iň köp like';

  @override
  String get reviewSortMostDisliked => 'Iň köp dislike';

  @override
  String get reviewSortWithPhotos => 'Suratly';

  @override
  String get reviewSortWithoutPhotos => 'Suratsyz';

  @override
  String get reviewAllRatings => 'Ähli bahalar';

  @override
  String get reviewAddPhotos => 'Surat goş';

  @override
  String get reviewPhotoLimit => '5 suratdan köp däl';

  @override
  String get reviewPhotoUploadError => 'Surat ýüklenmedi.';

  @override
  String get reviewNoMatches => 'Bu süzgüçler boýunça syn ýok';

  @override
  String get reviewHiddenNotice => 'Synyňyz beýlekilerden gizlenen';

  @override
  String reviewHelpfulCount(int count) {
    return 'Peýdaly ($count)';
  }

  @override
  String productRatingCount(int count) {
    return '$count baha';
  }

  @override
  String get productReadAllReviews => 'Ähli teswirleri oka';

  @override
  String get orderActive => 'Işjeň sargyt';

  @override
  String get orderCompleted => 'Sargyt tamamlandy';

  @override
  String get orderCancelled => 'Sargyt ýatyryldy';

  @override
  String get orderStatusCancelled => 'Ýatyryldy';

  @override
  String get orderCancelTitle => 'Sargyt ýatyrylsynmy?';

  @override
  String get orderCancelMessage =>
      'Ýatyrylan sargyt dikeldilip bilinmeýär. Ony sebediňizden täzeden bermek bolar.';

  @override
  String get orderCancelKeep => 'Sargyt galsyn';

  @override
  String get orderCancelConfirm => 'Sargyt ýatyr';

  @override
  String get orderRepeatDone => 'Önümler sebede goşuldy';

  @override
  String get orderNotFound => 'Sargyt ýüklenip bilmedi';

  @override
  String get orderComment => 'Bellik';

  @override
  String get orderStatusNew => 'Jaň garaşylýar';

  @override
  String get orderStatusConfirmed => 'Tassyklandy';

  @override
  String get orderStatusOrdered => 'Sargyt edildi';

  @override
  String get orderStatusCompleted => 'Tamamlandy';

  @override
  String get orderReceiptTitle => 'Sargyt çegi';

  @override
  String get orderReceiptItems => 'Önümler';

  @override
  String get orderReceiptQty => 'Sany';

  @override
  String get orderReceiptPrice => 'Baha';

  @override
  String get orderReceiptAmount => 'Jemi';

  @override
  String get orderReceiptThanks => 'Sargydyňyz üçin sagboluň';

  @override
  String get orderReceiptFailed => 'Çek döredilip bilmedi';

  @override
  String get orderTrackRefresh => 'Her 15 sekuntdan täzelenýär';

  @override
  String get orderTrackNoPoint => 'Eltip bermek nokady görkezilmedi';

  @override
  String get orderTrackMapPoint => 'Kartadaky eltip bermek nokady';

  @override
  String get orderTrackNoCourier => 'Kurýeriň ýeri we gelmeli wagty heniz ýok.';

  @override
  String get orderTrackCancelled => 'Bu sargyt ýatyryldy.';

  @override
  String get orderHistory => 'Sargytlaryň taryhy';

  @override
  String get orderHistoryEmptyTitle => 'Heniz sargyt ýok';

  @override
  String get orderHistoryEmptyMessage =>
      'Sargyt bereniňizden soň, ol şu ýerde görüner.';

  @override
  String get activeOrdersEmptyTitle => 'Işjeň sargyt ýok';

  @override
  String get activeOrdersEmptyMessage =>
      'Dowam edýän sargytlaryňyz şu ýerde görüner.';

  @override
  String get orderStatusDelivered => 'Gowşuryldy';

  @override
  String orderItemsFor(int count, String amount) {
    return '$count haryt, $amount';
  }

  @override
  String orderItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count haryt',
      one: '1 haryt',
      zero: 'Haryt ýok',
    );
    return '$_temp0';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get onboardingWelcome => 'Hoş geldiňiz!';

  @override
  String get onboardingSubtitle =>
      'Hasabyňyza çalt we ygtybarly girip bilersiňiz.';

  @override
  String get onboardingStart => 'Başlamak';

  @override
  String get settingsLanguage => 'Dil';

  @override
  String get settingsLanguageDialogTitle => 'Dil çalyşmak';

  @override
  String get settingsLanguageDialogSubtitle =>
      'Ulanmak isleýän diliňizi saýlaň.';

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeLight => 'Açyk';

  @override
  String get settingsThemeDark => 'Garaňky';

  @override
  String get settingsThemeSystem => 'Ulgam';

  @override
  String get errorServer => 'Bir zat ýalňyş boldy. Gaýtadan synanyşyň.';

  @override
  String get errorNetwork => 'Internet birikmesi ýok.';

  @override
  String get errorTimeout => 'Haýyş juda uzaga çekdi.';

  @override
  String get errorUnauthorized => 'Dowam etmek üçin ulgama giriň.';

  @override
  String get errorNotFound => 'Gözlän zadyňyz tapylmady.';

  @override
  String get errorCache => 'Saklanan maglumat okalmady.';

  @override
  String get errorUnknown => 'Näbelli ýalňyşlyk.';

  @override
  String get profileEditProfile => 'Profili üýtget';

  @override
  String get profileAllOrders => 'Ähli sargytlar';

  @override
  String profileOrderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sargyt',
      one: '1 sargyt',
      zero: 'Sargyt ýok',
    );
    return '$_temp0';
  }

  @override
  String get profileSectionGeneral => 'Umumy';

  @override
  String get profileSectionOther => 'Beýleki';

  @override
  String get profileSectionContact => 'Biz bilen habarlaşyň';

  @override
  String get profileNotifications => 'Bildirişler';

  @override
  String get profileActiveOrders => 'Işjeň sargytlar';

  @override
  String get profileSavedLocations => 'Saklanan salgylarym';

  @override
  String get addressListTitle => 'Salgylar';

  @override
  String get addressAddWork => 'Iş salgysyny goş';

  @override
  String get addressAddHome => 'Öý salgysyny goş';

  @override
  String get addressAddNew => 'Täze salgy goş';

  @override
  String get addressNameWork => 'Iş';

  @override
  String get addressNameHome => 'Öý';

  @override
  String get addressEdit => 'Üýtget';

  @override
  String get addressMakeDefault => 'Esasy salgy et';

  @override
  String get addressDelete => 'Poz';

  @override
  String get addressMapLocation => 'Kartadaky salgy';

  @override
  String get addressMapHint => 'Köçe, jaý, şäher';

  @override
  String get addressApartmentFlat => 'Kwartira / öý';

  @override
  String get addressApartmentHint => 'mysal: 35/1';

  @override
  String get addressFloor => 'Gat';

  @override
  String get addressFloorHint => 'mysal: 3';

  @override
  String get addressNameLabel => 'Salgynyň ady';

  @override
  String get addressSaveButton => 'Salgyny sakla';

  @override
  String get addressResolving => 'Salgy gözlenýär…';

  @override
  String get addressTypeHome => 'Öý';

  @override
  String get addressTypeWork => 'Iş';

  @override
  String get addressTypeOther => 'Başga';

  @override
  String get addressPointRequired => 'Ilki kartadan bir nokat saýlaň.';

  @override
  String get addressNameRequired => 'Salgynyň adyny ýazyň.';

  @override
  String get addressLocationApproximate =>
      'Ýerleşiş takmynan. Belligi dogry ýere süýşüriň.';

  @override
  String get addressLocationFailed =>
      'Ýerleşişi alyp bolmady. Kartadan saýlaň.';

  @override
  String get addressLocationServiceOff =>
      'Ýerleşiş hyzmaty öçük. Sazlamalardan açyň ýa-da kartadan saýlaň.';

  @override
  String get addressLocationPermissionDenied =>
      'Ýerleşişe rugsat berilmedi. Sazlamalardan rugsat beriň ýa-da kartadan saýlaň.';

  @override
  String get addressOpenSettings => 'Sazlamalary aç';

  @override
  String get addressLookupFailed =>
      'Köçe salgysy tapylmady. Salgyny özüňiz ýazyň.';

  @override
  String get addressEmptyTitle => 'Heniz salgy saklanmady';

  @override
  String get addressEmptyMessage =>
      'Ilkinji eltip beriş salgyňyzy saklamak üçin + basyň.';

  @override
  String get addressDeleteDone => 'Salgy pozuldy.';

  @override
  String get profileOrderHistory => 'Sargytlaryň taryhy';

  @override
  String get profileAnnouncements => 'Habarlar';

  @override
  String get profileDarkMode => 'Garaňky tema';

  @override
  String get profileAboutApp => 'Programma barada';

  @override
  String get profileFaq => 'Sowal-jogap';

  @override
  String get profileTerms => 'Ulanyş şertleri';

  @override
  String get profilePrivacy => 'Gizlinlik syýasaty';

  @override
  String get staticPageEmpty => 'Mazmun taýýar bolanda şu ýerde görkeziler.';

  @override
  String get profileWhatsapp => 'WhatsApp';

  @override
  String get profileInstagram => 'Instagram';

  @override
  String get profileTiktok => 'TikTok';

  @override
  String get profileCallTitle => 'Ähli soraglar üçin jaň ediň:';

  @override
  String get profileCallAction => 'Jaň et';

  @override
  String get profileCallHours =>
      'Jaňlara jogap beriljek wagtlary: Hepde içi her gün sagat 09:00 - 19:00 aralygy';

  @override
  String profileVersion(String version) {
    return 'Wersiýa $version';
  }

  @override
  String get profileSignOut => 'Çykmak';

  @override
  String get profileSignOutTitle => 'Hasapdan çykmalymy?';

  @override
  String get profileSignOutMessage =>
      'Täzeden girmek üçin telefon belgiňiz gerek bolar.';

  @override
  String get profileGuestTitle => 'Hasabyňyza giriň';

  @override
  String get profileGuestMessage =>
      'Geýim, öý harytlary we başga-da köp zatlary sargyt ediň';

  @override
  String get profileGuestAction => 'Gir';

  @override
  String get authSignIn => 'Gir';

  @override
  String get authSignInRequiredTitle => 'Girmek talap edilýär';

  @override
  String get authSignInRequiredMessage =>
      'Bu bölümi ulanmak üçin ulgama giriň.';

  @override
  String get loginTitle => 'Ulgama giriş';

  @override
  String get loginPhoneTitle => 'Hasaba girmek';

  @override
  String get loginPhoneMessage =>
      'Telefon belgiňizi girizip, hasabyňyza çalt we ygtybarly girip bilersiňiz.';

  @override
  String get loginPhoneLabel => 'Telefon belgisi';

  @override
  String get loginPhoneHint => 'Telefon belgiňiz';

  @override
  String get loginSendCode => 'Dowam etmek';

  @override
  String get loginLegalNotice =>
      'Elyeter programmasyny ulanmak bilen, Ulanyş şertlerini we Gizlinlik syýasatyny kabul edýärsiňiz.';

  @override
  String get loginReadTerms => 'Şertleri okaň';

  @override
  String get loginCodeTitle => 'Tassyklamak';

  @override
  String loginCodeMessage(String phone) {
    return '$phone belgisine iberilen kody giriziň';
  }

  @override
  String get loginCodeLabel => 'Tassyklaýyş kody';

  @override
  String get loginVerify => 'Dowam et';

  @override
  String get loginResend => 'Kody täzeden ugrat';

  @override
  String loginResendCountdown(String time) {
    return 'Kody täzeden ugrat $time';
  }

  @override
  String loginResendIn(int seconds) {
    return '$seconds sekuntdan gaýtadan';
  }

  @override
  String get loginChangePhone => 'Belgini üýtget';

  @override
  String get loginSignedIn => 'Ulgama girdiňiz';

  @override
  String get settingsLanguageEnglish => 'Iňlisçe';

  @override
  String get settingsLanguageTurkmen => 'Türkmençe';

  @override
  String get settingsLanguageRussian => 'Rusça';

  @override
  String get editProfileTitle => 'Profili üýtget';

  @override
  String get editProfileName => 'Ady we familiýasy';

  @override
  String get editProfileNameHint => 'Adyňyz';

  @override
  String get editProfilePhone => 'Telefon belgisi';

  @override
  String get editProfilePhoneNote =>
      'Belgiňizi üýtgetmek üçin goldaw bilen habarlaşyň';

  @override
  String get editProfilePhoto => 'Suraty üýtget';

  @override
  String get editProfilePhotoCamera => 'Surat al';

  @override
  String get editProfilePhotoGallery => 'Galereýadan saýla';

  @override
  String get editProfilePhotoRemove => 'Suraty aýyr';

  @override
  String get editProfilePhotoTooLarge =>
      'Suraty 1 MB-dan kiçeldip bolmady. Başga surat saýlaň.';

  @override
  String get editProfileSaved => 'Profil täzelendi';

  @override
  String get editProfileNameRequired => 'Adyňyzy ýazyň';

  @override
  String get editProfilePhotoHint => 'Üýtgetmek üçin surata basyň';

  @override
  String editProfileNameCounter(int count) {
    return '$count/40';
  }

  @override
  String get editProfileNothingChanged => 'Ýatda saklamaga zat ýok';

  @override
  String get aboutTagline =>
      'Uly bazarlardaky ähli zat, Türkmenistana eltilýär.';

  @override
  String legalUpdated(String date) {
    return 'Soňky täzelenme: $date';
  }

  @override
  String get faqTitle => 'Sowal-jogap';

  @override
  String get faqQ1 => 'Sargydy nädip edýärin?';

  @override
  String get faqA1 =>
      'Islän harydyňyzy sebede goşuň, Sebet bölümini açyň we Sargyt et düwmesine basyň. Tassyklamazdan öň eltip bermek bilen bilelikde jemi görkeziler.';

  @override
  String get faqQ2 => 'Eltip bermek näçe wagt alýar?';

  @override
  String get faqA2 =>
      'Ýerli ammardaky harytlar 1–3 günde gelýär. Hyzmatdaş bazarlardan sargytlar satyja görä 10–20 gün alýar.';

  @override
  String get faqQ3 => 'Sargydymy nädip yzarlaýaryn?';

  @override
  String get faqA3 =>
      'Profil → Işjeň sargytlar bölümini açyň. Tassyklanandan eltilýänçä ähli ädim şol ýerde.';

  @override
  String get faqQ4 => 'Sargydy ýatyryp bilerinmi?';

  @override
  String get faqA4 =>
      'Hawa, entek \"Tassyklandy\" ýagdaýyndaka. Ugradylandan soň operatora jaň ediň, kömek ederis.';

  @override
  String get faqQ5 => 'Haryt yzyna nädip gaýtarylýar?';

  @override
  String get faqA5 =>
      'Eltilenden soň 3 günüň içinde operatora jaň ediň. Ulanylmadyk we asyl gaby bilen harytlar kabul edilýär.';

  @override
  String get termsTitle => 'Ulanyş şertleri';

  @override
  String get termsS1 => 'Programmany ulanmak';

  @override
  String get termsB1 =>
      'Elyeter-i ulanmak bilen bu şertleri kabul edýärsiňiz. Razy bolmasaňyz, programmany ulanmagy bes ediň.';

  @override
  String get termsS2 => 'Sargytlar we bahalar';

  @override
  String get termsB2 =>
      'Bahalar TMT-de görkezilýär we sargyt tassyklanýança üýtgäp biler. Hyzmatdaş bazarlardaky haryt gory biziň gözegçiligimizde däl.';

  @override
  String get termsS3 => 'Eltip bermek';

  @override
  String get termsB3 =>
      'Eltip bermek möhletleri çaklamadyr, kepillik däldir. Gümrük we satyjy gijikdirmeleri möhleti uzaldyp biler.';

  @override
  String get termsS4 => 'Yzyna gaýtarmak';

  @override
  String get termsB4 =>
      'Ulanylmadyk we asyl gabyndaky harytlar eltilenden soň 3 günüň içinde yzyna gaýtarylyp bilner. Sargyt boýunça ýasalan we şahsy ideg harytlary gaýtarylmaýar.';

  @override
  String get termsS5 => 'Hasabyňyz';

  @override
  String get termsB5 =>
      'Telefon belgiňiz hasabyňyzy kesgitleýär. Ony täze ýagdaýda saklaň — sargytlar we eltip bermek jaňlary şol belgä barýar.';

  @override
  String get privacyTitle => 'Gizlinlik syýasaty';

  @override
  String get privacyS1 => 'Näme ýygnaýarys';

  @override
  String get privacyB1 =>
      'Adyňyz, telefon belgiňiz, eltip bermek salgyňyz we sargyt taryhyňyz. Elyeter-i ulanmak üçin başga zat gerek däl.';

  @override
  String get privacyS2 => 'Näme üçin ulanýarys';

  @override
  String get privacyB2 =>
      'Sargytlaryňyzy eltmek, olar barada habar bermek we goldawa ýüz tutanyňyzda jogap bermek üçin.';

  @override
  String get privacyS3 => 'Kim bilen paýlaşýarys';

  @override
  String get privacyB3 =>
      'Diňe kurýerler we töleg hyzmatlary bilen, diňe sargydyňyzy tamamlamak üçin gerek bölegi. Maglumatlaryňyzy hiç haçan satmaýarys.';

  @override
  String get privacyS4 => 'Näçe wagt saklaýarys';

  @override
  String get privacyB4 =>
      'Hasabyňyz bar wagty, şeýle hem tamamlanan sargytlar üçin hasabat kadalarynyň talap edýän möhletinde.';

  @override
  String get privacyS5 => 'Hukuklaryňyz';

  @override
  String get privacyB5 =>
      'Maglumatlaryňyzyň nusgasyny almak ýa-da hasabyňyzy pozdurmak üçin operatora jaň ediň.';

  @override
  String get categoryTitle => 'Bölümler';

  @override
  String get errorOtpRateLimited => 'Täze kod soramazdan öň biraz garaşyň.';

  @override
  String get errorOtpInvalid => 'Kod nädogry.';

  @override
  String get errorOtpTooManyAttempts => 'Synanyşyk köp boldy. Täze kod soraň.';

  @override
  String get errorOtpExpired => 'Kodyň möhleti geçdi. Täzesini soraň.';

  @override
  String get errorUserBlocked => 'Bu hasap petiklendi.';

  @override
  String get errorVariantRequired => 'Sargyt etmezden öň görnüşi saýlaň.';

  @override
  String get errorItemsUnavailable => 'Käbir harytlar indi elýeterli däl.';

  @override
  String get errorPriceChanged =>
      'Jemi bahasy üýtgedi. Ýene bir gezek serediň.';

  @override
  String get errorSupplierUnavailable =>
      'Üpjün ediji jogap bermeýär. Birnäçe minutdan synanyşyň.';

  @override
  String get errorCannotCancel => 'Bu sargydy indi ýatyryp bolmaýar.';

  @override
  String get errorTooManyRequests => 'Haýyş köp iberildi. Biraz haýallaň.';

  @override
  String get errorValidation => 'Giren maglumatlaryňyzy barlaň.';

  @override
  String get profileDeleteAccount => 'Hasaby pozmak';

  @override
  String get profileDeleteTitle => 'Hasabyňyzy pozmalymy?';

  @override
  String get profileDeleteMessage =>
      'Bu hemişelik. Hasabyňyz we ondaky ähli zat Elyeter-den aýrylar, yzyna gaýtaryp bolmaýar.';

  @override
  String get profileDeleteLossOrders => 'Sargyt taryhyňyz';

  @override
  String get profileDeleteLossProfile =>
      'Adyňyz, suratyňyz we ýatda saklanan maglumatlaryňyz';

  @override
  String get profileDeleteLossAccess =>
      'Şu belgidäki hasaba girmek mümkinçiligi';

  @override
  String profileDeleteAccountOn(String phone) {
    return 'Hasap: $phone';
  }

  @override
  String get profileDeleteKeep => 'Hasabymy saklaýaryn';

  @override
  String get profileDeleteConfirm => 'Hemişelik poz';

  @override
  String get profileDeleteDone => 'Hasabyňyz pozuldy.';

  @override
  String get commonOk => 'Bolýar';

  @override
  String get errorPaymentBankFailed =>
      'Bank tölegi kabul etmedi. Soňrak synanyşyň ýa-da başga bank saýlaň.';

  @override
  String get errorPreOrderAlreadyPaid => 'Bu sargyt eýýäm tölenildi.';

  @override
  String get errorPreOrderNotPayable =>
      'Bu sargydy indi onlaýn tölemek bolmaýar.';

  @override
  String get errorBankNotFound =>
      'Bu bank häzir elýeterli däl. Başgasyny saýlaň.';

  @override
  String get errorProductRequestInvalidLink =>
      'Bu tekstde AliExpress haryt salgysy tapylmady.';

  @override
  String get paymentTitle => 'Töleg';

  @override
  String get paymentChooseBank => 'Bank saýlaň';

  @override
  String get paymentChooseBankHint =>
      'Kart maglumatlaryny bankyň sahypasynda girizersiňiz.';

  @override
  String get paymentNoBanks => 'Onlaýn töleg häzir elýeterli däl.';

  @override
  String get paymentPayOnlineTitle => 'Onlaýn töle';

  @override
  String get paymentPayOnlineMessage =>
      'Sargydy häzir kart bilen töläň — jaňa garaşmagyň zerurlygy ýok.';

  @override
  String get paymentPay => 'Töle';

  @override
  String get paymentPaid => 'Onlaýn tölenildi';

  @override
  String get paymentChecking => 'Töleg barlanýar…';

  @override
  String get paymentCheckingMessage => 'Bu birnäçe sekunt alar.';

  @override
  String get paymentSuccess => 'Töleg üstünlikli geçdi';

  @override
  String get paymentSuccessMessage => 'Sargydyňyz tölenildi. Sag boluň!';

  @override
  String get paymentFailed => 'Töleg geçmedi';

  @override
  String get paymentFailedMessage =>
      'Bank tölegi ret etdi. Gaýtadan synanyşyň ýa-da başga bank saýlaň.';

  @override
  String get paymentPending => 'Töleg barlanýar';

  @override
  String get paymentPendingMessage =>
      'Bank tölegi entek tassyklamady. Tassyklan badyna sargyt tölenen diýlip bellener.';

  @override
  String get paymentNotCompletedMessage =>
      'Töleg tamamlanmady. Eger kartyňyzdan pul alnan bolsa, sargyt birnäçe minudyň dowamynda tölenen diýlip bellener.';

  @override
  String get paymentTryAgain => 'Gaýtadan synanyş';

  @override
  String get productRequestTitle => 'Bize salgy iberiň';

  @override
  String get productRequestMessage =>
      'Haryt tapmadyňyzmy? AliExpress salgysyny goýuň, biz ony kataloga goşarys.';

  @override
  String get productRequestHint => 'AliExpress salgysy ýa-da paýlaşmak teksti';

  @override
  String get productRequestPaste => 'Goý';

  @override
  String get productRequestSend => 'Salgyny iber';

  @override
  String get productRequestSendAnother => 'Başga salgy iber';

  @override
  String get productRequestMine => 'Haryt haýyşlarym';

  @override
  String get productRequestSearchAction => 'Haryt salgysyny iber';

  @override
  String get productRequestLoadingTitle => 'Haryt ýüklenýär…';

  @override
  String get productRequestLoadingMessage =>
      'Bu adatça bir minuda çenli wagt alýar.';

  @override
  String get productRequestLaterTitle => 'Size habar bereris';

  @override
  String get productRequestLaterMessage =>
      'Bu birneme köp wagt alýar. Haryt elýeterli bolanda size bildiriş ibereris.';

  @override
  String get productRequestReviewTitle => 'Barlagda';

  @override
  String get productRequestReviewMessage =>
      'Haryt barlanýar. Elýeterli bolanda size habar bereris.';

  @override
  String get productRequestRejectedTitle => 'Elýeterli däl';

  @override
  String get productRequestRejectedMessage =>
      'Bagyşlaň, bu harydy satyp bilmeýäris.';

  @override
  String get productRequestFailedTitle => 'Ýüklenip bilmedi';

  @override
  String get productRequestFailedMessage =>
      'Haryt AliExpress-den ýüklenip bilmedi. Ol satuwdan aýrylan bolmagy mümkin.';

  @override
  String get productRequestAvailableTitle => 'Haryt goşuldy';

  @override
  String get productRequestAvailableMessage =>
      'Haryt katalogda. Ony «Haryt haýyşlarym» bölüminde tapyň.';

  @override
  String get productRequestStatusProcessing => 'Ýüklenýär';

  @override
  String get productRequestStatusInReview => 'Barlagda';

  @override
  String get productRequestStatusAvailable => 'Elýeterli';

  @override
  String get productRequestStatusRejected => 'Ret edildi';

  @override
  String get productRequestStatusFailed => 'Ýüklenmedi';

  @override
  String get productRequestEmptyTitle => 'Heniz haýyş ýok';

  @override
  String get errorImageSearchInvalidImage =>
      'JPEG, PNG ýa-da WebP surat ulanyň.';

  @override
  String get errorImageSearchInProgress =>
      'Öňki gözleg heniz ugradylýar. Garaşyň.';

  @override
  String get errorImageSearchUnavailable =>
      'Gözleg wagtlaýyn elýeterli däl. Soňrak synanşyň.';

  @override
  String get imageSearchTitle => 'Surat boýunça gözleg';

  @override
  String get imageSearchSearching => 'Ýene gözleýäris…';

  @override
  String get imageSearchEmpty => 'Entek meňzeş zat ýok';

  @override
  String imageSearchRateLimited(int minutes) {
    return 'Gözleg çägi doldy. $minutes min soň synanşyň.';
  }

  @override
  String imageSearchInReview(int count) {
    return 'Suratyňyz işlenildi. Ýene $count haryt moderator tarapyndan barlanýar — habarnama ugradarys.';
  }

  @override
  String get imageSearchFailed => 'AliExpress-den harytlary ýükläp bolmady.';
}
