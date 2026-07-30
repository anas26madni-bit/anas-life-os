import 'dart:math';

import 'package:anas_life_os/core/database/uuid_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generates RFC 4122 version 4 identifiers', () {
    final generator = UuidGenerator(random: Random(7));

    final uuid = generator.generate();

    expect(
      uuid,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-'
          r'[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });
}
