# stripe_identity_plugin

A Flutter plugin for implementing Stripe Identity Verification in your Flutter applications. This package provides a seamless integration with Stripe's Identity verification service for both Android and iOS platforms.

[![pub package](https://img.shields.io/pub/v/stripe_identity_plugin.svg)](https://pub.dev/packages/stripe_identity_plugin)

## Demo

**Tests in Debug Mode**

If you provide a correct verification session and ephermal secret key:

https://github.com/user-attachments/assets/c43a1a81-7a14-4417-8048-be689d196a0e

**Tests in Debug Mode**

Otherwise, you get this screen instead:

https://github.com/user-attachments/assets/d1a343c2-17dc-4bf0-b0c6-f9347e141e79




## Getting Started

You can go to [Stripe Identity Website](https://stripe.com/identity) for more information on how to get started.
This package is not endorsed by Stripe, but it is written to work seamlessly for you. For more information on how this package works for Android, iOS and other platforms, check out [Stripe Identity Documentation](https://docs.stripe.com/identity).

## Features

- Easy integration with Stripe Identity Verification
- Support for both Android and iOS platforms
- Customizable brand logo display
- Simple error handling and result parsing
- Type-safe verification results

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  stripe_identity_plugin: ^1.0.3
```

## Usage

### Basic Implementation

```dart
final stripeIdentity = StripeIdentityPlugin();

// Start verification
final (status, message) = await stripeIdentity.startVerification(
  id: 'verification_session_id_from_your_server',
  key: 'ephemeral_key_secret_from_your_server',
  brandLogoUrl: 'https://your-domain.com/logo.png', // Optional
);

// Handle the result
switch (status) {
  case VerificationResult.completed:
    print('Verification completed successfully');
  case VerificationResult.canceled:
    print('User canceled verification');
  case VerificationResult.failed:
    print('Verification failed: $message');
  case VerificationResult.unknown:
    print('Unknown error occurred: $message');
}
```

### Important Notes

1. Call your server endpoint to obtain the `verificationSessionId` and `ephemeralKeySecret` before starting the verification process.
2. When providing a brand logo, ensure it's a square image with recommended dimensions of 32x32 points.
3. The verification flow is handled entirely by Stripe's native SDK, ensuring a secure verification process.

## Verification Results

The plugin returns a tuple containing:

- `VerificationResult`: An enum indicating the status of verification
- `String?`: Optional message providing additional details

Possible verification results:

- `completed`: User has completed document upload and verification process
- `canceled`: User canceled the verification or didn't complete the process
- `failed`: Verification failed (includes error message)
- `unknown`: Unexpected error occurred

## Requirements

- iOS 13.0 or higher
- Android API level 21 or higher
- Flutter 3.0.0 or higher

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
