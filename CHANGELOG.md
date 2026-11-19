## 0.3.0
Brings the Flutter library up to the component set of Prime for the web (`prime-core`, plus `prime-ui`, `prime-controls`, `prime-editor`, `prime-panes` and `prime-tree`).

* **BREAKING** for files that import both `package:flutter/material.dart` and `prime_flutter`: the new `IconButton`, `Tooltip`, `Radio`, and `Checkbox` share names with Material widgets, so a file that uses the Material one now needs `import 'package:flutter/material.dart' hide IconButton, Tooltip, Radio, Checkbox;` (to switch to Prime's) or a `hide` on the `prime_flutter` import (to keep Material's). This follows the existing `Badge`/`Slider`/`Divider` convention.
* Aligned with the running `prime-core` demo site: `BadgeVariant.pending`, `progress`, and `inactive`; `ProgressVariant.dots`; a `language` on `CodeSnippet` for syntax highlighting; `CodeEditorLanguage.json5`; and `heading`, `buttonText`, `buttonIcon`, and `onButtonPressed` on `Multiselect`.
* Added `DateTimeInput` (time, date, or both), `tryFixJson` with `CodeEditor.fixJsonOnBlur`, Escape-to-close on every menu, popover, dropdown, calendar, `Modal` and `Takeover` (`Floating.onEscape`), and arrow-key navigation in `NavDropdown`.
* Added `CodeEditor`: syntax highlighting for Go, JavaScript, JSON, Python, SQL and TypeScript, a line-number gutter, line wrapping, read-only/disabled/invalid states, and a unified or split diff view (`original`, `diff`, `collapseUnchanged`) that stays editable, with deleted lines shown in place, including with `collapseUnchanged`.
* Added `Panes` and `SplitPane`: resizable split layouts driven by an immutable `LayoutNode` tree (`SplitNode`, `PaneNode`, `StackNode`), tabbed stacks, drag-to-rearrange (drag a tab or a `PaneDragTrigger` onto another pane's edge, middle, or tab strip), and the tree operations `setSplitRatio`, `movePane`, `swapPanes`, `stackPanes`, `moveStack`, `swapSlots`, `reorderPane`, `selectPane`, `removePane`, `updatePaneData`, `addPaneToUpperRight`, `findLayoutNode`, `listPanes`.
* `Panes` also supports keyboard move mode (`PaneMoveTrigger`: arrows, Tab, Enter, Escape, or tap to place) and floating windows (`FloatNode`, `FloatEntry`, `FloatRect`, with `floatPane`, `floatStack`, `setFloatRect`, `raiseFloat`, `removeFloat`, `floatEntryOf`). `PaneState` reports `isMoving`, `isFloating`, and `floatEntryId`. `Panes.floatBuilder` with `FloatWindowControls` replaces the default window chrome with your own.
* `CodeEditor` also has a search bar (Ctrl/Cmd+F: find, replace, replace all) and code folding from the gutter or with Ctrl/Cmd+Shift+[ and ].
* Added `Keybindings`, `Hotkey`, `Keybinding`, `KeybindingsRegistry`, and the formatters `formatKey`, `formatKeybinding`, `keybindingParts`.
* Added `TreeView`: expandable, selectable tree with single/multiple selection, `TreeBranchClick` modes, indent guides, and full keyboard navigation including type-ahead.
* `PrimeBanner` has two looks: `BannerAppearance.filled` (the `prime-core` banner, the default) and `BannerAppearance.outlined` (the current `prime-ui` banner).
* Added `PrimeBanner`, `SiteBanner`, and `NotificationContainer` with `Notify.of(context)` (info, warn, danger, success, pending).
* Added `IconButton`, `Tooltip`, `Floating`, `ContextMenu`, `ContextMenuItem`, `ContextMenuSeparator`, `FloatingMenu`, and `NavDropdown`.
* Added `Pill`, `StatusPill`, `Kbd`, `KbdGroup`, `InlineCode`, and `CodeSnippet`.
* Added `Label`, `NumericInput`, `SliderInput`, `RangeInput`, `VectorInput`, and `Radio`.
* Added `SearchableSelect`, `Multiselect`, and `RelativeTimePicker` (with `parseRelativeTime`, `parseDateValueString`, `formatDateValueString`).
* Added `Breadcrumbs`, `NavigationBreadcrumb` and its parts, `Expandable`, `Takeover` and its parts, and `PrimeTable`.
* Added `Field`, `Hint`, `Checkbox`, `Textarea`, and `StatusDot`. `Label`, `Input`, `Textarea`, `Checkbox` and `Hint` read `required`, `disabled` and `state` from an enclosing `Field`.
* Added `Menu` with `MenuItem`, `MenuCheckboxItem`, `MenuRadioGroup`, `MenuRadioItem`, `MenuGroup`, `MenuGroupHeading`, `MenuSub`, `MenuSeparator` and `MenuShortcut`; `Menubar`; `ContextMenuRegion`; `Popover`; and `Collapsible`.
* Added `DatePicker`, `Modal`, and `DataGrid` (sticky header, sortable columns, virtualized rows).
* Added `Combobox` (`ComboboxItem`) and `DateRangePicker` (`DateRange`), from the current web `prime-ui`. `SearchableSelect` gained `emptyText` and `onQueryChanged`.
* Added `AGGridTable` and `ColDef`, with the `columnDefs` / `rowData` / `height` shape of the web component. On the web it hosts the real AG Grid (when the `agGrid` global is present or `scriptUrl` is given) and passes `gridOptions` through; on iOS, Android, and desktop it is drawn natively by `DataGrid`.
* Tool-panel controls follow `prime-controls` 0.4.2: `PanelTextField`, `hint` and `suffix` on `NumberField`, `SliderField` and `PointField`, `state` on `NumberField` and `PointField`, and per-axis `PointAxisOptions` plus `details` on `PointField`.
* Added tool-panel controls: `Panel`, `Folder`, `ControlRow`, `NumberField`, `PointField` (`PointValue`), and `SliderField`.
* Added 75 icons to `PrimeIcons` so the set matches Prime for the web (for example `calendarBlank`, `checkboxBlankOutline`, `folder`, `fileOutline`, `eyeOutline`, `contentPaste`, `menuRight`, `sparkles`). This includes the ML icons `imageClassification`, `objectDetection`, `onnx`, `pytorch`, and `tensorflow`.
* Added `minLines`, `maxLines`, and `dense` to `Input`, and `dense` to `NumericInput`.
* Fixed `PrimeDropdown` and `PrimeMultiDropdown` asserting in debug builds when disposed.
* Added `annotated`, `onText` and `offText` to `SwitchToggle`, `state` to `PrimeDropdown`, and `disabled` to `SegmentedButton`.
* Added `test/ts_parity_test.dart`: the TypeScript library's test suites translated to Flutter, one group per spec file.
* Example app: added `integration_test_web/ag_grid_test.dart`, which drives the real AG Grid in a browser (`flutter run -d chrome -t integration_test_web/ag_grid_test.dart`).
* Example app: added `integration_test/components_test.dart`, which drives the new showcase screens on a device or simulator (`flutter test integration_test -d <device>`).
* Added `disabled`, `readOnly`, `state` (`InputState`), `inputFormatters`, and `onTap` to `Input`. Defaults leave existing inputs unchanged.
* Added status mid-tone and accent primitives to `PrimeColors`: `dangerMedium`, `infoMedium`, `successMedium`, `warningMedium`, `warningBright`, `pendingLight`, `pendingMedium`, `pendingDark`.

## 0.2.25
* Added `padding` to `Button`, for dense layouts where several buttons share a row. Defaults to `Button.defaultPadding`, so existing buttons are unchanged.
* Added `childrenPadding` to `ExpansionListItem`, so expanded children can reclaim horizontal space. Defaults to `ExpansionListItem.defaultChildrenPadding`.

## 0.2.24
* Fixed `Button` press feedback being invisible on a quick tap. Press-and-hold is unchanged.

## 0.2.23
* Added `autofillHints` and `focusNode` to `Input`, so a form can participate in platform password autofill and chain focus between fields.
* Added `textInputAction` to `Input`, for setting the keyboard's action button (e.g. next, done, search).

## 0.2.19
* Add defaultTextStyle to Toast text so it avoids yellow udnerline

## 0.2.18
* Added `centerTitle` parameter to `PrimeAppBar`. Defaults to `true`. When `false`, leading + title + actions lay out in a `Row` with the title in `Expanded` for clean overflow, and the leading slot is no longer icon-width-constrained.
* Added `onPressed` callback to `Avatar`. When provided, the avatar becomes interactive — it darkens on hover (10% black scrim) and press (20% black scrim) and shows a click cursor on web/desktop.

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
