import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:stripe_identity_plugin/stripe_identity_plugin_platform_interface.dart';
import 'package:stripe_identity_plugin/utils/enum.dart';
import 'package:stripe_identity_plugin/utils/exception.dart';
import 'package:stripe_identity_plugin/utils/identity_style.dart';

/// The main class for interacting with Stripe Identity verification.
///
/// This plugin allows you to integrate Stripe Identity verification into your
/// Flutter application. It supports both Android and iOS platforms.
///
/// ## Usage
///
/// ```dart
/// final plugin = StripeIdentityPlugin();
///
/// // Start verification with default styling
/// final (status, message) = await plugin.startVerification(
///   id: 'vs_xxx', // Your verification session ID
///   key: 'ek_xxx', // Your ephemeral key secret
///   brandLogoUrl: 'https://example.com/logo.png',
/// );
///
/// // Start verification with custom styling
/// final (status, message) = await plugin.startVerification(
///   id: 'vs_xxx',
///   key: 'ek_xxx',
///   style: IdentityStyle(
///     buttonBackgroundColor: Colors.blue,
///     buttonTextColor: Colors.white,
///   ),
/// );
/// ```
class StripeIdentityPlugin {
  //* THE FUNCTION TO BEGIN VERIFICATION ON BOTH ANDROID AND IOS
  //* You should call your server endpoint before calling this method
  //* This method will receive the [verificationSessionId] and [ephemeralKeySecret]
  //* You should also pass your brand logo to this method.
  //! Recommended image size is [32 x 32 points]

  /// Starts the Stripe Identity verification flow.
  ///
  /// Parameters:
  /// - [id]: The verification session ID from your server endpoint
  /// - [key]: The ephemeral key secret from your server endpoint
  /// - [brandLogoUrl]: URL to a square brand logo (recommended 32x32 points)
  /// - [style]: Optional styling configuration for the verification UI
  ///
  /// Returns a tuple containing:
  /// - [VerificationResult]: The result status of the verification
  /// - [String?]: An optional message describing the result
  ///
  /// Possible results:
  /// - [VerificationResult.completed]: User completed document upload
  /// - [VerificationResult.canceled]: User canceled the verification
  /// - [VerificationResult.failed]: Verification failed with an error
  /// - [VerificationResult.unknown]: An unknown error occurred
  Future<(VerificationResult status, String? message)> startVerification({
    //* The verificationSessionId from your server endpoint
    required String id,
    //* The ephemeralKeySecret from your server endpoint
    required String key,
    //* Configure a square brand logo. Recommended image size is [32 x 32 points].
    String? brandLogoUrl,
    //* Optional styling configuration for the verification UI
    IdentityStyle? style,
  }) async {
    try {
      //* The verification begins at this point.
      if (kDebugMode) {
        log("Attempting to start verification", name: "StripeIdentityPlugin");
      }
      final result = await IdentityPlatform.instance.startVerification(
        id: id,
        key: key,
        brandLogoUrl: brandLogoUrl,
        style: style,
      );
      //* Returns a parsed verification result based on the result received from the platform.
      return _parseVerificationResult(result);
    } on StripeIdentityException catch (e) {
      if (kDebugMode) {
        log(
          "Error while starting verification\nThe message is: ${e.message} and the code is: ${e.code}",
          name: "StripeIdentityPlugin",
        );
      }
      //! It will most likely result to this exception when:
      //? On the iOS side, [result(FlutterError)] is returned
      //? On the Android side, [result.error()] is returned
      return (
        VerificationResult.failed,
        _formatErrorMessage(e.code, e.message),
      );
    } catch (e) {
      if (kDebugMode) {
        log(
          "Error while starting verification\nThe error message is: ${e.toString()}",
          name: "StripeIdentityPlugin",
        );
      }
      return (VerificationResult.unknown, e.toString());
    }
  }

  /// Formats the error message for display to the user.
  ///
  /// This method takes the error code and message from the platform and
  /// returns a user-friendly error message.
  String _formatErrorMessage(String code, String? message) {
    switch (code) {
      case 'INVALID_ARGUMENTS':
        return 'Invalid verification parameters provided.';
      case 'NO_ACTIVITY':
      case 'NO_VIEW_CONTROLLER':
        return 'Unable to present verification screen. Please try again.';
      case 'NULL_RESULT':
        return 'No response received from verification service.';
      case 'failed':
        return message ?? 'Verification failed. Please try again.';
      default:
        return message ?? 'An unexpected error occurred. Please try again.';
    }
  }

  (VerificationResult status, String message) _parseVerificationResult(
    String result,
  ) {
    switch (result) {
      case 'completed':
        //* The user has completed uploading their documents.
        //* Let them know that the verification is processing.
        //* This can also mean that the verification is successful or not.
        return (VerificationResult.completed, "Verification is completed.");
      case 'canceled':
        //* The user has canceled the verification OR
        //* The user did not complete uploading their documents.
        //* You should allow them to try again.
        return (VerificationResult.canceled, "Verification is canceled.");
      case 'failed':
        //* If the flow fails, you should display the localized error
        //* message to your user
        return (VerificationResult.failed, "Verification failed.");
      default:
        //* An unknown error occured. They can try again.
        return (VerificationResult.unknown, "Unknown error.");
    }
  }
}
