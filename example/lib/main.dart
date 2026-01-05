import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:stripe_identity_plugin/stripe_identity_plugin.dart';
import 'package:stripe_identity_plugin/utils/enum.dart';
import 'package:stripe_identity_plugin/utils/identity_style.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _identityPlugin = StripeIdentityPlugin();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Stripe Identity Plugin'),
        ),
        body: Builder(builder: (context) {
          return Center(
            child: ElevatedButton(
                onPressed: () async {
                  //* Show the loading indicator
                  setState(() {
                    isLoading = true;
                  });

                  //* Call the identity plugin
                  final response = await _identityPlugin.startVerification(
                    id: dotenv.env['VERIFICATION_ID']!,
                    key: dotenv.env['VERIFICATION_KEY']!,
                    brandLogoUrl:
                        "https://img.icons8.com/?size=128&id=77153&format=png",
                    style: const IdentityStyle(
                      buttonBackgroundColor: Colors.blue,
                      buttonTextColor: Colors.white,
                      navigationBarTitle: "Stripe Identity Example",
                    ),
                  );

                  //* Hide the loading indicator
                  setState(() {
                    isLoading = false;
                  });

                  //* Display a [snackbar] depending on the status of the verification
                  if (!context.mounted) return;
                  switch (response.$1) {
                    case VerificationResult.completed:
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text(response.$2 ?? "Verification completed")));
                      break;
                    case VerificationResult.failed:
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(response.$2 ?? "Verification failed")));
                    default:
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(response.$2 ??
                              "Verification couldn't be completed")));
                  }
                },
                child: isLoading
                    ? const CircularProgressIndicator.adaptive(
                        backgroundColor: Colors.black,
                      )
                    : const Text("Start verification")),
          );
        }),
      ),
    );
  }
}
