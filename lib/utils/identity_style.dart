import 'dart:ui' show Color;

/// Configuration class for customizing the Stripe Identity verification UI.
///
/// The native Stripe Identity SDKs only expose a very small public styling
/// surface: a brand logo and a brand color. This class maps onto that surface;
/// it cannot restyle individual widgets (see
/// [issue #15](https://github.com/jeremiahseun/Stripe-Identity/issues/15)).
///
/// | Option                     | iOS | Android |
/// | -------------------------- | --- | ------- |
/// | [buttonBackgroundColor]    | yes | no (1)  |
/// | [buttonTextColor]          | no  | no      |
/// | [buttonLabel]              | no  | no      |
/// | [navigationBarTitle]       | no  | no      |
///
/// 1. On Android the Stripe sheet is created when the plugin attaches to the
///    activity, before Dart code can run, so the brand color cannot be changed
///    per call. Set it once in `AndroidManifest.xml` instead, using the
///    `com.stripe.identity.brand_color` meta-data entry (see the README).
class IdentityStyle {
  /// The brand color used for the primary action buttons.
  ///
  /// On iOS the button text color is chosen automatically (black or white,
  /// whichever contrasts more with this color).
  ///
  /// On Android this value is currently ignored at runtime; configure the
  /// `com.stripe.identity.brand_color` meta-data entry in your
  /// `AndroidManifest.xml` instead.
  final Color? buttonBackgroundColor;

  /// The text color for buttons.
  ///
  /// Not supported by the Stripe SDKs; this value has no effect.
  final Color? buttonTextColor;

  /// The label text for the primary action button.
  ///
  /// Not supported by the Stripe SDKs; this value has no effect.
  final String? buttonLabel;

  /// The navigation bar/app bar title.
  ///
  /// Not supported by the Stripe SDKs; this value has no effect.
  final String? navigationBarTitle;

  /// Creates an [IdentityStyle] configuration.
  ///
  /// All parameters are optional. If not provided, the Stripe SDK defaults
  /// will be used.
  const IdentityStyle({
    this.buttonBackgroundColor,
    @Deprecated(
      'The Stripe Identity SDKs do not support a custom button text color. '
      'This has no effect.',
    )
    this.buttonTextColor,
    @Deprecated(
      'The Stripe Identity SDKs do not support a custom button label. '
      'This has no effect.',
    )
    this.buttonLabel,
    @Deprecated(
      'The Stripe Identity SDKs do not support a custom navigation bar title. '
      'This has no effect.',
    )
    this.navigationBarTitle,
  });

  /// Converts the style to a map for passing to the native platform.
  ///
  /// Colors are encoded as 32-bit ARGB integers.
  Map<String, dynamic> toMap() {
    return {
      if (buttonBackgroundColor != null)
        'buttonBackgroundColor': buttonBackgroundColor!.toARGB32(),
      if (buttonTextColor != null)
        'buttonTextColor': buttonTextColor!.toARGB32(),
      if (buttonLabel != null) 'buttonLabel': buttonLabel,
      if (navigationBarTitle != null) 'navigationBarTitle': navigationBarTitle,
    };
  }
}
