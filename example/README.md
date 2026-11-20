# identity_example

Example app for the `stripe_identity_plugin` Flutter plugin.

## Running the example

1. Create a Stripe Identity **VerificationSession** and an **ephemeral key** on your
   backend (see the [Stripe docs](https://docs.stripe.com/identity/verify-identity-documents)).
2. Copy `env.example` to `.env` and fill in `VERIFICATION_ID` and `VERIFICATION_KEY`.
   `.env` is git-ignored; the app will not build without the file.
3. Run it:

   ```sh
   cd example
   flutter pub get
   flutter run
   ```

## Testing iOS with both dependency managers

```sh
# Swift Package Manager
flutter config --enable-swift-package-manager
flutter build ios --no-codesign

# CocoaPods
flutter config --no-enable-swift-package-manager
flutter build ios --no-codesign
```
