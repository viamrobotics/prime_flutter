"""Add Material Design Icons glyphs to fonts/PrimeIcons.ttf.

PrimeIcons follows Material Design Icons (https://pictogrammers.com/library/mdi/, Apache 2.0): each glyph is the MDI
24x24 outline scaled to 1000 units per em with its top at y=850, which is how the existing glyphs were generated.

Usage (from the package root):

    python3 -m venv /tmp/venv && /tmp/venv/bin/pip install fonttools
    npm pack @mdi/svg && tar xzf mdi-svg-*.tgz   # gives package/svg/<name>.svg
    /tmp/venv/bin/python tool/add_mdi_icons.py package/svg bluetooth wifi lock-outline

Each name gets the next free code point after the highest one in the font, in the order given. The script prints a
`static const IconData` line per glyph to paste into lib/src/widgets/prime_icons.dart. A name already in the font is
skipped. Left side bearings are set to each outline's xMin (test/icon_font_test.dart checks this).
"""

import re
import sys
from pathlib import Path

from fontTools.pens.cu2quPen import Cu2QuPen
from fontTools.pens.transformPen import TransformPen
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.svgLib.path import parse_path
from fontTools.ttLib import TTFont

FONT = Path(__file__).resolve().parent.parent / "fonts" / "PrimeIcons.ttf"
SCALE = 1000 / 24
TOP = 850
ADVANCE = 1000


def camel(name: str) -> str:
    head, *rest = name.split("-")
    return head + "".join(part[:1].upper() + part[1:] for part in rest)


def glyph_from_svg(svg: Path):
    paths = re.findall(r'<path[^>]* d="([^"]+)"', svg.read_text())
    if not paths:
        sys.exit(f"no <path> in {svg}")
    pen = TTGlyphPen(None)
    target = TransformPen(Cu2QuPen(pen, max_err=1.0, reverse_direction=True), (SCALE, 0, 0, -SCALE, 0, TOP))
    for d in paths:
        parse_path(d, target)
    return pen.glyph()


def main() -> None:
    if len(sys.argv) < 3:
        sys.exit(__doc__)
    svg_dir = Path(sys.argv[1])
    font = TTFont(FONT)
    order = font.getGlyphOrder()
    cmap = font.getBestCmap()
    next_cp = max(cmap) + 1
    for name in sys.argv[2:]:
        if name in order:
            print(f"// skipped {name}: already in the font", file=sys.stderr)
            continue
        glyph = glyph_from_svg(svg_dir / f"{name}.svg")
        glyph.recalcBounds(font["glyf"])
        font["glyf"][name] = glyph  # also appends name to the glyph order
        if name not in order:
            order.append(name)
        font["hmtx"][name] = (ADVANCE, glyph.xMin)
        for table in font["cmap"].tables:
            if table.isUnicode():
                table.cmap[next_cp] = name
        print(f"  static const IconData {camel(name)} = IconData(0x{next_cp:x}, fontFamily: _ff, fontPackage: _fp);")
        next_cp += 1
    font.setGlyphOrder(order)
    font["maxp"].numGlyphs = len(order)
    font.save(FONT)


if __name__ == "__main__":
    main()
