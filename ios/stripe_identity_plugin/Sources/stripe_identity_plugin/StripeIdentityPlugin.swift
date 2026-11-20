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
            // Extract the style configuration from the arguments.
            let styleMap = args["style"] as? [String: Any]
            // Start the verification process.
            startVerification(id: id, key: key, brandLogoUrl: brandLogoUrl, styleMap: styleMap, result: result)
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
    ///   - styleMap: Optional styling configuration from Flutter.
    ///   - result: A closure to return the result of the verification flow to Flutter.
    private func startVerification(id: String, key: String, brandLogoUrl: String?, styleMap: [String: Any]?, result: @escaping FlutterResult) {
        // Get the top-most view controller of the foreground window scene.
        guard let viewController = topViewController() else {
            // Return an error if the root view controller cannot be found.
            result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Unable to get the root view controller", details: nil))
            return
        }

        // Create a configuration for the IdentityVerificationSheet.
        let configuration = makeConfiguration(
            // Load the brand logo from the URL.
            brandLogo: loadBrandLogo(from: brandLogoUrl) ?? appIconImage() ?? UIImage(),
            styleMap: styleMap
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

    /// Builds the Stripe sheet configuration.
    ///
    /// `Configuration.brandColor` only exists in stripe-ios 26.16.0 and later. The Swift Package
    /// declares `from: "26.16.0"`, so the API is always available there. CocoaPods trunk stops at
    /// StripeIdentity 26.15.0, so CocoaPods builds compile without it and ignore the brand color.
    ///
    /// - Parameters:
    ///   - brandLogo: The brand logo image.
    ///   - styleMap: Optional styling configuration from Flutter.
    private func makeConfiguration(brandLogo: UIImage, styleMap: [String: Any]?) -> IdentityVerificationSheet.Configuration {
        #if SWIFT_PACKAGE
        var configuration = IdentityVerificationSheet.Configuration(brandLogo: brandLogo)
        // The only public styling option besides the logo; the SDK picks black or white button
        // text for contrast.
        configuration.brandColor = brandColor(from: styleMap)
        return configuration
        #else
        return IdentityVerificationSheet.Configuration(brandLogo: brandLogo)
        #endif
    }

    /// Finds the view controller the verification sheet should be presented from.
    ///
    /// Uses the foreground-active window scene (falling back to any connected scene) and walks up
    /// to the top-most presented view controller, so presenting works in multi-scene apps and when
    /// another view controller is already being presented.
    private func topViewController() -> UIViewController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let scene = scenes.first(where: { $0.activationState == .foregroundActive }) ?? scenes.first
        let window = scene?.windows.first(where: { $0.isKeyWindow }) ?? scene?.windows.first
        var top = window?.rootViewController
        while let presented = top?.presentedViewController {
            top = presented
        }
        return top
    }

    /// Reads the optional brand color from the style map sent by Flutter.
    ///
    /// Flutter encodes colors as 32-bit ARGB integers (`Color.toARGB32()`).
    ///
    /// - Parameter styleMap: The style configuration from Flutter, if any.
    /// - Returns: The brand color, or `nil` to use the Stripe SDK default.
    private func brandColor(from styleMap: [String: Any]?) -> UIColor? {
        guard let argb = (styleMap?["buttonBackgroundColor"] as? NSNumber)?.uint32Value else {
            return nil
        }
        let alpha = CGFloat((argb >> 24) & 0xFF) / 255
        let red = CGFloat((argb >> 16) & 0xFF) / 255
        let green = CGFloat((argb >> 8) & 0xFF) / 255
        let blue = CGFloat(argb & 0xFF) / 255
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    /// Loads the brand logo from the given URL.
    ///
    /// - Parameter urlString: The URL of the brand logo.
    /// - Returns: The brand logo image, or `nil` if the URL is missing or invalid, or the image cannot be loaded.
    private func loadBrandLogo(from urlString: String?) -> UIImage? {
        guard let urlString = urlString,
              let url = URL(string: urlString),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return UIImage(data: data)
    }

    /// The host app's primary icon, used as the brand logo when no logo URL is provided or it fails to load.
    ///
    /// This mirrors the Android plugin, which falls back to the application icon. It reads the
    /// primary icon declared in the app's Info.plist (`CFBundleIcons`).
    ///
    /// - Returns: The app icon, or `nil` if it cannot be resolved (the caller then uses an empty image).
    private func appIconImage() -> UIImage? {
        guard let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconName = iconFiles.last else {
            return nil
        }
        return UIImage(named: iconName)
    }
}
