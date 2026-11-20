package com.stripe.identity.identity

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlin.test.Test
import org.mockito.Mockito

/*
 * Unit tests for the parts of the plugin that do not need a real Activity.
 *
 * Run them with `./gradlew :stripe_identity_plugin:testDebugUnitTest` from the
 * `example/android/` directory (after building the example app once).
 */
internal class IdentityPluginTest {

  private fun newResult(): MethodChannel.Result =
    Mockito.mock(MethodChannel.Result::class.java)

  @Test
  fun unknownMethod_returnsNotImplemented() {
    val result = newResult()

    StripeIdentityPlugin().onMethodCall(MethodCall("getPlatformVersion", null), result)

    Mockito.verify(result).notImplemented()
  }

  @Test
  fun startVerification_withoutIdOrKey_returnsInvalidArguments() {
    val result = newResult()
    val call = MethodCall("startVerification", mapOf("brandLogoUrl" to "https://example.com/logo.png"))

    StripeIdentityPlugin().onMethodCall(call, result)

    Mockito.verify(result).error("INVALID_ARGUMENTS", "Missing id or key", null)
  }

  @Test
  fun startVerification_withoutAttachedActivity_returnsNoActivity() {
    val result = newResult()
    val call = MethodCall("startVerification", mapOf("id" to "vs_123", "key" to "ek_456"))

    StripeIdentityPlugin().onMethodCall(call, result)

    Mockito.verify(result).error("NO_ACTIVITY", "Plugin requires a ComponentActivity.", null)
  }
}
