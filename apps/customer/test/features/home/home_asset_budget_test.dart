import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('home image assets remain within the mobile size budget', () {
    const maxAssetBytes = <String, int>{
      'hero_aleppo.webp': 48 * 1024,
      'ride_car.webp': 16 * 1024,
      'food.webp': 16 * 1024,
      'shopping.webp': 16 * 1024,
    };
    var totalBytes = 0;
    for (final entry in maxAssetBytes.entries) {
      final file = File('assets/images/${entry.key}');
      expect(file.existsSync(), isTrue, reason: 'Missing ${entry.key}');
      final size = file.lengthSync();
      totalBytes += size;
      expect(size, lessThan(entry.value), reason: '${entry.key} is oversized');
    }
    expect(totalBytes, lessThan(64 * 1024));
  });
}
