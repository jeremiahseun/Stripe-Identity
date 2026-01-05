import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'stripe_identity_plugin_method_channel.dart';
import 'utils/identity_style.dart';

abstract class IdentityPlatform extends PlatformInterface {
  /// Constructs a IdentityPlatform.
  IdentityPlatform() : super(token: _token);

  static final Object _token = Object();

  static IdentityPlatform _instance = MethodChannelIdentity();

  /// The default instance of [IdentityPlatform] to use.
  ///
  /// Defaults to [MethodChannelIdentity].
  static IdentityPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IdentityPlatform] when
  /// they register themselves.
  static set instance(IdentityPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String> startVerification({
    required String id,
    required String key,
    String? brandLogoUrl,
    IdentityStyle? style,
  }) {
    throw UnimplementedError('startVerification() has not been implemented.');
  }
}
