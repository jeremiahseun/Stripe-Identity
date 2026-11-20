# stripe_identity_plugin

A Flutter plugin for implementing Stripe Identity Verification in your Flutter applications. This package provides a seamless integration with Stripe's Identity verification service for both Android and iOS platforms.

[![pub package](https://img.shields.io/pub/v/stripe_identity_plugin.svg)](https://pub.dev/packages/stripe_identity_plugin)

## Demo

**Tests in Debug Mode**

If you provide a correct verification session and ephermal secret key:

https://github.com/user-attachments/assets/c43a1a81-7a14-4417-8048-be689d196a0e

**Tests in Debug Mode**

Otherwise, you get this screen instead:

https://github.com/user-attachments/assets/d1a343c2-17dc-4bf0-b0c6-f9347e141e79

## Getting Started

You can go to [Stripe Identity Website](https://stripe.com/identity) for more information on how to get started.
This package is not endorsed by Stripe, but it is written to work seamlessly for you. For more information on how this package works for Android, iOS and other platforms, check out [Stripe Identity Documentation](https://docs.stripe.com/identity).

## Features

- Easy integration with Stripe Identity Verification
- Support for both Android and iOS platforms
- Customizable brand logo and brand color (see [Styling](#styling))
- Simple error handling and result parsing
- Type-safe verification results

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  stripe_identity_plugin: ^2.0.0
```

### Requirements

| | Minimum |
| --- | --- |
| Flutter / Dart | 3.44.0 / 3.12.0 |
| iOS | 15.0 |
| Android `minSdk` | 24 (Flutter 3.50's default; set `minSdk = 24` explicitly on older Flutter) |
| Android Kotlin | 2.1 or newer (Stripe's Android SDK is compiled with Kotlin 2.2; Flutter 3.44+ already ships newer) |
| Java | 17 |

**iOS dependency managers.** The plugin supports both **Swift Package Manager** (recommended, and the
default from Flutter 3.44) and **CocoaPods**. No extra setup is needed for either.

- Swift Package Manager resolves the Stripe iOS SDK `26.16` or newer and needs **Xcode 16.3+**
  (Stripe's Swift package uses `swift-tools-version:6.1`).
- CocoaPods resolves `StripeIdentity ~> 26.15`. CocoaPods trunk stops at 26.15.x, so the iOS brand color
  (which needs SDK 26.16) is only applied when building with Swift Package Manager.

**Android and Kotlin.** The plugin uses AGP's *built-in Kotlin* and does not apply the Kotlin Gradle Plugin,
so it does not trigger Flutter's "plugins that apply KGP" warning. It works whether your app has
`android.builtInKotlin=true` or keeps it `false`.

### Upgrading from 1.x

1. Update Flutter to 3.44 or newer (stay on `1.0.5` if you cannot).
2. Android: set `minSdk = 24` in `android/app/build.gradle` and use Java 17.
3. Android (optional): set the brand logo and color in `AndroidManifest.xml` (see [Android setup](#android)); the `brandLogoUrl` argument is ignored on Android.
4. iOS: raise your deployment target to 15.0 if needed; with Swift Package Manager use Xcode 16.3+.
5. Remove uses of the deprecated `IdentityStyle` options `buttonTextColor`, `buttonLabel` and `navigationBarTitle` (they never had any effect).

See the [CHANGELOG](CHANGELOG.md) for the full list of changes.

## Setup Instructions

### Android

1. **Update MainActivity**
   Change your `MainActivity.kt` to extend `FlutterFragmentActivity` instead of `FlutterActivity`. This is required because the Stripe SDK uses Android Fragments.

   ```kotlin
   // android/app/src/main/kotlin/com/example/your_app/MainActivity.kt
   import io.flutter.embedding.android.FlutterFragmentActivity

   class MainActivity: FlutterFragmentActivity()
   ```

2. **Configure Themes**
   The Stripe Identity SDK requires a **Material Components** theme. Update your `styles.xml` to inherit from a Material Components theme.

   **In `android/app/src/main/res/values/styles.xml`:**
   ```xml
   <style name="LaunchTheme" parent="Theme.MaterialComponents.Light.NoActionBar">
       <!-- ... -->
   </style>

   <style name="NormalTheme" parent="Theme.MaterialComponents.Light.NoActionBar">
       <item name="android:windowBackground">?android:colorBackground</item>
   </style>
   ```

   **In `android/app/src/main/res/values-night/styles.xml` (optional):**
   ```xml
   <style name="LaunchTheme" parent="Theme.MaterialComponents.Light.NoActionBar">
       <!-- ... -->
   </style>

   <style name="NormalTheme" parent="Theme.MaterialComponents.Light.NoActionBar">
       <item name="android:windowBackground">?android:colorBackground</item>
   </style>
   ```

3. **Add Application Theme (Recommended)**
   To ensure the Stripe Identity Activity acts consistently with your app, add the `android:theme` attribute to your `AndroidManifest.xml` application tag.

   ```xml
   <application
       android:label="identity_example"
       android:name="${applicationName}"
       android:theme="@style/NormalTheme"  <!-- Add this line -->
       ... >
   ```

4. **Set `minSdk` to 24**
   The Stripe Identity Android SDK (23.x) requires API 24. Flutter 3.50 already defaults to it; on older
   Flutter versions set it in `android/app/build.gradle`: `minSdk = 24`.

5. **Add Dependencies**
   If you encounter theme issues, ensure you have the Material library in your `android/app/build.gradle`:

   ```gradle
   dependencies {
       implementation 'com.google.android.material:material:1.13.0'
   }
   ```

6. **Brand logo and color (optional)**
   On Android the Stripe sheet is created before Dart code runs, so the logo and brand color are read from
   `AndroidManifest.xml` (the `brandLogoUrl` argument is ignored on Android):

   ```xml
   <application ...>
       <!-- Square brand logo shown in the Stripe flow. Defaults to your app icon. -->
       <meta-data android:name="com.stripe.identity.brand_logo_url"
                  android:value="https://your-domain.com/logo.png" />
       <!-- Primary button color: #RRGGBB or #AARRGGBB. Defaults to the Stripe style. -->
       <meta-data android:name="com.stripe.identity.brand_color"
                  android:value="#635BFF" />
   </application>
   ```

### iOS

1. **Camera Permission**
   Add the `NSCameraUsageDescription` key to your `ios/Runner/Info.plist` file. This is required for document scanning.

   ```xml
   <key>NSCameraUsageDescription</key>
   <string>We need access to the camera to scan your identity documents.</string>
   ```

2. **Dependency manager**
   Nothing to configure. With Flutter's Swift Package Manager integration enabled the plugin is added as a
   Swift package; otherwise it is installed through CocoaPods. See [Requirements](#requirements).

## Usage

### Basic Implementation

```dart
import 'package:flutter/material.dart';
import 'package:stripe_identity_plugin/stripe_identity_plugin.dart';
import 'package:stripe_identity_plugin/utils/identity_style.dart'; // Import for styling

final stripeIdentity = StripeIdentityPlugin();

// Start verification
final (status, message) = await stripeIdentity.startVerification(
  id: 'verification_session_id',
  key: 'ephemeral_key_secret',
  brandLogoUrl: 'https://your-domain.com/logo.png',

  // Optional: brand color for the primary buttons (iOS with Swift Package Manager;
  // on Android use the manifest entry instead, see Setup)
  style: const IdentityStyle(buttonBackgroundColor: Colors.blue),
);

// Handle the result
switch (status) {
  case VerificationResult.completed:
    print('Verification completed successfully');
  case VerificationResult.canceled:
    print('User canceled verification');
  case VerificationResult.failed:
    print('Verification failed: $message');
  case VerificationResult.unknown:
    print('Unknown error occurred: $message');
}
```

### Important Notes

1. **Backend Integration**: You must call your backend server to obtain the `verificationSessionId` and `ephemeralKeySecret` **before** starting the verification process.
2. **Brand Logo**: Ensure the brand logo is a square image (recommended 32x32 points). If no logo is provided (or it fails to load), the app icon is used on both platforms. On Android the logo is configured in `AndroidManifest.xml`.
3. **Styling Limitations**: See [Styling](#styling).

### Styling

The native Stripe SDKs only expose a brand logo and a brand color publicly, so that is all this plugin can
customize (see [#15](https://github.com/jeremiahseun/Stripe-Identity/issues/15)).

| Option | iOS | Android |
| --- | --- | --- |
| `brandLogoUrl` argument (falls back to the app icon) | Yes | No, use the manifest entry (falls back to the app icon) |
| `IdentityStyle.buttonBackgroundColor` | Yes (Swift Package Manager only) | No, use the manifest entry |
| `buttonTextColor`, `buttonLabel`, `navigationBarTitle` | No (deprecated, no effect) | No (deprecated, no effect) |

More detail is in [STYLING_AND_ERROR_HANDLING.md](STYLING_AND_ERROR_HANDLING.md).

## Verification Results

The plugin returns a tuple containing:

- `VerificationResult`: An enum indicating the status of verification
- `String?`: Optional message providing additional details

Possible verification results:

- `completed`: User has completed document upload and verification process
- `canceled`: User canceled the verification or didn't complete the process
- `failed`: Verification failed (includes error message)
- `unknown`: Unexpected error occurred

## Troubleshooting

### Android: "Plugin requires a component activity"
Ensure your `MainActivity` extends `FlutterFragmentActivity` as shown in the Android Setup section.

### Android: "Module was compiled with an incompatible version of Kotlin"
The Stripe Identity Android SDK is compiled with Kotlin 2.2. Use Kotlin Gradle Plugin 2.1 or newer in your app.

### Android: "The 'org.jetbrains.kotlin.android' plugin is not compatible with built-in Kotlin"
This comes from your *app*, not this plugin. If you enabled `android.builtInKotlin=true`, remove the `kotlin-android` / `org.jetbrains.kotlin.android` plugin from your app's Gradle files (see [Flutter's guide](https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers)), or set it back to `false`.

### Android: manifest merger error mentioning `minSdkVersion 21`
Set `minSdk = 24` in `android/app/build.gradle`.

### iOS: Swift Package resolution fails with a `swift-tools-version` error
Stripe's Swift package needs Xcode 16.3 or newer.

### Android: "You need to use a Theme.AppCompat theme" or "createMdcTheme requires..."
Ensure your `styles.xml` themes inherit from `Theme.MaterialComponents.Light.NoActionBar`.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
