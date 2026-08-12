import FlutterMacOS
import Foundation
import StripeIdentity

/// A Flutter plugin for Stripe Identity verification.
public class StripeIdentityPlugin: NSObject, FlutterPlugin {
    /// Registers the plugin with the Flutter engine.
    ///
    /// - Parameter registrar: The Flutter plugin registrar.
    public static func register(with registrar: FlutterPluginRegistrar) {
        // Create a Flutter method channel for communication with the Flutter application.
        let channel = FlutterMethodChannel(name: "stripe_identity_plugin", binaryMessenger: registrar.messenger)
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
        // macOS implementation of the startVerification flow is missing or requires AppKit.
        // As StripeIdentity currently doesn't natively support macOS AppKit elements in the same way it supports UIKit,
        // we'll return a not implemented for now to indicate macOS implementation might be different or unsupported directly.
        result(FlutterMethodNotImplemented)
    }
}
