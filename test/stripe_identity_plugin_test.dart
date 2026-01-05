import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:stripe_identity_plugin/stripe_identity_plugin.dart';
import 'package:stripe_identity_plugin/stripe_identity_plugin_method_channel.dart';
import 'package:stripe_identity_plugin/stripe_identity_plugin_platform_interface.dart';
import 'package:stripe_identity_plugin/utils/identity_style.dart';

class MockIdentityPlatform
    with MockPlatformInterfaceMixin
    implements IdentityPlatform {
  @override
  Future<String> startVerification({
    required String id,
    required String key,
    String? brandLogoUrl,
    IdentityStyle? style,
  }) {
    // TODO: implement startVerification
    throw UnimplementedError();
  }
}

void main() {
  final IdentityPlatform initialPlatform = IdentityPlatform.instance;

  test('$MethodChannelIdentity is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelIdentity>());
  });

  test('startVerification', () async {
    StripeIdentityPlugin identityPlugin = StripeIdentityPlugin();
    MockIdentityPlatform fakePlatform = MockIdentityPlatform();
    IdentityPlatform.instance = fakePlatform;
  });
}
