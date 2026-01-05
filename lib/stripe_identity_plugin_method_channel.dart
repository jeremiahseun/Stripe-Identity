import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'stripe_identity_plugin_platform_interface.dart';
import 'utils/exception.dart';
import 'utils/identity_style.dart';

/// An implementation of [IdentityPlatform] that uses method channels.
class MethodChannelIdentity extends IdentityPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('stripe_identity_plugin');

  @override
  Future<String> startVerification({
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
      final result =
          await methodChannel.invokeMethod<String>('startVerification', {
        'id': id,
        'key': key,
        'brandLogoUrl': brandLogoUrl,
        if (style != null) 'style': style.toMap(),
      });
      if (result == null) {
        throw StripeIdentityException(
          'NULL_RESULT',
          'The platform returned a null result',
        );
      }
      return result;
    } on PlatformException catch (e) {
      // Convert PlatformException to StripeIdentityException for consistent error handling
      throw StripeIdentityException(
        e.code,
        e.message ?? 'An unknown error occurred',
      );
    }
  }
}
