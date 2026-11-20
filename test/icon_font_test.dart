import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

// Text renderers place a TrueType glyph by its left side bearing in `hmtx`, not by the outline's own xMin. When the
// two disagree the icon is drawn shifted sideways inside its box.
void main() {
  test('every PrimeIcons glyph has a left side bearing equal to its outline xMin', () {
    final font = ByteData.sublistView(File('fonts/PrimeIcons.ttf').readAsBytesSync());
    final tables = <String, int>{};
    for (var i = 0; i < font.getUint16(4); i++) {
      final record = 12 + i * 16;
      tables[String.fromCharCodes(Uint8List.sublistView(font, record, record + 4))] = font.getUint32(record + 8);
    }
    final glyphCount = font.getUint16(tables['maxp']! + 4);
    final metricCount = font.getUint16(tables['hhea']! + 34);
    final longOffsets = font.getInt16(tables['head']! + 50) == 1;

    int glyphOffset(int glyph) =>
        longOffsets ? font.getUint32(tables['loca']! + glyph * 4) : font.getUint16(tables['loca']! + glyph * 2) * 2;

    int leftSideBearing(int glyph) => glyph < metricCount
        ? font.getInt16(tables['hmtx']! + glyph * 4 + 2)
        : font.getInt16(tables['hmtx']! + metricCount * 4 + (glyph - metricCount) * 2);

    final mismatched = <int>[];
    for (var glyph = 0; glyph < glyphCount; glyph++) {
      if (glyphOffset(glyph + 1) == glyphOffset(glyph)) continue;
      final xMin = font.getInt16(tables['glyf']! + glyphOffset(glyph) + 2);
      if (leftSideBearing(glyph) != xMin) mismatched.add(glyph);
    }
    expect(mismatched, isEmpty, reason: 'glyph indices whose lsb differs from xMin');
  });
}
