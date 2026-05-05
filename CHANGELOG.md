## 0.2.17
* Added `ListItemGroup` widget.
* Added `surfaceHover` token to `PrimeColorScheme` for a light → medium → dark progression on hover/press states. **BREAKING** for code that constructs `PrimeColorScheme` directly — `surfaceHover` is now required.
* Reworked interactive color animation on `ListItem` and `Button`:
  * `ListItem` hover/press now step through `surfaceOffset` → `surfaceHover` → `surfaceHighlight` instead of jumping directly to the press color.
  * Fixed mid-tween dark flash on the standard `ListItem` variant (caused by interpolating from transparent black).
  * Primary `Button` now darkens through three phases (`gray9` → `gray9_5` → pure black) to match Prime web's primary action.
* Added grayscale primitives `gray1_5`, `gray7_5`, `gray9_5`, and `black` to `PrimeColors`.

## 0.2.16
* Allocate extra space for app bar.

## 0.2.15
* Add dialog
* Add switch

## 0.2.14
* Added `PrimeDropdown` widget for single-select from a list.
* Added `PrimeMultiDropdown` widget for multi-select from a list.

## 0.2.11
* Added `SegmentedButton` widget.

## 0.2.10

* Added `onChangedEnd` callback to `Slider` widget.

## 0.2.9

* Added `Slider` widget with custom colors, ranges, and divisions.

## 0.2.4
* added ghost button disabled state

## 0.2.0

* **BREAKING**: `Button`'s `label` parameter is now a `Widget?` instead of a `String`.
* **BREAKING**: `Badge`'s `child` parameter is now a `Widget?` instead of a `Widget`, and is optional.
* **BREAKING**: `ExpansionListItem`'s `title` parameter is now a `Widget?` instead of a `Widget`, and is optional.
* **BREAKING**: `BottomSheet`'s `show` method `title` parameter is now a `Widget?` instead of a `String?`.
* **BREAKING**: `NavigationBar`'s `NavigationBarItemData` `label` parameter is now a `Widget?` instead of a `String`.
* **BREAKING**: `TabBar`'s `items` parameter is now `List<Widget>` instead of `List<String>`.

## 0.0.1

* TODO: Describe initial release.
