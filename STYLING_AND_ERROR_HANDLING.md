# Stripe Identity Plugin - Styling & Error Handling

## Summary of Changes

### 1. **Improved Error Handling**

#### Problem
The plugin was throwing raw `PlatformException` errors with unhelpful messages like:
```
PlatformException(failed, sessionID: placeholder_id and ephemeralKey: placeholder_key, null, null)
```

#### Solution
- Created `StripeIdentityException` class for consistent error handling
- Updated `MethodChannelIdentity` to catch `PlatformException` and convert to `StripeIdentityException`
- Added `_formatErrorMessage()` method in main plugin to provide user-friendly error messages
- Now errors show helpful messages like:
  - "Invalid verification parameters provided."
  - "Unable to present verification screen. Please try again."
  - "Verification failed. Please try again."

### 2. **UI Customization (`IdentityStyle`)**

The native Stripe Identity SDKs expose a very small *public* styling surface, so `IdentityStyle`
can only map onto that. See [issue #15](https://github.com/jeremiahseun/Stripe-Identity/issues/15).

| Option                  | iOS                         | Android                                  |
| ----------------------- | --------------------------- | ---------------------------------------- |
| `buttonBackgroundColor` | Yes, with Swift Package Manager (Stripe iOS SDK 26.16+) | Via `AndroidManifest.xml` only (see below) |
| `buttonTextColor`       | No (deprecated, no effect)  | No (deprecated, no effect)               |
| `buttonLabel`           | No (deprecated, no effect)  | No (deprecated, no effect)               |
| `navigationBarTitle`    | No (deprecated, no effect)  | No (deprecated, no effect)               |

#### Why the limits

- **iOS:** `IdentityVerificationSheet.Configuration.brandColor` was added in stripe-ios 26.16.0.
  CocoaPods trunk stops at `StripeIdentity` 26.15.0, so CocoaPods builds cannot use it and ignore the
  color. Stripe's button-style options are `@_spi(InternalOnlyAPI)` (internal), so this plugin does
  not use them.
- **Android:** The Stripe sheet registers an activity result launcher, which must happen before the
  activity starts. The plugin therefore creates the sheet when it attaches to the activity, before
  Dart can pass any arguments. Logo and color are read from `AndroidManifest.xml` meta-data instead.
  The button style classes in the Android SDK are annotated `@RestrictTo` (internal), so they are not
  used either.

#### Android manifest configuration

```xml
<application ...>
    <!-- Optional: square brand logo shown in the Stripe flow (defaults to your app icon) -->
    <meta-data android:name="com.stripe.identity.brand_logo_url"
               android:value="https://example.com/logo.png" />
    <!-- Optional: brand color for primary buttons, #RRGGBB or #AARRGGBB -->
    <meta-data android:name="com.stripe.identity.brand_color"
               android:value="#635BFF" />
</application>
```

Note: on Android the `brandLogoUrl` argument passed from Dart is currently ignored for the same
reason; use the manifest entry.

### 3. **Everything else is app-theme level**

On Android, remaining appearance follows your app's Material Components theme (`styles.xml`):

```xml
<style name="AppTheme" parent="Theme.MaterialComponents.Light.NoActionBar">
    <item name="colorPrimary">@color/your_primary_color</item>
    <item name="colorOnPrimary">@color/white</item>
</style>
```

On iOS the SDK follows system appearance (light/dark mode).

## Files involved

- `lib/utils/identity_style.dart` - style configuration class
- `lib/stripe_identity_plugin.dart` - main plugin with error formatting
- `lib/stripe_identity_plugin_method_channel.dart` - passes the style map to native
- `android/src/main/kotlin/.../StripeIdentityPlugin.kt` - reads brand logo/color from manifest meta-data
- `ios/stripe_identity_plugin/Sources/stripe_identity_plugin/StripeIdentityPlugin.swift` - maps `buttonBackgroundColor` to `brandColor`

## Testing

Dart unit tests cover the style serialization, the method-channel contract and the error mapping:

```sh
flutter test
```

Visual changes (brand color/logo) must be checked on a device or simulator with a real
VerificationSession; see `example/README.md`.
