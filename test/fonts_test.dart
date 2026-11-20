import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prime_flutter/prime_flutter.dart';

void main() {
  test('every text style but label uses the bundled Public Sans', () {
    final theme = PrimeThemeData.light().textTheme;
    for (final TextStyle style in [theme.heading, theme.title, theme.bodyDefault, theme.bodySmall, theme.link]) {
      expect(style.fontFamily, 'packages/prime_flutter/Public Sans');
    }
    expect(theme.label.fontFamily, 'packages/prime_flutter/RobotoMono');
  });

  test('pubspec declares a Public Sans file for each weight the text styles use', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final family = pubspec.substring(pubspec.indexOf('- family: Public Sans'));
    for (final (file, weight) in [('Regular', null), ('Medium', 500), ('SemiBold', 600), ('Bold', 700)]) {
      final asset = 'fonts/PublicSans-$file.ttf';
      expect(File(asset).existsSync(), isTrue, reason: asset);
      final declared = weight == null ? '- asset: $asset' : '- asset: $asset\n          weight: $weight';
      expect(family, contains(declared));
    }
  });

  // The Flutter tool reads NOTICES in place of LICENSE, and splits it on this separator into
  // "names, blank line, license text" sections that become LicenseRegistry entries.
  test('NOTICES gives the Flutter tool the package license and the Public Sans license', () {
    final sections = File('NOTICES').readAsStringSync().split('\n${'-' * 80}\n');
    final byName = {
      for (final section in sections) section.substring(0, section.indexOf('\n\n')): section.substring(section.indexOf('\n\n') + 2),
    };
    expect(byName.keys, ['prime_flutter', 'Public Sans']);
    expect(byName['prime_flutter']!.trim(), File('LICENSE').readAsStringSync().trim());
    expect(byName['Public Sans'], contains('SIL OPEN FONT LICENSE Version 1.1'));
    expect(byName['Public Sans'], contains('The Public Sans Project Authors'));
  });
}
