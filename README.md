# Elyeter

Elyeter is a Flutter shopping app with product browsing, cart, orders, addresses, account, and notifications. See [ARCHITECTURE.md](ARCHITECTURE.md) for the code structure.

## Setup and development

Use Flutter 3.47.8 (Dart 3.13.7). Run `flutter pub get` and `flutter gen-l10n` before starting the app.

```sh
flutter run --dart-define=FLAVOR=dev
```

Set `--dart-define=API_BASE_URL=...` for a different API or `--dart-define=FILE_BASE_URL=...` for a different file server. Defaults are in [app_environment.dart](lib/core/constants/app_environment.dart). Keep real secrets and signing passwords out of this repository.

## Checks and builds

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build appbundle --release --dart-define=FLAVOR=prod
flutter build ios --release --no-codesign --dart-define=FLAVOR=prod
```

Use `android/key.properties.example` as a guide for Android store signing. Keep the real `android/key.properties` and keystore outside Git. An App Store upload also requires Apple signing. Golden previews are skipped by the default test run; [ARCHITECTURE.md](ARCHITECTURE.md) explains how to check them.

## Get the app

- [App Store: Elyeter TM](https://apps.apple.com/us/app/elyeter-tm/id6824987693) — matches this project's iOS bundle ID, `com.sanlyadim.elyeter`.
- Google Play — no public listing has been verified for this project's Android application ID, `com.gurbanov.elyeter`. Add its link here after verification; do not link to an older Elyeter app with a different ID.
- [GitHub Release v1.0.0+1](https://github.com/Dadebay/elyeter/releases/tag/v1.0.0%2B1) — [download the signed Android APK](https://github.com/Dadebay/elyeter/releases/download/v1.0.0%2B1/Elyeter-1.0.0-build1-android.apk). SHA-256: `3215ae98db0ed6aefc20da632c96203980e390d80ffaeacc5bcfd9143bd53253`. A physical Android smoke test was unavailable when this release was prepared; see the release notes. An AAB is not a user-installable file. Install the iOS app through the App Store.

Match every store version to its Git commit and release tag. Record format, analysis, test, platform build, and PR CI results before publishing.

## GitHub repository page

Keep the GitHub **About** description, verified website, and relevant topics current in the repository settings. README text does not fill those fields. Publish an actual GitHub Release for each distributed version, then verify that the Releases card and download links work for users.

## Merge into `main`

Open a pull request from a separate branch. Resolve review comments and pass PR checks before merging into `main`; do not force-push. Verify CI on the remote `main` branch. Create the version tag and GitHub Release from the verified commit on `main`.
