import 'package:flutter/material.dart';

/// Configuration class for customizing the Stripe Identity verification UI.
///
/// This class allows you to customize the appearance of the verification flow
/// on both Android and iOS platforms.
class IdentityStyle {
  /// The primary color used for buttons and accents.
  ///
  /// On Android, this affects the Material Components theme primary color.
  /// On iOS, this affects the button background color.
  final Color? buttonBackgroundColor;

  /// The text color for buttons.
  final Color? buttonTextColor;

  /// The label text for the primary action button.
  ///
  /// Note: This may not be customizable on all platforms/SDK versions.
  final String? buttonLabel;

  /// The navigation bar/app bar title.
  ///
  /// Note: The Stripe Identity SDK may override this in certain screens.
  final String? navigationBarTitle;

  /// Creates an [IdentityStyle] configuration.
  ///
  /// All parameters are optional. If not provided, the Stripe SDK defaults
  /// will be used.
  const IdentityStyle({
    this.buttonBackgroundColor,
    this.buttonTextColor,
    this.buttonLabel,
    this.navigationBarTitle,
  });

  /// Converts the style to a map for passing to the native platform.
  Map<String, dynamic> toMap() {
    return {
      if (buttonBackgroundColor != null)
        'buttonBackgroundColor': buttonBackgroundColor!.value,
      if (buttonTextColor != null) 'buttonTextColor': buttonTextColor!.value,
      if (buttonLabel != null) 'buttonLabel': buttonLabel,
      if (navigationBarTitle != null) 'navigationBarTitle': navigationBarTitle,
    };
  }
}
