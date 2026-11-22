# Changelog

## 2.0.0

A major release: Swift Package Manager support, new Stripe SDK major versions, and raised platform minimums. If you are on Flutter older than 3.44, stay on `1.0.5`.

### Highlights

* **Swift Package Manager support** for iOS. The plugin now ships `ios/stripe_identity_plugin/Package.swift`, so apps using Flutter's SwiftPM integration (the default from Flutter 3.44) no longer need CocoaPods for this plugin. CocoaPods remains supported through the podspec.
* **Stripe SDK upgrades:** Stripe Identity iOS SDK `26.x` (SwiftPM `26.16+`, CocoaPods `~> 26.15`) and Stripe Identity Android SDK `23.26.0` (was `22.5.0`).
* **Built-in Kotlin:** the Android plugin no longer applies the Kotlin Gradle Plugin, which silences Flutter's "plugins that apply KGP will fail in future versions" warning. It works with apps that use built-in Kotlin (`android.builtInKotlin=true`) and with apps that keep it disabled.

### Breaking changes (minimums raised)

* **Flutter 3.44.0 / Dart 3.12.0 or newer.** Needed for the `FlutterFramework` Swift package and for the Kotlin migration.
* **iOS 15.0 or newer** (required by Stripe iOS SDK 26.x).
* **Android `minSdk` 24** (required by Stripe Android SDK 23.x; was 21) and **Java 17**. The Stripe Android SDK is compiled with Kotlin 2.2, so apps need Kotlin Gradle Plugin 2.1+ (Flutter 3.44 already ships newer).
* Swift Package Manager users need **Xcode 16.3+** (Stripe's Swift package uses `swift-tools-version:6.1`).
* `IdentityStyle.buttonTextColor`, `buttonLabel` and `navigationBarTitle` are **deprecated** (see below). They still compile and are ignored.

### Upgrading from 1.x

1. Update Flutter to 3.44 or newer.
2. Android: set `minSdk = 24` in `android/app/build.gradle`, and make sure the app uses Java 17.
3. Android (optional): configure the brand logo and color in `AndroidManifest.xml` (`com.stripe.identity.brand_logo_url`, `com.stripe.identity.brand_color`); the `brandLogoUrl` argument is ignored on Android.
4. iOS: nothing to change. Raise your deployment target to 15.0 if needed, and use Xcode 16.3+ with Swift Package Manager.
5. Remove uses of the deprecated `IdentityStyle` options (optional; they had no effect before either).

### Styling (#15)

* `IdentityStyle.buttonBackgroundColor` now takes effect on iOS (Swift Package Manager builds, via Stripe's `brandColor`).
* On Android the sheet is created before Dart code can run, so brand color and logo are configured in `AndroidManifest.xml`: `com.stripe.identity.brand_color` (new) and `com.stripe.identity.brand_logo_url`.
* **Deprecated** `IdentityStyle.buttonTextColor`, `buttonLabel` and `navigationBarTitle`: the Stripe SDKs do not support them and they never had any effect.

### Fixes

* **iOS:** when no brand logo URL is given or it fails to load, the app icon is now used (matching Android) instead of a "+" placeholder image.
* **iOS:** the sheet is now presented from the top-most view controller of the foreground window scene instead of `UIApplication.shared.windows.first`, which could pick the wrong window or fail when another view controller was already presented.
* **Android:** after an activity recreation (for example a configuration change) the Stripe sheet was never recreated, so every later `startVerification` failed with `NO_SHEET`.
* **Android:** removed the deprecated `package` attribute from the plugin manifest and modernized the Gradle build (compileSdk 36, Java 17, `kotlin { compilerOptions }`).
* Podspec: version and homepage metadata.

### Tests and docs

* Replaced placeholder tests with real unit tests (method-channel contract, result and error mapping, `IdentityStyle` serialization) and replaced the stale Android template test and example widget test.
* CI now builds the example on Android and on iOS with both Swift Package Manager and CocoaPods.
* README and `STYLING_AND_ERROR_HANDLING.md` now state the real requirements and what styling is (and is not) supported. The example app documents the required `.env` file.

## 1.0.5

* **Added UI Customization:** Introduced `IdentityStyle` class to allow customizing button colors, text colors, and labels from Flutter.
* **Improved Error Handling:** Deprecated raw `PlatformException` in favor of user-friendly error messages and parsed status codes.
* **Fixed Android Themes:** Resolved crashes related to `Theme.AppCompat` by supporting `Theme.MaterialComponents`.
* **Compatibility:** Verified support for Android 15 and 16KB page sizes (pure Kotlin implementation).
* **Documentation:** Updated README with comprehensive setup instructions for Android (FragmentActivity, Themes) and iOS (Camera Permissions).

## 1.0.4

Fixes:

* Android Plugin Crash fixes

## 1.0.3

Fixes:

* Fixed URI Image for Android

## 1.0.2

Fixes:

* Fixed plugin class name for Android and iOS

## 1.0.1

* Fixed plugin class name for use
* Added screen record for reference purposes

## 1.0.0

* Initial release of the Stripe Identity Plugin
* Features included:
  * Implementation of Stripe Identity Verification for Flutter
  * Support for Android and iOS platforms
  * Customizable brand logo integration
  * Comprehensive error handling and result parsing
  * Type-safe verification results
  * Documentation and usage examples

## 0.0.1-dev

* Development version
* Initial setup of the plugin structure
* Basic implementation of native platform channels
* Preliminary testing and documentation
