# identity_example

Example app for the `stripe_identity_plugin` Flutter plugin.

> **Requires Flutter 3.50 or newer.** The example's Android project uses Gradle 9.5, AGP 9.3 and
> built-in Kotlin (`android.builtInKotlin=true`), which older Flutter versions do not accept. On an
> older Flutter, regenerate the Android scaffolding with `flutter create --platforms=android .` from
> this folder (the plugin itself supports Flutter 3.44+).

## Running the example

1. Create a Stripe Identity **VerificationSession** and an **ephemeral key** on your backend
   (see the [Stripe docs](https://docs.stripe.com/identity/verify-identity-documents)). Never put your
   Stripe secret key in the app.
2. Copy `env.example` to `.env` and fill in `VERIFICATION_ID` and `VERIFICATION_KEY`.
   `.env` is git-ignored; the app will not build without the file.
3. Run it on a **real device** (the camera flow does not work on simulators/emulators):

   ```sh
   cd example
   flutter pub get
   flutter run
   ```

VerificationSessions and ephemeral keys are single-use and expire, so create a fresh pair for every run.

## Testing iOS with both dependency managers

```sh
cd example

# Swift Package Manager
flutter config --enable-swift-package-manager
flutter clean && flutter pub get
flutter build ios --no-codesign
# The plugin must NOT be listed in ios/Podfile.lock

# CocoaPods
flutter config --no-enable-swift-package-manager
flutter clean && flutter pub get
flutter build ios --no-codesign
```

Flutter may migrate `example/ios` files (Podfile, `AppFrameworkInfo.plist`, UIScene lifecycle) when you
build. Those edits are generated; do not commit them.

## Android brand color and logo

Edit `android/app/src/main/AndroidManifest.xml` and add inside `<application>`:

```xml
<meta-data android:name="com.stripe.identity.brand_color" android:value="#635BFF" />
<meta-data android:name="com.stripe.identity.brand_logo_url" android:value="https://example.com/logo.png" />
```

## Unit tests

```sh
# Dart
cd .. && flutter test && cd example && flutter test

# Android plugin (Kotlin) unit tests, after building the example once
cd android && ./gradlew :stripe_identity_plugin:testDebugUnitTest
```
