# Changelog

## 1.1.0

* **Swift Package Manager support:** The iOS plugin now ships a `Package.swift` alongside the existing podspec, so apps building with SPM no longer need CocoaPods for this plugin. CocoaPods remains supported.
* **Pinned the Stripe Identity iOS SDK** to `25.14.x` for both SPM and CocoaPods, so both build systems resolve the same native SDK.
* **Requires Flutter 3.41.0 or newer**, which is the first version that vends the `FlutterFramework` Swift package the plugin depends on.
* **iOS:** Raised the minimum deployment target to iOS 15 to match the current Stripe Identity SDK.

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
