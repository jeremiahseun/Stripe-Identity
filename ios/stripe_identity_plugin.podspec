#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint stripe_identity_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'stripe_identity_plugin'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for Stripe Identity verification'
  s.description      = <<-DESC
A Flutter plugin to integrate Stripe Identity verification in iOS and Android apps.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'EL-Joy Technologies' => 'seunjeremiah@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'stripe_identity_plugin/Sources/stripe_identity_plugin/**/*.swift'
  s.dependency 'Flutter'
  s.dependency 'StripeIdentity'
  s.platform = :ios, '15.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
