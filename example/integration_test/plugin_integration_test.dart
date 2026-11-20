// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://docs.flutter.dev/cookbook/testing/integration/introduction

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:stripe_identity_plugin/stripe_identity_plugin.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('startVerification returns a message on the host platform',
      (WidgetTester tester) async {
    final StripeIdentityPlugin plugin = StripeIdentityPlugin();
    final result = await plugin.startVerification(id: "id", key: "key");
    // Invalid credentials are rejected by the native SDK, so we only assert that
    // a non-empty message comes back.
    expect(result.$2?.isNotEmpty, true);
  });
}
