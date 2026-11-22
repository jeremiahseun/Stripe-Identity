import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stripe_identity_plugin/stripe_identity_plugin_method_channel.dart';
import 'package:stripe_identity_plugin/utils/exception.dart';
import 'package:stripe_identity_plugin/utils/identity_style.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = MethodChannelIdentity();
  const channel = MethodChannel('stripe_identity_plugin');

  MethodCall? lastCall;

  void mockHandler(Future<Object?> Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) {
          lastCall = call;
          return handler(call);
        });
  }

  setUp(() => lastCall = null);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('uses the channel the native plugins register', () {
    expect(platform.methodChannel.name, 'stripe_identity_plugin');
  });

  test('sends id, key and brand logo, and returns the native result', () async {
    mockHandler((_) async => 'completed');

    final result = await platform.startVerification(
      id: 'vs_123',
      key: 'ek_456',
      brandLogoUrl: 'https://example.com/logo.png',
    );

    expect(result, 'completed');
    expect(lastCall?.method, 'startVerification');
    expect(lastCall?.arguments, {
      'id': 'vs_123',
      'key': 'ek_456',
      'brandLogoUrl': 'https://example.com/logo.png',
    });
  });

  test('sends the style map only when a style is provided', () async {
    mockHandler((_) async => 'completed');

    await platform.startVerification(
      id: 'vs_123',
      key: 'ek_456',
      style: const IdentityStyle(buttonBackgroundColor: Color(0xFF112233)),
    );

    final args = lastCall?.arguments as Map;
    expect(args['style'], {'buttonBackgroundColor': 0xFF112233});
  });

  test('converts PlatformException to StripeIdentityException', () async {
    mockHandler(
      (_) async =>
          throw PlatformException(code: 'INVALID_ARGUMENTS', message: 'bad'),
    );

    expect(
      () => platform.startVerification(id: 'vs_123', key: 'ek_456'),
      throwsA(
        isA<StripeIdentityException>()
            .having((e) => e.code, 'code', 'INVALID_ARGUMENTS')
            .having((e) => e.message, 'message', 'bad'),
      ),
    );
  });

  test('throws NULL_RESULT when the platform returns null', () async {
    mockHandler((_) async => null);

    expect(
      () => platform.startVerification(id: 'vs_123', key: 'ek_456'),
      throwsA(
        isA<StripeIdentityException>().having(
          (e) => e.code,
          'code',
          'NULL_RESULT',
        ),
      ),
    );
  });
}
