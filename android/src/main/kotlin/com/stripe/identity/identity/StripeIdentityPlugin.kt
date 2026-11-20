package com.stripe.identity.identity

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.net.Uri
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.lifecycle.Lifecycle
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
    companion object {
        private const val TAG = "StripeIdentityPlugin"
        private const val BRAND_LOGO_META_DATA_KEY = "com.stripe.identity.brand_logo_url"
        private const val BRAND_COLOR_META_DATA_KEY = "com.stripe.identity.brand_color"
    }

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
     * Called when the plugin is attached to an activity.
     *
     * @param binding The activity plugin binding.
     */
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity

        val activity = activity
        if (activity is ComponentActivity) {
            createIdentityVerificationSheet(activity, brandLogoUrl)
        }
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
                // Note: the Stripe Android SDK fixes its configuration (logo, brand color) when the
                // sheet is created, which must happen before the activity starts. Both are therefore
                // read from AndroidManifest meta-data; per-call `brandLogoUrl`/`style` values from
                // Dart cannot be applied on Android.

                val activity = activity
                if (activity is ComponentActivity &&
                    identityVerificationSheet == null &&
                    activity.lifecycle.currentState.isAtLeast(Lifecycle.State.INITIALIZED) &&
                    !activity.lifecycle.currentState.isAtLeast(Lifecycle.State.STARTED)
                ) {
                    createIdentityVerificationSheet(activity, brandLogoUrl)
                }

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
    private fun startVerification(
        id: String,
        key: String,
        result: Result
    ) {
        val activity = activity
        if (activity !is ComponentActivity) {
            // Return an error if the activity is not a ComponentActivity.
            result.error("NO_ACTIVITY", "Plugin requires a ComponentActivity.", null)
            return
        }

        pendingResult = result

        if (identityVerificationSheet == null) {
            result.error(
                "NO_SHEET",
                "Identity sheet is not initialized. Ensure plugin is attached before starting verification.",
                null
            )
            return
        }

        // Present the verification sheet on the UI thread.
        activity.runOnUiThread {
            identityVerificationSheet?.present(
                // Set the verification session ID.
                verificationSessionId = id,
                // Set the ephemeral key secret.
                ephemeralKeySecret = key
            )
        }
    }

    private fun createIdentityVerificationSheet(activity: ComponentActivity, brandLogoUrl: String?) {
        val resolvedBrandLogoUri = resolveBrandLogoUri(activity, brandLogoUrl)

        val configuration = IdentityVerificationSheet.Configuration(
            brandLogo = resolvedBrandLogoUri,
            brandColor = resolveBrandColor(activity)
        )

        identityVerificationSheet = IdentityVerificationSheet.create(
            activity,
            configuration
        ) { verificationFlowResult ->
            handleVerificationResult(verificationFlowResult, pendingResult)
        }

        Log.d(TAG, "Identity sheet initialized with brand logo URI: $resolvedBrandLogoUri")
    }

    /**
     * Reads a string `<meta-data>` value from the host app's `<application>` manifest entry.
     */
    private fun readManifestMetaData(activity: ComponentActivity, key: String): String? {
        return try {
            val appInfo = activity.packageManager.getApplicationInfo(
                activity.packageName,
                android.content.pm.PackageManager.GET_META_DATA
            )
            appInfo.metaData?.getString(key)
        } catch (error: Exception) {
            null
        }
    }

    /**
     * Resolves the optional brand color from the `com.stripe.identity.brand_color` manifest
     * meta-data entry. Accepts `#RRGGBB` or `#AARRGGBB`; returns `null` (SDK default) if the entry
     * is missing or invalid.
     */
    private fun resolveBrandColor(activity: ComponentActivity): Int? {
        val raw = readManifestMetaData(activity, BRAND_COLOR_META_DATA_KEY)
            ?.takeIf { it.isNotBlank() }
            ?: return null

        return try {
            Color.parseColor(raw.trim())
        } catch (error: IllegalArgumentException) {
            Log.w(TAG, "Ignoring invalid $BRAND_COLOR_META_DATA_KEY value \"$raw\" (expected #RRGGBB or #AARRGGBB)")
            null
        }
    }

    private fun resolveBrandLogoUri(activity: ComponentActivity, runtimeBrandLogoUrl: String?): Uri {
        runtimeBrandLogoUrl
            ?.takeIf { it.isNotBlank() }
            ?.let { return Uri.parse(it) }

        readManifestMetaData(activity, BRAND_LOGO_META_DATA_KEY)
            ?.takeIf { it.isNotBlank() }
            ?.let { return Uri.parse(it) }

        return try {
            val appInfo = activity.packageManager.getApplicationInfo(activity.packageName, 0)
            val appIconResId = appInfo.icon
            if (appIconResId != 0) {
                Uri.Builder()
                    .scheme("android.resource")
                    .authority(activity.packageName)
                    .appendPath(activity.resources.getResourceTypeName(appIconResId))
                    .appendPath(activity.resources.getResourceEntryName(appIconResId))
                    .build()
            } else {
                Uri.EMPTY
            }
        } catch (error: Exception) {
            Uri.EMPTY
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
                // Verification completed successfully.
                result?.success("completed")
            }
            is IdentityVerificationSheet.VerificationFlowResult.Canceled -> {
                // Verification canceled by the user.
                result?.success("canceled")
            }
            is IdentityVerificationSheet.VerificationFlowResult.Failed -> {
                // Return an error to Flutter with the error message.
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
        identityVerificationSheet = null

        // The new activity has not started yet, so the sheet (which registers an activity result
        // launcher) must be recreated now, otherwise every later call fails with NO_SHEET.
        val activity = activity
        if (activity is ComponentActivity) {
            createIdentityVerificationSheet(activity, brandLogoUrl)
        }
    }

    /**
     * Called when the plugin is detached from an activity.
     */
    override fun onDetachedFromActivity() {
        activity = null
        identityVerificationSheet = null
    }
}
