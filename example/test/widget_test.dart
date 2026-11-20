import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:identity_example/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('stripe_identity_plugin');

  setUp(() {
    dotenv.testLoad(
        fileInput: 'VERIFICATION_ID=vs_test\nVERIFICATION_KEY=ek_test');
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('shows the start button', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Stripe Identity Plugin'), findsOneWidget);
    expect(find.text('Start verification'), findsOneWidget);
  });

  testWidgets('forwards credentials to the plugin and shows the result', (
    WidgetTester tester,
  ) async {
    MethodCall? received;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      received = call;
      return 'canceled';
    });

    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Start verification'));
    await tester.pumpAndSettle();

    expect(received?.method, 'startVerification');
    expect((received?.arguments as Map)['id'], 'vs_test');
    expect((received?.arguments as Map)['key'], 'ek_test');
    expect(find.text('Verification is canceled.'), findsOneWidget);
  });
}
