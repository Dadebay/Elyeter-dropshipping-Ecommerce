// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Elyeter';

  @override
  String get navHome => 'Главная';

  @override
  String get navCategory => 'Категории';

  @override
  String get navCart => 'Корзина';

  @override
  String get navFavorite => 'Избранное';

  @override
  String get favoriteTitle => 'Избранное';

  @override
  String get favoriteEmptyTitle => 'Пока нет избранного';

  @override
  String get favoriteEmptyMessage =>
      'Сохраняйте понравившиеся товары, чтобы быстро находить их здесь.';

  @override
  String get favoriteEmptyAction => 'Смотреть';

  @override
  String get navProfile => 'Профиль';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get notificationsEmptyTitle => 'Пока нет уведомлений';

  @override
  String get notificationsEmptyMessage => 'Новые уведомления появятся здесь.';

  @override
  String get notificationsOverviewTitle => 'Новости от Elyeter';

  @override
  String get notificationsOverviewMessage =>
      'Предложения и важные новости в одном месте.';

  @override
  String get notificationsToday => 'Сегодня';

  @override
  String get notificationsYesterday => 'Вчера';

  @override
  String get notificationsEarlier => 'Ранее';

  @override
  String get notificationsNew => 'Новое';

  @override
  String get notificationsLoadMore => 'Загрузить ещё';

  @override
  String get notificationsRefresh => 'Обновить';

  @override
  String get announcementsEmptyTitle => 'Пока нет объявлений';

  @override
  String get announcementsEmptyMessage => 'Новые объявления появятся здесь.';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonSearch => 'Поиск';

  @override
  String get homeSearchHint => 'Поиск товара';

  @override
  String get locationTitle => 'Адрес доставки';

  @override
  String get locationSearchHint => 'Поиск района или улицы';

  @override
  String get locationEmpty => 'Совпадений не найдено';

  @override
  String get visualSearchTitle => 'Поиск по фото';

  @override
  String get visualSearchHint => 'Поместите товар в рамку для сканирования';

  @override
  String get visualSearchCamera => 'Сделать фото';

  @override
  String get visualSearchRetake => 'Переснять';

  @override
  String get visualSearchUse => 'Использовать';

  @override
  String get visualSearchGallery => 'Выбрать из галереи';

  @override
  String get visualSearchNoCamera => 'На этом устройстве нет камеры.';

  @override
  String get visualSearchDenied =>
      'Для поиска по фото нужен доступ к камере. Разрешите его в настройках.';

  @override
  String get visualSearchReady => 'Фото готово — поиск по фото скоро.';

  @override
  String commonOpenFailed(String target) {
    return 'Не удалось открыть $target';
  }

  @override
  String get orderActiveTitle => 'Активный заказ';

  @override
  String orderNumber(String number) {
    return 'Заказ № $number';
  }

  @override
  String get orderRepeat => 'Повторить заказ';

  @override
  String get orderQuestions => 'Вопросы';

  @override
  String get orderCancel => 'Отменить';

  @override
  String get orderProgress => 'Ход доставки';

  @override
  String get orderStepPlaced => 'Заказ оформлен';

  @override
  String get orderStepWarehouse => 'Поступил на склад в Китае';

  @override
  String get orderStepShipped => 'Отправлен в Туркменистан';

  @override
  String get orderStepArrived => 'Прибыл в Туркменистан';

  @override
  String get orderStepDelivered => 'Доставлен';

  @override
  String get orderStepStopped => 'Остановлено';

  @override
  String get orderProducts => 'Товары в доставке';

  @override
  String orderItemSummary(int count, String total) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count товаров на $total',
      few: '$count товара на $total',
      one: '$count товар на $total',
    );
    return '$_temp0';
  }

  @override
  String get orderPickupPoint => 'Пункт выдачи';

  @override
  String get orderSelectAddressTitle => 'Выберите адрес';

  @override
  String get orderSelectAddressMessage =>
      'Выберите или добавьте адрес перед оформлением заказа.';

  @override
  String get orderAddressLoadFailed =>
      'Не удалось загрузить адреса. Повторите попытку.';

  @override
  String get orderRecipient => 'Получатель';

  @override
  String get orderTime => 'Время заказа';

  @override
  String get orderPayment => 'Способ оплаты';

  @override
  String get orderPaymentCard => 'Картой / Оплата картой';

  @override
  String get orderTotalTitle => 'Сумма заказа';

  @override
  String get orderProductsTotal => 'Сумма товаров';

  @override
  String get orderDeliveryLabel => 'Доставка';

  @override
  String get orderDeliveryFree => 'Бесплатно';

  @override
  String get orderCargo => 'Карго';

  @override
  String get orderDiscount => 'Скидка';

  @override
  String get orderDownloadCheck => 'Скачать чек';

  @override
  String get orderCargoNote =>
      'Примечание: стоимость карго рассчитывается после прибытия товара.';

  @override
  String get categoryFilterMaterial => 'Материал';

  @override
  String get categoryFilterColor => 'Цвет';

  @override
  String get categoryFilterBrand => 'Бренд';

  @override
  String get categorySearch => 'Поиск';

  @override
  String get categoryFilters => 'Фильтры';

  @override
  String get categoryOnlyFeatured => 'Только рекомендуемые товары';

  @override
  String get categorySortTitle => 'Сортировка';

  @override
  String get categorySortNewest => 'Сначала новые';

  @override
  String get categorySortPopular => 'Популярные';

  @override
  String get categoryPriceMin => 'Минимальная цена';

  @override
  String get categoryPriceRange => 'Диапазон цен';

  @override
  String get categoryPriceMax => 'Максимальная цена';

  @override
  String get categorySortPriceAsc => 'Цена: по возрастанию';

  @override
  String get categorySortPriceDesc => 'Цена: по убыванию';

  @override
  String get categorySortDiscount => 'Больше скидка';

  @override
  String get categoryApply => 'Применить';

  @override
  String get categoryReset => 'Сбросить';

  @override
  String get categoryNoResults => 'Ничего не найдено по этим фильтрам';

  @override
  String get categoryProductsEmptyTitle => 'Пока нет товаров';

  @override
  String get categoryProductsEmptyMessage =>
      'В этой категории пока нет товаров. Посмотрите другие категории.';

  @override
  String get categoryNoResultsHint => 'Попробуйте убрать один из них.';

  @override
  String categoryFacetSearch(String facet) {
    return 'Поиск: $facet';
  }

  @override
  String categorySelectedCount(int count) {
    return 'Выбрано: $count';
  }

  @override
  String get searchTitle => 'Поиск';

  @override
  String get searchClear => 'Очистить поиск';

  @override
  String get searchNotFoundTitle => 'Ничего не найдено';

  @override
  String get searchNotFoundMessage =>
      'Проверьте правильность написания или попробуйте другие ключевые слова.';

  @override
  String get searchErrorTitle => 'Ошибка';

  @override
  String get searchErrorMessage => 'Произошла ошибка. Попробуйте ещё раз.';

  @override
  String get searchConnectionErrorTitle => 'Ошибка подключения';

  @override
  String get searchConnectionErrorMessage =>
      'Не удалось подключиться к серверу. Проверьте интернет-соединение и повторите попытку.';

  @override
  String get commonSeeAll => 'Все';

  @override
  String get commonAddToCart => 'В корзину';

  @override
  String get commonAdded => 'Добавлено';

  @override
  String get cartDelete => 'Удалить';

  @override
  String get cartSelectAll => 'Выбрать все';

  @override
  String get cartEmpty => 'Корзина пуста';

  @override
  String get cartTitle => 'Товары';

  @override
  String get cartEmptyMessage =>
      'Вы ещё ничего не добавили. Посмотрите товары и найдите то, что понравится.';

  @override
  String get cartEmptyAction => 'К покупкам';

  @override
  String cartProductCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count товара',
      one: '1 товар',
    );
    return '$_temp0';
  }

  @override
  String get commonCheckout => 'Оформить';

  @override
  String get commonTotal => 'Итого';

  @override
  String get commonEmpty => 'Здесь пока пусто';

  @override
  String productReviewCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count отзывов',
      one: '1 отзыв',
    );
    return '$_temp0';
  }

  @override
  String productOrderCount(int count) {
    return '$count заказов';
  }

  @override
  String productColor(String name) {
    return 'Цвет: $name';
  }

  @override
  String productSize(String size) {
    return 'Размер: $size';
  }

  @override
  String get productArticle => 'Артикул:';

  @override
  String get productPriceDetails => 'Детали цены';

  @override
  String get productPricePerItem => 'Цена за штуку';

  @override
  String get productRegularPrice => 'Обычная цена';

  @override
  String productDiscountPercent(int percent) {
    return 'Скидка $percent%';
  }

  @override
  String get productCopy => 'Копировать';

  @override
  String get productCopied => 'Артикул скопирован';

  @override
  String get productShared => 'Ссылка на товар скопирована';

  @override
  String get productSharePrice => 'Цена';

  @override
  String get productSharePhoto => 'Фото товара';

  @override
  String get productShareOpen => 'Открыть в приложении Elýeter';

  @override
  String get productShareFailed =>
      'Не удалось открыть меню отправки. Попробуйте ещё раз.';

  @override
  String get productDescription => 'Описание';

  @override
  String get productReadMore => 'Читать далее';

  @override
  String get productReadLess => 'Свернуть';

  @override
  String get productCharacteristics => 'Характеристики';

  @override
  String get productAllCharacteristics => 'Все характеристики';

  @override
  String get productReviews => 'Отзывы';

  @override
  String get reviewEmpty => 'Пока нет отзывов';

  @override
  String get reviewWrite => 'Написать отзыв';

  @override
  String get reviewEdit => 'Изменить мой отзыв';

  @override
  String get reviewDelete => 'Удалить мой отзыв';

  @override
  String get reviewRating => 'Ваша оценка';

  @override
  String get reviewComment => 'Напишите, что вы думаете о товаре...';

  @override
  String get reviewIntro => 'Поделитесь впечатлениями о товаре.';

  @override
  String get reviewRatingPrompt => 'Нажмите на звезду, чтобы оценить';

  @override
  String get reviewRatingPoor => 'Плохо';

  @override
  String get reviewRatingFair => 'Так себе';

  @override
  String get reviewRatingGood => 'Хорошо';

  @override
  String get reviewRatingVeryGood => 'Очень хорошо';

  @override
  String get reviewRatingExcellent => 'Отлично';

  @override
  String get reviewCommentHint => 'Что понравилось? Что можно улучшить?';

  @override
  String get reviewHowRate => 'Как бы вы оценили этот товар?';

  @override
  String get reviewSubmit => 'Отправить';

  @override
  String get reviewAnonymous => 'Покупатель';

  @override
  String get reviewLoadMore => 'Загрузить ещё';

  @override
  String get reviewLoadError => 'Не удалось загрузить отзывы.';

  @override
  String get reviewActionError => 'Не удалось изменить отзыв.';

  @override
  String get reviewSaved => 'Отзыв сохранён';

  @override
  String get reviewDeleted => 'Отзыв удалён';

  @override
  String get reviewDeleteConfirm => 'Удалить ваш отзыв?';

  @override
  String get reviewDeleteMessage => 'Позже вы сможете написать новый отзыв.';

  @override
  String get reviewHelpful => 'Полезно';

  @override
  String get reviewSortBy => 'Сортировка';

  @override
  String get reviewRatingFilter => 'Оценка';

  @override
  String get reviewSortNewest => 'Сначала новые';

  @override
  String get reviewSortOldest => 'Сначала старые';

  @override
  String get reviewSortMostLiked => 'Больше лайков';

  @override
  String get reviewSortMostDisliked => 'Больше дизлайков';

  @override
  String get reviewSortWithPhotos => 'С фото';

  @override
  String get reviewSortWithoutPhotos => 'Без фото';

  @override
  String get reviewAllRatings => 'Все оценки';

  @override
  String get reviewAddPhotos => 'Добавить фото';

  @override
  String get reviewPhotoLimit => 'До 5 фото';

  @override
  String get reviewPhotoUploadError => 'Не удалось загрузить фото.';

  @override
  String get reviewNoMatches => 'Нет отзывов по этим фильтрам';

  @override
  String get reviewHiddenNotice => 'Ваш отзыв скрыт от других';

  @override
  String reviewHelpfulCount(int count) {
    return 'Полезно ($count)';
  }

  @override
  String productRatingCount(int count) {
    return '$count оценок';
  }

  @override
  String get productReadAllReviews => 'Читать все отзывы';

  @override
  String get orderActive => 'Активный заказ';

  @override
  String get orderCompleted => 'Заказ выполнен';

  @override
  String get orderCancelled => 'Заказ отменён';

  @override
  String get orderStatusCancelled => 'Отменён';

  @override
  String get orderCancelTitle => 'Отменить заказ?';

  @override
  String get orderCancelMessage =>
      'Отменённый заказ нельзя восстановить. Вы можете оформить его заново из корзины.';

  @override
  String get orderCancelKeep => 'Оставить заказ';

  @override
  String get orderCancelConfirm => 'Отменить заказ';

  @override
  String get orderRepeatDone => 'Товары добавлены в корзину';

  @override
  String get orderNotFound => 'Не удалось загрузить заказ';

  @override
  String get orderComment => 'Комментарий';

  @override
  String get orderStatusNew => 'Ожидает звонка';

  @override
  String get orderStatusConfirmed => 'Подтверждён';

  @override
  String get orderStatusOrdered => 'Заказан';

  @override
  String get orderStatusCompleted => 'Завершён';

  @override
  String get orderReceiptTitle => 'Чек заказа';

  @override
  String get orderReceiptItems => 'Товары';

  @override
  String get orderReceiptQty => 'Кол-во';

  @override
  String get orderReceiptPrice => 'Цена';

  @override
  String get orderReceiptAmount => 'Сумма';

  @override
  String get orderReceiptThanks => 'Спасибо за заказ';

  @override
  String get orderReceiptFailed => 'Не удалось создать чек';

  @override
  String get orderTrackRefresh => 'Обновляется каждые 15 секунд';

  @override
  String get orderTrackNoPoint => 'Точка доставки не указана';

  @override
  String get orderTrackMapPoint => 'Точка доставки на карте';

  @override
  String get orderTrackNoCourier =>
      'Положение курьера и время прибытия пока недоступны.';

  @override
  String get orderTrackCancelled => 'Этот заказ был отменён.';

  @override
  String get orderHistory => 'История заказов';

  @override
  String get orderHistoryEmptyTitle => 'Заказов пока нет';

  @override
  String get orderHistoryEmptyMessage =>
      'После оформления заказа он появится здесь.';

  @override
  String get activeOrdersEmptyTitle => 'Нет активных заказов';

  @override
  String get activeOrdersEmptyMessage =>
      'Здесь появятся заказы в процессе выполнения.';

  @override
  String get orderStatusDelivered => 'Доставлен';

  @override
  String orderItemsFor(int count, String amount) {
    return '$count шт. на сумму $amount';
  }

  @override
  String orderItemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count товаров',
      few: '$count товара',
      one: '$count товар',
      zero: 'Нет товаров',
    );
    return '$_temp0';
  }

  @override
  String get profileTitle => 'Профиль';

  @override
  String get onboardingWelcome => 'Добро пожаловать!';

  @override
  String get onboardingSubtitle =>
      'Вы можете быстро и безопасно войти в свой аккаунт.';

  @override
  String get onboardingStart => 'Начать';

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageDialogTitle => 'Выбрать язык';

  @override
  String get settingsLanguageDialogSubtitle =>
      'Выберите язык, который хотите использовать.';

  @override
  String get settingsTheme => 'Тема';

  @override
  String get settingsThemeLight => 'Светлая';

  @override
  String get settingsThemeDark => 'Тёмная';

  @override
  String get settingsThemeSystem => 'Системная';

  @override
  String get errorServer => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get errorNetwork => 'Нет подключения к интернету.';

  @override
  String get errorTimeout => 'Запрос занял слишком много времени.';

  @override
  String get errorUnauthorized => 'Войдите, чтобы продолжить.';

  @override
  String get errorNotFound => 'Ничего не найдено.';

  @override
  String get errorCache => 'Не удалось прочитать сохранённые данные.';

  @override
  String get errorUnknown => 'Неизвестная ошибка.';

  @override
  String get profileEditProfile => 'Изменить профиль';

  @override
  String get profileAllOrders => 'Все заказы';

  @override
  String profileOrderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count заказов',
      few: '$count заказа',
      one: '$count заказ',
      zero: 'Нет заказов',
    );
    return '$_temp0';
  }

  @override
  String get profileSectionGeneral => 'Основное';

  @override
  String get profileSectionOther => 'Другое';

  @override
  String get profileSectionContact => 'Связаться с нами';

  @override
  String get profileNotifications => 'Уведомления';

  @override
  String get profileActiveOrders => 'Активные заказы';

  @override
  String get profileSavedLocations => 'Мои адреса';

  @override
  String get addressListTitle => 'Адреса';

  @override
  String get addressAddWork => 'Добавить рабочий адрес';

  @override
  String get addressAddHome => 'Добавить домашний адрес';

  @override
  String get addressAddNew => 'Добавить новый адрес';

  @override
  String get addressNameWork => 'Работа';

  @override
  String get addressNameHome => 'Дом';

  @override
  String get addressEdit => 'Изменить';

  @override
  String get addressMakeDefault => 'Сделать основным';

  @override
  String get addressDelete => 'Удалить';

  @override
  String get addressMapLocation => 'Адрес на карте';

  @override
  String get addressMapHint => 'Улица, дом, город';

  @override
  String get addressApartmentFlat => 'Квартира';

  @override
  String get addressApartmentHint => 'напр. 35/1';

  @override
  String get addressFloor => 'Этаж';

  @override
  String get addressFloorHint => 'напр. 3';

  @override
  String get addressNameLabel => 'Название адреса';

  @override
  String get addressSaveButton => 'Сохранить адрес';

  @override
  String get addressResolving => 'Ищем адрес…';

  @override
  String get addressTypeHome => 'Дом';

  @override
  String get addressTypeWork => 'Работа';

  @override
  String get addressTypeOther => 'Другое';

  @override
  String get addressPointRequired => 'Сначала выберите точку на карте.';

  @override
  String get addressNameRequired => 'Введите название адреса.';

  @override
  String get addressLocationApproximate =>
      'Местоположение приблизительное. Переместите метку в нужную точку.';

  @override
  String get addressLocationFailed =>
      'Не удалось определить местоположение. Выберите точку на карте.';

  @override
  String get addressLocationServiceOff =>
      'Геолокация отключена. Включите её в настройках или выберите точку на карте.';

  @override
  String get addressLocationPermissionDenied =>
      'Доступ к геолокации не разрешён. Разрешите его в настройках или выберите точку на карте.';

  @override
  String get addressOpenSettings => 'Открыть настройки';

  @override
  String get addressLookupFailed =>
      'Адрес улицы не найден. Введите адрес вручную.';

  @override
  String get addressEmptyTitle => 'Пока нет сохранённых адресов';

  @override
  String get addressEmptyMessage =>
      'Нажмите +, чтобы сохранить первый адрес доставки.';

  @override
  String get addressDeleteDone => 'Адрес удалён.';

  @override
  String get profileOrderHistory => 'История заказов';

  @override
  String get profileAnnouncements => 'Объявления';

  @override
  String get profileDarkMode => 'Тёмная тема';

  @override
  String get profileAboutApp => 'О приложении';

  @override
  String get profileFaq => 'Вопросы и ответы';

  @override
  String get profileTerms => 'Условия использования';

  @override
  String get profilePrivacy => 'Политика конфиденциальности';

  @override
  String get staticPageEmpty =>
      'Содержимое появится здесь, когда будет доступно.';

  @override
  String get profileWhatsapp => 'WhatsApp';

  @override
  String get profileInstagram => 'Instagram';

  @override
  String get profileTiktok => 'TikTok';

  @override
  String get profileCallTitle => 'Звоните по любым вопросам:';

  @override
  String get profileCallAction => 'Позвонить';

  @override
  String get profileCallHours =>
      'Звонки принимаем каждый день недели, 09:00 - 19:00';

  @override
  String profileVersion(String version) {
    return 'Версия $version';
  }

  @override
  String get profileSignOut => 'Выйти';

  @override
  String get profileSignOutTitle => 'Выйти из аккаунта?';

  @override
  String get profileSignOutMessage =>
      'Чтобы войти снова, понадобится номер телефона.';

  @override
  String get profileGuestTitle => 'Войдите в аккаунт';

  @override
  String get profileGuestMessage =>
      'Одежда, товары для дома и многое другое для заказа';

  @override
  String get profileGuestAction => 'Войти';

  @override
  String get authSignIn => 'Войти';

  @override
  String get authSignInRequiredTitle => 'Требуется вход';

  @override
  String get authSignInRequiredMessage =>
      'Войдите, чтобы пользоваться этим разделом.';

  @override
  String get loginTitle => 'Вход';

  @override
  String get loginPhoneTitle => 'Войти в аккаунт';

  @override
  String get loginPhoneMessage =>
      'Введите номер телефона, чтобы быстро и безопасно войти в аккаунт.';

  @override
  String get loginPhoneLabel => 'Номер телефона';

  @override
  String get loginPhoneHint => 'Ваш номер телефона';

  @override
  String get loginSendCode => 'Продолжить';

  @override
  String get loginLegalNotice =>
      'Используя Elyeter, вы соглашаетесь с Условиями использования и Политикой конфиденциальности.';

  @override
  String get loginReadTerms => 'Читать условия';

  @override
  String get loginCodeTitle => 'Подтверждение';

  @override
  String loginCodeMessage(String phone) {
    return 'Введите код, отправленный на $phone';
  }

  @override
  String get loginCodeLabel => 'Код подтверждения';

  @override
  String get loginVerify => 'Продолжить';

  @override
  String get loginResend => 'Отправить код ещё раз';

  @override
  String loginResendCountdown(String time) {
    return 'Отправить код снова $time';
  }

  @override
  String loginResendIn(int seconds) {
    return 'Повторно через $seconds с';
  }

  @override
  String get loginChangePhone => 'Изменить номер';

  @override
  String get loginSignedIn => 'Вы вошли в аккаунт';

  @override
  String get settingsLanguageEnglish => 'Английский';

  @override
  String get settingsLanguageTurkmen => 'Туркменский';

  @override
  String get settingsLanguageRussian => 'Русский';

  @override
  String get editProfileTitle => 'Изменить профиль';

  @override
  String get editProfileName => 'Имя и фамилия';

  @override
  String get editProfileNameHint => 'Ваше имя';

  @override
  String get editProfilePhone => 'Номер телефона';

  @override
  String get editProfilePhoneNote =>
      'Чтобы изменить номер, обратитесь в поддержку';

  @override
  String get editProfilePhoto => 'Изменить фото';

  @override
  String get editProfilePhotoCamera => 'Сделать фото';

  @override
  String get editProfilePhotoGallery => 'Выбрать из галереи';

  @override
  String get editProfilePhotoRemove => 'Удалить фото';

  @override
  String get editProfilePhotoTooLarge =>
      'Не удалось уменьшить фото до 1 МБ. Выберите другое фото.';

  @override
  String get editProfileSaved => 'Профиль обновлён';

  @override
  String get editProfileNameRequired => 'Введите ваше имя';

  @override
  String get editProfilePhotoHint => 'Нажмите на фото, чтобы изменить';

  @override
  String editProfileNameCounter(int count) {
    return '$count/40';
  }

  @override
  String get editProfileNothingChanged => 'Пока нечего сохранять';

  @override
  String get aboutTagline =>
      'Всё с крупных маркетплейсов — с доставкой по Туркменистану.';

  @override
  String legalUpdated(String date) {
    return 'Обновлено: $date';
  }

  @override
  String get faqTitle => 'Вопросы и ответы';

  @override
  String get faqQ1 => 'Как оформить заказ?';

  @override
  String get faqA1 =>
      'Добавьте товары в корзину, откройте вкладку «Корзина» и нажмите «Оформить». Итог с доставкой показан до подтверждения.';

  @override
  String get faqQ2 => 'Сколько идёт доставка?';

  @override
  String get faqA2 =>
      'Товары со склада приходят за 1–3 дня. Заказы с партнёрских площадок — 10–20 дней, в зависимости от продавца.';

  @override
  String get faqQ3 => 'Как отследить заказ?';

  @override
  String get faqA3 =>
      'Откройте Профиль → Активные заказы. Там виден каждый этап от подтверждения до доставки.';

  @override
  String get faqQ4 => 'Можно ли отменить заказ?';

  @override
  String get faqA4 =>
      'Да, пока он в статусе «Подтверждён». После отправки позвоните оператору — поможем.';

  @override
  String get faqQ5 => 'Как вернуть товар?';

  @override
  String get faqA5 =>
      'Позвоните оператору в течение 3 дней после доставки. Принимаем неиспользованный товар в оригинальной упаковке.';

  @override
  String get termsTitle => 'Условия использования';

  @override
  String get termsS1 => 'Использование приложения';

  @override
  String get termsB1 =>
      'Пользуясь Elyeter, вы принимаете эти условия. Если вы не согласны, прекратите использование приложения.';

  @override
  String get termsS2 => 'Заказы и цены';

  @override
  String get termsB2 =>
      'Цены указаны в TMT и могут измениться до подтверждения заказа. Наличие на партнёрских площадках от нас не зависит.';

  @override
  String get termsS3 => 'Доставка';

  @override
  String get termsB3 =>
      'Сроки доставки — ориентир, а не гарантия. Таможня и задержки продавца могут их увеличить.';

  @override
  String get termsS4 => 'Возврат';

  @override
  String get termsB4 =>
      'Неиспользованный товар в оригинальной упаковке можно вернуть в течение 3 дней. Товары под заказ и средства личной гигиены возврату не подлежат.';

  @override
  String get termsS5 => 'Ваш аккаунт';

  @override
  String get termsB5 =>
      'Ваш номер телефона — идентификатор аккаунта. Держите его актуальным: заказы и звонки курьера идут на него.';

  @override
  String get privacyTitle => 'Политика конфиденциальности';

  @override
  String get privacyS1 => 'Какие данные мы собираем';

  @override
  String get privacyB1 =>
      'Имя, номер телефона, адрес доставки и историю заказов. Больше ничего для работы Elyeter не нужно.';

  @override
  String get privacyS2 => 'Зачем мы их используем';

  @override
  String get privacyB2 =>
      'Чтобы доставлять заказы, сообщать об их статусе и отвечать вам в поддержке.';

  @override
  String get privacyS3 => 'Кому мы их передаём';

  @override
  String get privacyB3 =>
      'Только курьерам и платёжным сервисам — и только то, что нужно для выполнения заказа. Мы не продаём ваши данные.';

  @override
  String get privacyS4 => 'Сколько мы их храним';

  @override
  String get privacyB4 =>
      'Пока существует ваш аккаунт, плюс срок, требуемый правилами учёта для завершённых заказов.';

  @override
  String get privacyS5 => 'Ваши права';

  @override
  String get privacyB5 =>
      'Позвоните оператору, чтобы получить копию данных или удалить аккаунт.';

  @override
  String get categoryTitle => 'Категории';

  @override
  String get errorOtpRateLimited =>
      'Подождите, прежде чем запрашивать новый код.';

  @override
  String get errorOtpInvalid => 'Неверный код.';

  @override
  String get errorOtpTooManyAttempts =>
      'Слишком много попыток. Запросите новый код.';

  @override
  String get errorOtpExpired => 'Срок действия кода истёк. Запросите новый.';

  @override
  String get errorUserBlocked => 'Этот аккаунт заблокирован.';

  @override
  String get errorVariantRequired => 'Выберите вариант перед заказом.';

  @override
  String get errorItemsUnavailable => 'Некоторых товаров больше нет в наличии.';

  @override
  String get errorPriceChanged => 'Сумма изменилась. Проверьте её ещё раз.';

  @override
  String get errorSupplierUnavailable =>
      'Поставщик не отвечает. Попробуйте через пару минут.';

  @override
  String get errorCannotCancel => 'Этот заказ уже нельзя отменить.';

  @override
  String get errorTooManyRequests => 'Слишком много запросов. Повторите позже.';

  @override
  String get errorPreOrderInProgress =>
      'Заказ ещё оформляется. Подождите немного.';

  @override
  String get errorPaymentInProgress =>
      'Оплата ещё проверяется — попробуйте через пару минут.';

  @override
  String get errorValidation => 'Проверьте введённые данные.';

  @override
  String get profileDeleteAccount => 'Удалить аккаунт';

  @override
  String get profileDeleteTitle => 'Удалить ваш аккаунт?';

  @override
  String get profileDeleteMessage =>
      'Это навсегда. Аккаунт и все его данные удаляются из Elyeter без возможности восстановления.';

  @override
  String get profileDeleteLossOrders => 'История заказов';

  @override
  String get profileDeleteLossProfile => 'Имя, фото и сохранённые данные';

  @override
  String get profileDeleteLossAccess => 'Доступ к аккаунту на этом номере';

  @override
  String profileDeleteAccountOn(String phone) {
    return 'Аккаунт: $phone';
  }

  @override
  String get profileDeleteKeep => 'Оставить аккаунт';

  @override
  String get profileDeleteConfirm => 'Удалить навсегда';

  @override
  String get profileDeleteDone => 'Ваш аккаунт удалён.';

  @override
  String get commonOk => 'ОК';

  @override
  String get errorPaymentBankFailed =>
      'Банк не принял платёж. Попробуйте позже или выберите другой банк.';

  @override
  String get errorPreOrderAlreadyPaid => 'Этот заказ уже оплачен.';

  @override
  String get errorPreOrderNotPayable =>
      'Этот заказ больше нельзя оплатить онлайн.';

  @override
  String get errorBankNotFound =>
      'Этот банк сейчас недоступен. Выберите другой.';

  @override
  String get errorProductRequestInvalidLink =>
      'Мы не нашли ссылку на товар AliExpress в этом тексте.';

  @override
  String get paymentTitle => 'Оплата';

  @override
  String get paymentChooseBank => 'Выберите банк';

  @override
  String get paymentChooseBankHint =>
      'Данные карты вы введёте на странице банка.';

  @override
  String get paymentNoBanks => 'Онлайн-оплата сейчас недоступна.';

  @override
  String get paymentPayOnlineTitle => 'Оплатить онлайн';

  @override
  String get paymentPayOnlineMessage =>
      'Оплатите заказ картой сейчас — не дожидаясь звонка.';

  @override
  String get paymentPay => 'Оплатить';

  @override
  String get paymentPaid => 'Оплачено онлайн';

  @override
  String get paymentChecking => 'Проверяем оплату…';

  @override
  String get paymentCheckingMessage => 'Это займёт несколько секунд.';

  @override
  String get paymentSuccess => 'Оплата прошла успешно';

  @override
  String get paymentSuccessMessage => 'Ваш заказ оплачен. Спасибо!';

  @override
  String get paymentFailed => 'Оплата не прошла';

  @override
  String get paymentFailedMessage =>
      'Банк отклонил платёж. Попробуйте ещё раз или выберите другой банк.';

  @override
  String get paymentPending => 'Платёж проверяется';

  @override
  String get paymentPendingMessage =>
      'Банк ещё не подтвердил платёж. Заказ будет отмечен оплаченным, как только это произойдёт.';

  @override
  String get paymentNotCompletedMessage =>
      'Оплата не завершена. Если деньги списались с карты, заказ будет отмечен оплаченным в течение нескольких минут.';

  @override
  String get paymentTryAgain => 'Попробовать снова';

  @override
  String get productRequestTitle => 'Отправьте нам ссылку';

  @override
  String get productRequestMessage =>
      'Не нашли товар? Вставьте ссылку с AliExpress, и мы добавим его в каталог.';

  @override
  String get productRequestHint =>
      'Ссылка AliExpress или текст из «Поделиться»';

  @override
  String get productRequestPaste => 'Вставить';

  @override
  String get productRequestSend => 'Отправить ссылку';

  @override
  String get productRequestSendAnother => 'Отправить другую ссылку';

  @override
  String get productRequestMine => 'Мои запросы товаров';

  @override
  String get productRequestSearchAction => 'Отправить ссылку на товар';

  @override
  String get productRequestLoadingTitle => 'Загружаем товар…';

  @override
  String get productRequestLoadingMessage => 'Обычно это занимает до минуты.';

  @override
  String get productRequestLaterTitle => 'Мы сообщим вам';

  @override
  String get productRequestLaterMessage =>
      'Это занимает чуть больше времени. Мы пришлём уведомление, когда товар станет доступен.';

  @override
  String get productRequestReviewTitle => 'На проверке';

  @override
  String get productRequestReviewMessage =>
      'Товар на проверке. Мы сообщим, когда он станет доступен.';

  @override
  String get productRequestRejectedTitle => 'Недоступно';

  @override
  String get productRequestRejectedMessage =>
      'К сожалению, мы не можем продавать этот товар.';

  @override
  String get productRequestFailedTitle => 'Не удалось загрузить';

  @override
  String get productRequestFailedMessage =>
      'Не удалось загрузить товар с AliExpress. Возможно, он снят с продажи.';

  @override
  String get productRequestAvailableTitle => 'Товар добавлен';

  @override
  String get productRequestAvailableMessage =>
      'Товар в каталоге. Найдите его в «Мои запросы товаров».';

  @override
  String get productRequestStatusProcessing => 'Загружается';

  @override
  String get productRequestStatusInReview => 'На проверке';

  @override
  String get productRequestStatusAvailable => 'Доступен';

  @override
  String get productRequestStatusRejected => 'Отклонён';

  @override
  String get productRequestStatusFailed => 'Не загружен';

  @override
  String get productRequestEmptyTitle => 'Запросов пока нет';

  @override
  String get errorImageSearchInvalidImage =>
      'Используйте фото JPEG, PNG или WebP.';

  @override
  String get errorImageSearchInProgress =>
      'Предыдущий поиск ещё отправляется. Подождите.';

  @override
  String get errorImageSearchUnavailable =>
      'Поиск временно недоступен, попробуйте позже.';

  @override
  String get imageSearchTitle => 'Поиск по фото';

  @override
  String get imageSearchSearching => 'Ищем ещё…';

  @override
  String get imageSearchEmpty => 'Ничего похожего пока нет';

  @override
  String imageSearchRateLimited(int minutes) {
    return 'Лимит поисков исчерпан. Повторите через $minutes мин.';
  }

  @override
  String imageSearchInReview(int count) {
    return 'Ваша фотография обработана. Ещё $count товаров проверяет модератор — пришлём уведомление.';
  }

  @override
  String get imageSearchFailed => 'Не удалось загрузить товары с AliExpress.';
}
