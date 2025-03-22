package com.stripe.identity.identity

import android.app.Activity
import android.content.Context
import android.net.Uri
import androidx.fragment.app.FragmentActivity
import com.stripe.android.identity.IdentityVerificationSheet
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * A Flutter plugin for Stripe Identity verification.
 */
class StripeIdentityPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /**
     * The Flutter method channel used to communicate with the Flutter application.
     */
    private lateinit var channel: MethodChannel

    /**
     * The Android application context.
     */
    private lateinit var context: Context

    /**
     * The current activity.
     */
    private var activity: Activity? = null

    /**
     * The IdentityVerificationSheet instance.
     */
    private var identityVerificationSheet: IdentityVerificationSheet? = null

    /**
     * The result callback to return to Flutter.
     */
    private var pendingResult: Result? = null

    /**
     * The verification session ID.
     */
    private var verificationSessionId: String? = null

    /**
     * The ephemeral key secret.
     */
    private var ephemeralKeySecret: String? = null

    /**
     * The brand logo URL.
     */
    private var brandLogoUrl: String? = null

    /**
     * Called when the plugin is attached to the Flutter engine.
     *
     * @param flutterPluginBinding The Flutter plugin binding.
     */
    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        // Create a method channel for communication with the Flutter application.
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "stripe_identity_plugin")
        // Set the method call handler for the channel.
        channel.setMethodCallHandler(this)
        // Get the application context.
        context = flutterPluginBinding.applicationContext
    }

    /**
     * Called when a method call is received from the Flutter application.
     *
     * @param call The method call received from Flutter.
     * @param result A closure to return the result of the method call to Flutter.
     */
    override fun onMethodCall(call: MethodCall, result: Result) {
        // Handle the "startVerification" method call.
        when (call.method) {
            "startVerification" -> {
                // Extract the verification session ID, ephemeral key secret, and brand logo URL from the method call arguments.
                val id = call.argument<String>("id")
                val key = call.argument<String>("key")
                brandLogoUrl = call.argument<String>("brandLogoUrl")

                // Start the verification process if the required arguments are provided.
                if (id != null && key != null) {
                    startVerification(id, key, result)
                } else {
                    // Return an error if the required arguments are missing.
                    result.error("INVALID_ARGUMENTS", "Missing id or key", null)
                }
            }
            // Handle any other method calls.
            else -> result.notImplemented()
        }
    }

    /**
     * Starts the Stripe Identity verification flow.
     *
     * @param id The verification session ID.
     * @param key The ephemeral key secret.
     * @param result A closure to return the result of the verification flow to Flutter.
     */
    private fun startVerification(id: String, key: String, result: Result) {
        val activity = activity
        if (activity !is FragmentActivity) {
            result.error("NO_ACTIVITY", "Plugin requires a FragmentActivity.", null)
            return
        }

        pendingResult = result
        verificationSessionId = id
        ephemeralKeySecret = key

        activity.runOnUiThread {
            identityVerificationSheet?.present(
                verificationSessionId = id,
                ephemeralKeySecret = key
            )
        }
    }

    /**
     * Handles the verification result from the IdentityVerificationSheet.
     *
     * @param verificationResult The verification result.
     * @param result A closure to return the result to Flutter.
     */
    private fun handleVerificationResult(
        verificationResult: IdentityVerificationSheet.VerificationFlowResult,
        result: Result?
    ) {
        when (verificationResult) {
            is IdentityVerificationSheet.VerificationFlowResult.Completed -> {
                result?.success("completed")
            }
            is IdentityVerificationSheet.VerificationFlowResult.Canceled -> {
                result?.success("canceled")
            }
            is IdentityVerificationSheet.VerificationFlowResult.Failed -> {
                result?.error(
                    "failed",
                    verificationResult.throwable.localizedMessage,
                    null
                )
            }
        }
    }

    /**
     * Called when the plugin is detached from the Flutter engine.
     *
     * @param binding The Flutter plugin binding.
     */
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        // Remove the method call handler to avoid leaks.
        channel.setMethodCallHandler(null)
    }

    /**
     * Called when the plugin is attached to an activity.
     *
     * @param binding The activity plugin binding.
     */
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity

        if (activity is FragmentActivity) {
            val configuration = IdentityVerificationSheet.Configuration(
                brandLogo = brandLogoUrl?.let { Uri.parse(it) } ?: Uri.EMPTY
            )
            identityVerificationSheet = IdentityVerificationSheet.create(
                activity as FragmentActivity,
                configuration
            ) { verificationFlowResult ->
                handleVerificationResult(verificationFlowResult, pendingResult)
            }
        }
    }

    /**
     * Called when the activity is detached due to configuration changes.
     */
    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
        identityVerificationSheet = null
    }

    /**
     * Called when the activity is reattached after configuration changes.
     *
     * @param binding The activity plugin binding.
     */
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    /**
     * Called when the plugin is detached from an activity.
     */
    override fun onDetachedFromActivity() {
        activity = null
        identityVerificationSheet = null
    }
}
