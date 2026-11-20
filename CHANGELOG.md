# Changelog

## 1.1.0

### Highlights

* **Swift Package Manager support** for iOS. The plugin now ships `ios/stripe_identity_plugin/Package.swift`, so apps using Flutter's SwiftPM integration (the default from Flutter 3.44) no longer need CocoaPods for this plugin. CocoaPods remains supported through the podspec.
* **Stripe SDK upgrades:** Stripe Identity iOS SDK `26.x` (SwiftPM `26.16+`, CocoaPods `~> 26.15`) and Stripe Identity Android SDK `23.26.0` (was `22.5.0`).

### Breaking changes (minimums raised)

* **Flutter 3.41.0 / Dart 3.11.0 or newer.** Required by the `FlutterFramework` Swift package the iOS plugin depends on.
* **iOS 15.0 or newer** (required by Stripe iOS SDK 26.x).
* **Android `minSdk` 24** (required by Stripe Android SDK 23.x; was 21) and **Java 17**. The Stripe Android SDK is compiled with Kotlin 2.2, so apps need Kotlin Gradle Plugin 2.1+.
* Swift Package Manager users need **Xcode 16.3+** (Stripe's Swift package uses `swift-tools-version:6.1`).

### Styling (#15)

* `IdentityStyle.buttonBackgroundColor` now takes effect on iOS (Swift Package Manager builds, via Stripe's `brandColor`).
* On Android the sheet is created before Dart code can run, so brand color and logo are configured in `AndroidManifest.xml`: `com.stripe.identity.brand_color` (new) and `com.stripe.identity.brand_logo_url`. The `brandLogoUrl` argument is ignored on Android.
* **Deprecated** `IdentityStyle.buttonTextColor`, `buttonLabel` and `navigationBarTitle`: the Stripe SDKs do not support them and they never had any effect. They still compile and are ignored.

### Fixes

* **Android:** after an activity recreation (for example a configuration change) the Stripe sheet was never recreated, so every later `startVerification` failed with `NO_SHEET`.
* **Android:** removed the deprecated `package` attribute from the plugin manifest and modernized the Gradle build (compileSdk 36, Java 17, `kotlin { compilerOptions }`).
* **iOS:** the sheet is now presented from the top-most view controller of the foreground window scene instead of `UIApplication.shared.windows.first`, which could pick the wrong window or fail when another view controller was already presented.
* Podspec: version and homepage metadata.

### Tests and docs

* Replaced placeholder tests with real unit tests (method-channel contract, result and error mapping, `IdentityStyle` serialization) and replaced the stale Android template test.
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
