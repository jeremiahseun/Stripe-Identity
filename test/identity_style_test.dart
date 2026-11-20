// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:ui' show Color;

import 'package:flutter_test/flutter_test.dart';
import 'package:stripe_identity_plugin/utils/identity_style.dart';

void main() {
  test('an empty style serializes to an empty map', () {
    expect(const IdentityStyle().toMap(), isEmpty);
  });

  test('colors are encoded as 32-bit ARGB integers', () {
    const style = IdentityStyle(
      buttonBackgroundColor: Color(0xFF112233),
      buttonTextColor: Color(0x80FFFFFF),
    );

    expect(style.toMap(), {
      'buttonBackgroundColor': 0xFF112233,
      'buttonTextColor': 0x80FFFFFF,
    });
  });

  test('only provided values are included', () {
    const style = IdentityStyle(buttonLabel: 'Continue');

    expect(style.toMap(), {'buttonLabel': 'Continue'});
  });
}
