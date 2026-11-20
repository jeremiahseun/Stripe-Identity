import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:stripe_identity_plugin/stripe_identity_plugin.dart';
import 'package:stripe_identity_plugin/stripe_identity_plugin_method_channel.dart';
import 'package:stripe_identity_plugin/stripe_identity_plugin_platform_interface.dart';
import 'package:stripe_identity_plugin/utils/enum.dart';
import 'package:stripe_identity_plugin/utils/exception.dart';
import 'package:stripe_identity_plugin/utils/identity_style.dart';

class FakeIdentityPlatform
    with MockPlatformInterfaceMixin
    implements IdentityPlatform {
  FakeIdentityPlatform(this._handler);

  final Future<String> Function() _handler;

  String? lastId;
  String? lastKey;
  String? lastBrandLogoUrl;
  IdentityStyle? lastStyle;

  @override
  Future<String> startVerification({
    required String id,
    required String key,
    String? brandLogoUrl,
    IdentityStyle? style,
  }) {
    lastId = id;
    lastKey = key;
    lastBrandLogoUrl = brandLogoUrl;
    lastStyle = style;
    return _handler();
  }
}

void main() {
  final IdentityPlatform initialPlatform = IdentityPlatform.instance;

  tearDown(() => IdentityPlatform.instance = initialPlatform);

  test('$MethodChannelIdentity is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelIdentity>());
  });

  group('startVerification result mapping', () {
    const cases = <String, VerificationResult>{
      'completed': VerificationResult.completed,
      'canceled': VerificationResult.canceled,
      'failed': VerificationResult.failed,
      'something-new': VerificationResult.unknown,
    };

    cases.forEach((nativeResult, expected) {
      test('"$nativeResult" -> $expected', () async {
        IdentityPlatform.instance = FakeIdentityPlatform(
          () async => nativeResult,
        );

        final (status, message) = await StripeIdentityPlugin()
            .startVerification(id: 'vs', key: 'ek');

        expect(status, expected);
        expect(message, isNotEmpty);
      });
    });
  });

  test('forwards all arguments to the platform', () async {
    final fake = FakeIdentityPlatform(() async => 'completed');
    IdentityPlatform.instance = fake;
    const style = IdentityStyle(buttonBackgroundColor: Color(0xFF0000FF));

    await StripeIdentityPlugin().startVerification(
      id: 'vs_1',
      key: 'ek_1',
      brandLogoUrl: 'https://example.com/logo.png',
      style: style,
    );

    expect(fake.lastId, 'vs_1');
    expect(fake.lastKey, 'ek_1');
    expect(fake.lastBrandLogoUrl, 'https://example.com/logo.png');
    expect(fake.lastStyle, same(style));
  });

  group('error handling', () {
    const friendly = <String, String>{
      'INVALID_ARGUMENTS': 'Invalid verification parameters provided.',
      'NO_ACTIVITY': 'Unable to present verification screen. Please try again.',
      'NO_VIEW_CONTROLLER':
          'Unable to present verification screen. Please try again.',
      'NULL_RESULT': 'No response received from verification service.',
    };

    friendly.forEach((code, expectedMessage) {
      test('$code is turned into a friendly message', () async {
        IdentityPlatform.instance = FakeIdentityPlatform(
          () async => throw StripeIdentityException(code, 'raw'),
        );

        final (status, message) = await StripeIdentityPlugin()
            .startVerification(id: 'vs', key: 'ek');

        expect(status, VerificationResult.failed);
        expect(message, expectedMessage);
      });
    });

    test('"failed" surfaces the native message', () async {
      IdentityPlatform.instance = FakeIdentityPlatform(
        () async =>
            throw StripeIdentityException('failed', 'Camera unavailable'),
      );

      final (status, message) = await StripeIdentityPlugin().startVerification(
        id: 'vs',
        key: 'ek',
      );

      expect(status, VerificationResult.failed);
      expect(message, 'Camera unavailable');
    });

    test('unexpected errors become VerificationResult.unknown', () async {
      IdentityPlatform.instance = FakeIdentityPlatform(
        () async => throw StateError('boom'),
      );

      final (status, message) = await StripeIdentityPlugin().startVerification(
        id: 'vs',
        key: 'ek',
      );

      expect(status, VerificationResult.unknown);
      expect(message, contains('boom'));
    });
  });
}
