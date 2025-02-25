import Flutter
import UIKit
import StripeIdentity

/// A Flutter plugin for Stripe Identity verification.
public class StripeIdentityPlugin: NSObject, FlutterPlugin {
    /// Registers the plugin with the Flutter engine.
    ///
    /// - Parameter registrar: The Flutter plugin registrar.
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Create a Flutter method channel for communication with the Flutter application.
        let channel = FlutterMethodChannel(name: "stripe_identity_plugin", binaryMessenger: registrar.messenger())
        // Create an instance of the plugin.
        let instance = StripeIdentityPlugin()
        // Add the plugin as a method call delegate to the channel.
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    /// Handles method calls from the Flutter application.
    ///
    /// - Parameters:
    ///   - call: The method call received from Flutter.
    ///   - result: A closure to return the result of the method call to Flutter.
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // Switch statement to handle different method calls.
        switch call.method {
        // Handle the "startVerification" method call.
        case "startVerification":
            // Extract arguments from the method call.
            guard let args = call.arguments as? [String: Any],
                  let id = args["id"] as? String,
                  let key = args["key"] as? String else {
                // Return an error if the arguments are invalid.
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing id or key", details: nil))
                return
            }
            // Extract the brand logo URL from the arguments.
            let brandLogoUrl = args["brandLogoUrl"] as? String
            // Start the verification process.
            startVerification(id: id, key: key, brandLogoUrl: brandLogoUrl, result: result)
        // Handle any other method calls.
        default:
            // Return a "not implemented" error.
            result(FlutterMethodNotImplemented)
        }
    }

    /// Starts the Stripe Identity verification flow.
    ///
    /// - Parameters:
    ///   - id: The verification session ID.
    ///   - key: The ephemeral key secret.
    ///   - brandLogoUrl: The URL of the brand logo to display.
    ///   - result: A closure to return the result of the verification flow to Flutter.
    private func startVerification(id: String, key: String, brandLogoUrl: String?, result: @escaping FlutterResult) {
        // Get the root view controller of the application.
        guard let viewController = UIApplication.shared.windows.first?.rootViewController else {
            // Return an error if the root view controller cannot be found.
            result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Unable to get the root view controller", details: nil))
            return
        }

        // Create a configuration for the IdentityVerificationSheet.
        let configuration = IdentityVerificationSheet.Configuration(
            // Load the brand logo from the URL.
            brandLogo: loadBrandLogo(from: brandLogoUrl) ?? UIImage(systemName: "plus") ?? UIImage()
        )

        // Create an instance of the IdentityVerificationSheet.
        let verificationSheet = IdentityVerificationSheet(
            // Set the verification session ID.
            verificationSessionId: id,
            // Set the ephemeral key secret.
            ephemeralKeySecret: key,
            // Set the configuration.
            configuration: configuration
        )

        // Present the verification sheet.
        verificationSheet.present(from: viewController) { verificationResult in
            // Handle the verification result.
            switch verificationResult {
            // If the flow is completed successfully.
            case .flowCompleted:
                // Return "completed" to Flutter.
                result("completed")
            // If the flow is canceled by the user.
            case .flowCanceled:
                // Return "canceled" to Flutter.
                result("canceled")
            // If the flow fails.
            case .flowFailed(let error):
                // Return an error to Flutter.
                result(FlutterError(code: "failed", message: "Verification Flow Failed", details: error.localizedDescription))
            // Handle any unknown result.
            @unknown default:
                // Return "unknown" to Flutter.
                result("unknown")
            }
        }
    }

    /// Loads the brand logo from the given URL.
    ///
    /// - Parameter urlString: The URL of the brand logo.
    /// - Returns: The brand logo image, or a default image if the URL is invalid or the image cannot be loaded.
    private func loadBrandLogo(from urlString: String?) -> UIImage? {
        // Check if the URL string is valid.
        guard let urlString = urlString,
              // Create a URL from the string.
              let url = URL(string: urlString),
              // Load the data from the URL.
              let data = try? Data(contentsOf: url),
              // Create an image from the data.
              let image = UIImage(data: data) else {
            // Return a default image if the URL is invalid or the image cannot be loaded.
            return UIImage(systemName: "plus") ?? UIImage()
        }
        // Return the loaded image.
        return image
    }
}
