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

### 2. **UI Customization Support**

#### New `IdentityStyle` Class
Created a new configuration class that allows customization from Flutter:

```dart
class IdentityStyle {
  final Color? buttonBackgroundColor;
  final Color? buttonTextColor;
  final String? buttonLabel;
  final String? navigationBarTitle;
}
```

#### Usage Example
```dart
await plugin.startVerification(
  id: 'vs_xxx',
  key: 'ek_xxx',
  style: IdentityStyle(
    buttonBackgroundColor: Colors.blue,
    buttonTextColor: Colors.white,
    navigationBarTitle: "My Custom Title",
  ),
);
```

### 3. **Native Platform Integration**

#### **✅ Flutter → Native Communication**
The style configuration is now successfully passed from Flutter to both platforms:

**Flutter Side:**
- `IdentityStyle.toMap()` converts the style to a map
- `MethodChannelIdentity` sends the map via method channel: `if (style != null) 'style': style.toMap()`

**Android Side:**
- `StripeIdentityPlugin.kt` now extracts: `val styleMap = call.argument<Map<String, Any>>("style")`
- Receives the map in `startVerification(id, key, styleMap, result)`

**iOS Side:**
- `StripeIdentityPlugin.swift` now extracts: `let styleMap = args["style"] as? [String: Any]`
- Receives the map in `startVerification(id:key:brandLogoUrl:styleMap:result:)`

## ⚠️ Important Notes

### Stripe SDK Limitations
The Stripe Identity SDK has **limited customization options**:

1. **What CAN be customized:**
   - Brand logo (via `brandLogoUrl` parameter)
   - App-level Material theme colors (Android) via `styles.xml`
   - Some navigation bar appearance (iOS) via system APIs

2. **What CANNOT be easily customized:**
   - Individual button colors within the Stripe UI
   - Button labels (SDK controls this)
   - Most text content (controlled by Stripe for compliance)
   - Screen-specific navigation titles

### Current Implementation Status

**✅ Implemented:**
- Style parameters are passed from Flutter → Native
- Error handling is improved with user-friendly messages
- Plugin infrastructure supports style customization

**⚠️ Limited by Stripe SDK:**
- The native platforms receive the `styleMap` but Stripe's `IdentityVerificationSheet.Configuration` has very few customization options
- Most visual customization must be done at the application theme level (Android) or appears system-level (iOS)

### Recommendations

**For Android:**
The best way to customize appearance is by modifying the Material theme in `styles.xml`:
```xml
<style name="AppTheme" parent="Theme.MaterialComponents.Light.NoActionBar">
    <item name="colorPrimary">@color/your_primary_color</item>
    <item name="colorPrimaryVariant">@color/your_primary_variant</item>
    <item name="colorOnPrimary">@color/white</item>
</style>
```

**For iOS:**
Limited to what `IdentityVerificationSheet.Configuration` exposes (primarily the brand logo).

## Files Modified

### Dart Files:
1. `/lib/utils/identity_style.dart` - New style configuration class
2. `/lib/utils/exception.dart` - Exception class (no changes needed)
3. `/lib/stripe_identity_plugin.dart` - Main plugin with error formatting
4. `/lib/stripe_identity_plugin_platform_interface.dart` - Added style parameter
5. `/lib/stripe_identity_plugin_method_channel.dart` - Passes style to native
6. `/test/stripe_identity_plugin_test.dart` - Updated mock

### Native Files:
7. `/android/src/main/kotlin/.../StripeIdentityPlugin.kt` - Receives style map
8. `/ios/Classes/StripeIdentityPlugin.swift` - Receives style map

## Testing

To test the changes:

1. **Error Handling:**
   ```dart
   // Try with invalid credentials
   final (status, message) = await plugin.startVerification(
     id: 'invalid_id',
     key: 'invalid_key',
   );
   // Should show: "Verification failed. Please try again."
   ```

2. **Style Passing:**
   ```dart
   // Add print statements in native code to verify style map is received
   final (status, message) = await plugin.startVerification(
     id: dotenv.env['VERIFICATION_ID']!,
     key: dotenv.env['VERIFICATION_KEY']!,
     style: IdentityStyle(
       buttonBackgroundColor: Colors.blue,
       buttonTextColor: Colors.white,
     ),
   );
   ```

## Next Steps (Optional)

If you need more customization, you could:
1. Fork the Stripe Identity SDK and modify its internal UI
2. Build a custom identity verification flow using Stripe's lower-level APIs
3. Work within the Material theme customization on Android
4. Accept the SDK's default appearance and customize only the brand logo
