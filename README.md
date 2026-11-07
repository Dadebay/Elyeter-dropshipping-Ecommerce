# Elyeter

Flutter ile geliştirilen alışveriş uygulaması. Ürünleri inceleme, sepet, sipariş, adres, hesap ve bildirim akışları içerir. Kod yapısı için [ARCHITECTURE.md](ARCHITECTURE.md) dosyasına bakın.

## Kurulum ve geliştirme

Flutter sürümü: 3.47.8 (Dart 3.13.7). Çalıştırmadan önce `flutter pub get` ve `flutter gen-l10n` komutlarını uygulayın.

```sh
flutter run --dart-define=FLAVOR=dev
```

API adresi gerektiğinde `--dart-define=API_BASE_URL=...` ve dosya adresi için `--dart-define=FILE_BASE_URL=...` verilebilir. Varsayılanlar [app_environment.dart](lib/core/constants/app_environment.dart) içindedir. Gerçek gizli anahtarları veya imza parolalarını bu depoya eklemeyin.

## Kontrol ve derleme

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build appbundle --release --dart-define=FLAVOR=prod
flutter build ios --release --no-codesign --dart-define=FLAVOR=prod
```

Android mağaza imzası için `android/key.properties.example` dosyasını örnek alın; gerçek `android/key.properties` ve keystore dosyalarını Git dışında tutun. iOS mağaza yüklemesi için Apple imzası ayrıca gerekir. Testlerdeki golden önizlemeler normal test koşusunda atlanır; nasıl kontrol edileceği [ARCHITECTURE.md](ARCHITECTURE.md) içinde açıklanır.

## Uygulamayı edinme

- [App Store: Elyeter TM](https://apps.apple.com/us/app/elyeter-tm/id6824987693) — bu projenin iOS bundle ID'si `com.sanlyadim.elyeter` ile eşleşir.
- Google Play — bu projenin Android kimliği `com.gurbanov.elyeter` için doğrulanmış herkese açık bağlantı henüz bulunmadı. Yayına çıktığında bağlantıyı burada ekleyin; farklı kimlikli eski Elyeter uygulamasına yönlendirmeyin.
- [GitHub Release v1.0.0+1](https://github.com/Dadebay/elyeter/releases/tag/v1.0.0%2B1) — [imzalı Android APK'yı indir](https://github.com/Dadebay/elyeter/releases/download/v1.0.0%2B1/Elyeter-1.0.0-build1-android.apk). SHA-256: `3215ae98db0ed6aefc20da632c96203980e390d80ffaeacc5bcfd9143bd53253`. Android cihazda fiziksel duman testi bu sürüm hazırlanırken yapılamadı; ayrıntılar Release notlarında. AAB son kullanıcı kurulum dosyası değildir; iOS kurulumu için App Store bağlantısını kullanın.

Her mağaza sürümünü ilgili Git commit'i ve sürüm etiketiyle eşleştirin. Yayın öncesinde format, analiz, test, platform derlemesi ve PR CI kontrollerinin sonuçlarını kaydedin.

## `main` dalına birleştirme

Değişiklikleri ayrı dalda incelemeye açın. İnceleme yorumları çözüldüğünde ve PR kontrolleri geçtiğinde dalı `main` dalına birleştirin; zorla push yapmayın. Uzak `main` üzerindeki CI sonucunu da doğrulayın. Sürüm etiketini ve GitHub Release'i yalnızca doğrulanmış `main` commit'inden oluşturun.
