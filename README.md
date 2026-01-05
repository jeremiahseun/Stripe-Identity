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
- Customizable brand logo display
- **UI Customization** via `IdentityStyle`
- Simple error handling and result parsing
- Type-safe verification results

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  stripe_identity_plugin: latest
```

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

4. **Add Dependencies**
   If you encounter theme issues, ensure you have the Material library in your `android/app/build.gradle`:

   ```gradle
   dependencies {
       implementation 'com.google.android.material:material:1.11.0'
   }
   ```

### iOS

1. **Camera Permission**
   Add the `NSCameraUsageDescription` key to your `ios/Runner/Info.plist` file. This is required for document scanning.

   ```xml
   <key>NSCameraUsageDescription</key>
   <string>We need access to the camera to scan your identity documents.</string>
   ```

## Usage

### Basic Implementation

```dart
import 'package:stripe_identity_plugin/stripe_identity_plugin.dart';
import 'package:stripe_identity_plugin/utils/identity_style.dart'; // Import for styling

final stripeIdentity = StripeIdentityPlugin();

// Start verification
final (status, message) = await stripeIdentity.startVerification(
  id: 'verification_session_id',
  key: 'ephemeral_key_secret',
  brandLogoUrl: 'https://your-domain.com/logo.png',

  // Optional: Customize UI appearance
  style: IdentityStyle(
    buttonBackgroundColor: Colors.blue,
    buttonTextColor: Colors.white,
    navigationBarTitle: "Confirm Identity",
  ),
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
2. **Brand Logo**: Ensure the brand logo is a square image (recommended 32x32 points).
3. **Styling Limitations**: The native Stripe SDK has limited customization options. The `IdentityStyle` parameters are passed to the native platform, but visual changes depend on the underlying native theme/configuration support.

## Verification Results

The plugin returns a tuple containing:

- `VerificationResult`: An enum indicating the status of verification
- `String?`: Optional message providing additional details

Possible verification results:

- `completed`: User has completed document upload and verification process
- `canceled`: User canceled the verification or didn't complete the process
- `failed`: Verification failed (includes error message)
- `unknown`: Unexpected error occurred

## Requirements

- iOS 13.0 or higher
- Android API level 21 or higher
- Flutter 3.0.0 or higher
- Kotlin 1.9.0+ (Recommended)

## Troubleshooting

### Android: "Plugin requires a component activity"
Ensure your `MainActivity` extends `FlutterFragmentActivity` as shown in the Android Setup section.

### Android: "You need to use a Theme.AppCompat theme" or "createMdcTheme requires..."
Ensure your `styles.xml` themes inherit from `Theme.MaterialComponents.Light.NoActionBar`.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
