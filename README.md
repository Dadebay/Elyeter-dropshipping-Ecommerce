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
- [GitHub Releases](https://github.com/Dadebay/elyeter/releases) — yeni sürüm yayımlandığında sürüm notları ve varsa doğrudan kurulabilir, imzalı Android APK burada bulunur. Özel depolardaki Release'lere yalnızca depo erişimi olan kişiler ulaşabilir. AAB dosyası son kullanıcıya kurulum dosyası olarak verilmez; iOS kurulumu için App Store bağlantısını kullanın.

Her mağaza sürümünü ilgili Git commit'i ve sürüm etiketiyle eşleştirin. Yayın öncesinde format, analiz, test, platform derlemesi ve PR CI kontrollerinin sonuçlarını kaydedin.
