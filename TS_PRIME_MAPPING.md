# TS Prime to Flutter Prime mapping

Where each component of the TypeScript (Svelte) Prime lives in `prime_flutter`. Use this when porting a screen from the web app, or when checking whether a TS component has a Flutter counterpart yet.

Last checked Nov 23, 2026 against `viamrobotics/prime` at `358fda7e` and `prime_flutter` at `f028220` plus the chart port.

## Sources

| What | Where |
| --- | --- |
| TS Prime v2 (current) | `viamrobotics/prime` monorepo, packages under `packages/`. Public docs: viamrobotics.github.io/prime |
| TS Prime v1 (legacy, `@viamrobotics/prime-core`) | `viamrobotics/app`, folder `prime/`, exports in `prime/src/lib/index.ts` |
| Flutter Prime | this repo. Every public widget is exported from `lib/prime_flutter.dart`; sources are in `lib/src/widgets/` |

TS package versions at the time of the check: `prime-ui` 0.6.0, `prime-controls` 0.5.0, `prime-panes` 0.1.3, `prime-tree` 0.1.3, `prime-editor` 0.1.1, `prime-charts` 0.2.0.

## How the two differ

- **Compound parts become constructor arguments.** TS components are built from parts (`Dialog.Trigger`, `Dialog.Content`, `Dialog.Title`). The Flutter widgets take the same pieces as named arguments or child lists. Parts are only separate classes where the table says so.
- **No drop shadows.** TS gives floating panels `shadow-popover` and dialogs `shadow-dialog`. Flutter Prime is flat: outlines and borders only. Do not port a shadow.
- **No Material or Cupertino.** Flutter Prime is built on `package:flutter/widgets.dart` alone. Several names (`Switch`, `Slider`, `Dialog`, `Scaffold`, `AppBar`, `TextField`, `Tooltip`, `Checkbox`, `Radio`) clash with Material, so hide them from one import when a file needs both.
- **Context providers become inherited widgets.** `provideX` / `useX` pairs map to a widget placed above the tree plus a static `of(context)`.
- **Popups share one primitive.** Anything anchored (menus, tooltips, selects, pickers) is built on `Floating` in `floating.dart`. Reach for it when a TS component has no direct counterpart.

## prime-ui

| TS | Flutter | File | Notes |
| --- | --- | --- | --- |
| `Banner` (+ `Icon`, `Title`, `Description`, `Actions`, `Details`, `Close`, `Progress`) | `PrimeBanner` | `banner.dart` | Parts are arguments. `BannerVariant`, `BannerSize`, `BannerAppearance` |
| `Breadcrumbs` (+ `Item`, `Link`, `Page`, `Separator`, `Ellipsis`) | `Breadcrumbs`, `NavigationBreadcrumb`, `NavigationBreadcrumbLink`, `NavigationBreadcrumbPage`, `NavigationBreadcrumbSeparator`, `NavigationBreadcrumbEllipsis` | `breadcrumbs.dart` | Parts are separate classes |
| `Checkbox` | `Checkbox` | `field.dart` | |
| `clickOutside` | `Floating.onTapOutside`, or Flutter's `TapRegion` | `floating.dart` | |
| `CodeSnippet` | `CodeSnippet`, `InlineCode`, `highlightCode()` | `code_snippet.dart` | |
| `Collapsible` (+ `Trigger`, `Content`) | `Collapsible` | `popover.dart` | `Expandable` in `expandable.dart` is the v1 equivalent |
| `Combobox` (+ parts) | `Combobox`, `ComboboxItem` | `searchable_select.dart` | |
| `ContextMenu` (+ parts) | `ContextMenuRegion` with the `Menu` item classes in `items` | `menu.dart` | The Flutter class named `ContextMenu` in `context_menu.dart` is the v1 popup list, not this |
| `DatePicker` (+ `Field`, `Trigger`, `Content`, `Calendar`) | `DatePicker` | `relative_time_picker.dart` | |
| `DateRangePicker`, `DateRange` | `DateRangePicker`, `DateRange` | `relative_time_picker.dart` | |
| `Dialog` (+ `Trigger`, `Content`, `Title`, `Description`, `Close`) | `Dialog.show(...)` with `DialogAction`s | `dialog.dart` | Imperative, no trigger part. `Modal` in `modal.dart` is the declarative v1 form |
| `Field`, `fieldState`, `FieldState` | `Field`; state is `InputState` | `field.dart`, `input.dart` | Use `Field` for label, hint and validation message around any control |
| `FileInput` | none | | Not ported |
| `Hint` | `Hint` | `field.dart` | |
| `Icon`, `IconType`, `IconSize` | Flutter's `Icon` with `PrimeIcons.<name>` | `prime_icons.dart` | Icon font in `fonts/PrimeIcons.ttf`. Names are camelCase versions of the TS kebab-case names |
| `Input`, `Input.Group` | `Input` (`leading`, `trailing`) | `input.dart` | `RawInput` in `raw_input.dart` is the unstyled editable underneath |
| Keybindings: `createKeybindings`, `provideKeybindings`, `useKeybindings`, `useKeybinding`, `useHotkey`, `formatKey`, `formatKeybinding`, `keybindingParts` | `Keybindings` (provider widget), `KeybindingsRegistry.of(context)`, `Hotkey`, `Keybinding`, `KeyPress`, `formatKey()`, `formatKeybinding()`, `keybindingParts()` | `keybindings.dart` | |
| `Label` | `Label`, `LabelPosition` | `label.dart` | |
| `Menu` (+ `Trigger`, `Content`, `Item`, `CheckboxItem`, `RadioGroup`, `RadioItem`, `Sub`, `Separator`, `Group`, `GroupHeading`, `Shortcut`) | `Menu`, `MenuItem`, `MenuCheckboxItem`, `MenuRadioGroup`, `MenuRadioItem`, `MenuSub`, `MenuSeparator`, `MenuGroup`, `MenuGroupHeading`, `MenuShortcut` | `menu.dart` | The trigger is the `Menu`'s child |
| `Menubar` (+ `Menu` and the menu parts) | `Menubar`, `MenubarMenu` | `menu.dart` | |
| `MultiSelect` | `MultiDropdown` (or `Multiselect` with search) | `dropdown.dart`, `searchable_select.dart` | |
| `Notify`, `provideNotify`, `useNotify`, `NotifyHandle` | `NotificationContainer` above the tree, `Notify.of(context)`, `NotificationHandle` | `notification.dart` | |
| `NumberInput` | `NumericInput` | `numeric_input.dart` | `NumericInputType` is `number` or `integer` |
| `Popover` (+ `Trigger`, `Content`, `Close`) | `Popover` | `popover.dart` | |
| `Progress` | `Progress`, `ProgressVariant` | `progress.dart` | |
| `RadioGroup` | `Radio` with `RadioOption`s | `radio.dart` | |
| `Select` (+ parts), `SelectOption` | `Dropdown` | `dropdown.dart` | `SearchableSelect` in `searchable_select.dart` adds type-to-filter |
| `StatusDot` | `StatusDot`, `StatusDotState`, `StatusDotVariant` | `field.dart` | |
| `Switch` | `Switch` | `switch_toggle.dart` | |
| `Tabs` (+ `List`, `Trigger`, `Content`) | `TabBar` | `tab_bar.dart` | Tab strip only. The caller swaps the content |
| `Takeover` (+ `Trigger`, `Content`, `Header`, `Title`, `Close`) | `Takeover`, `TakeoverHeader`, `TakeoverTitle`, `TakeoverClose` | `takeover.dart` | |
| `Textarea` | `Textarea` | `field.dart` | |
| `Toast`, `provideToast`, `useToast` | `Toast.show(context, ...)`, `ToastVariant` | `toast.dart` | No provider needed |
| `ToggleButtons` | `SegmentedButton` | `segmented_button.dart` | |
| `Tooltip` (+ `Trigger`, `Content`) | `Tooltip`, `TooltipVisibility` | `tooltip.dart` | The trigger is the child |

## prime-controls

All in `controls.dart` unless noted.

| TS | Flutter | Notes |
| --- | --- | --- |
| `Panel` | `Panel` | |
| `Folder` | `Folder` | |
| `NumberField` | `NumberField`, `NumberFieldLabelPlacement` | |
| `Point`, `PointAxisOptions`, `PointValue` | `PointField`, `PointAxisOptions`, `PointValue` | |
| `Slider` | `SliderField` | The plain `Slider` in `slider.dart` is the mobile slider, not this |
| `TextField` | `TextField` (alias `PanelTextField`) | Use the alias when Material is also imported |
| `Select` | none compact. Put a `Dropdown` in a `ControlRow` | |
| `Tabs` | none compact. Use `TabBar` | |
| `ToggleButtons` | none compact. Put a `SegmentedButton` in a `ControlRow` | |
| `FileField` | none | Not ported |

`ControlRow` is the Flutter-only helper that lays out a label beside any control in a `Panel`.

## prime-panes

All in `panes.dart`.

| TS | Flutter | Notes |
| --- | --- | --- |
| `Panes` | `Panes` | |
| `Panes.DragTrigger`, `Panes.MoveTrigger` | `PaneDragTrigger`, `PaneMoveTrigger` | |
| `Panes.PaneBody`, `Panes.TabList`, `Panes.TabListDropRegion` | built by `Panes` through `paneBuilder` and `tabBuilder` | `PaneCenterDrop` and `FloatWindowControls` cover the drop target and float chrome |
| `SplitPanes`, `setSplitRatio` | `SplitPane` | |
| `LayoutNode`, `PaneNode`, `SplitNode`, `StackNode`, `FloatNode`, `FloatEntry`, `FloatRect`, `SplitDirection`, `SplitKey`, `PaneState` | same names | Immutable sealed classes |
| Tree operations (`movePane`, `removePane`, `stackPanes`, `swapPanes`, `floatPane`, `setFloatRect`, and the rest of `tree.ts`) | same names, top-level functions | Pure functions that return a new tree |
| `dragIgnore`, `DragPreview` | none | Not needed: gesture handling differs |

## prime-tree

| TS | Flutter | File | Notes |
| --- | --- | --- | --- |
| `Tree` (+ `Branch`, `BranchControl`, `BranchTrigger`, `BranchContent`, `Item`, `Indicator`, `IndentGuide`, `Row`) | `TreeView` | `tree_view.dart` | Not headless. Rows are drawn by `TreeView` and customised through `nodeBuilder` |
| `TreeAccessors` | `nodeToValue`, `nodeToString`, `nodeToChildren` and related callbacks on `TreeView` | `tree_view.dart` | |
| `TreeNodeState`, `TreeBranchClick` | `TreeNodeState`, `TreeBranchClick`, `TreeSelectionMode` | `tree_view.dart` | |

## prime-editor

| TS | Flutter | File | Notes |
| --- | --- | --- | --- |
| `CodeEditor`, `CodeEditorLanguage`, `CodeEditorDiff` | same names | `code_editor.dart` | Not CodeMirror. A regex tokenizer per language on top of `RawInput`. `tryFixJson()` is exported alongside |

## prime-charts

All in `chart.dart`. The arithmetic (ticks, domains, point search) is in `internal/chart_math.dart` and follows d3, so both charts put ticks in the same places.

| TS | Flutter | Notes |
| --- | --- | --- |
| `Chart` | `Chart` | Takes `series`, the bounds, `loading`, `empty`, and the axis formats `xFormat` and `yFormat`. `aria-label` is `semanticLabel` |
| `Chart.Plot` | `ChartPlot` | Size it with a `SizedBox` or `Expanded`. 256 tall when the layout gives no height |
| `Chart.Line` | `ChartSeries` in `Chart.series` | Data, not a widget. `color` is a `Color`, not a CSS variable |
| `ChartPoint`, `ChartXValue` | `ChartPoint(DateTime, double?)`, `ChartPoint.millis` | |
| `Chart.XAxis`, `Chart.YAxis`, `Chart.Grid`, `Chart.Tooltip` | `ChartPlot(xAxis:, yAxis:, grid:, tooltip:)` | On by default. A `min-w-*` on the y axis is `yAxisMinWidth`; tooltip formats are `tooltipXFormat` and `tooltipYFormat` |
| `Chart.Legend` | `ChartLegend` | A legend toggle is reported through `Chart.onSeriesHiddenChanged` |
| `Chart.Table` | `ChartTable` | |
| `ChartScale` | none | Time is the only scale in both |

Not carried over: the per-part `class` hooks, and paint order by mount order (Flutter always paints grid, axes, lines, then the marker).

## prime-core (v1, legacy)

Only the v1 components that have no v2 row above.

| TS | Flutter | File |
| --- | --- | --- |
| `AGGridTable` | `AGGridTable`, `ColDef` (real AG Grid on web), `DataGrid` (pure Flutter, every platform) | `data_grid.dart`, `ag_grid/` |
| `Badge` | `Badge`, `BadgeVariant` | `badge.dart` |
| `Button`, `IconButton` | `Button`, `IconButton` | `button.dart`, `icon_button.dart` |
| `Expandable` | `Expandable` | `expandable.dart` |
| `floating` helpers | `Floating`, `FloatingPlacement` | `floating.dart` |
| `InlineCode` | `InlineCode` | `code_snippet.dart` |
| `Kbd`, `KbdGroup` | `Kbd`, `KbdGroup` | `kbd.dart` |
| `Modal` | `Modal`, `ModalVariant` | `modal.dart` |
| `NavDropdown` | `NavDropdown`, `NavOption` | `nav_dropdown.dart` |
| `Pill`, `StatusPill` | `Pill`, `StatusPill` | `pill.dart` |
| `Radio` | `Radio` | `radio.dart` |
| `RelativeTimePicker` | `RelativeTimePicker`, `DateTimeInput`, `parseRelativeTime()` | `relative_time_picker.dart` |
| `SearchableSelect`, `Multiselect` | same names | `searchable_select.dart` |
| `SiteBanner` | `SiteBanner`, `SiteBannerSegment` | `site_banner.dart` |
| `Tab`, `TabsBar` | `TabBar` | `tab_bar.dart` |
| `Table`, `TableHeader`, `TableHeaderCell`, `TableBody`, `TableRow`, `TableCell` | `PrimeTable`, `PrimeTableRow`, `TableVariant` | `table.dart` |
| `VectorInput`, `SliderInput`, `RangeInput` | same names | `numeric_input.dart` |
| `persisted`, `useTimeout`, `uniqueId`, `in-viewport`, `preventHandler` | none | Svelte utilities with no Flutter use |

## Flutter only

These have no TS counterpart because they serve mobile apps: `PrimeApp`, `Scaffold`, `AppBar`, `NavigationBar`, `BottomSheet`, `PrimePageRoute` and its transitions, `ListItem`, `ListItemGroup`, `ExpansionListItem`, `Avatar`, `Divider`, `FilterPill`, `FilterGroup`, `Slider`, `SelectionArea`, `PrimeScrollBehavior`.

## Not ported yet

- `FileInput` (prime-ui) and `FileField` (prime-controls)
- Compact panel variants of `Select`, `Tabs` and `ToggleButtons` (prime-controls)

## Keeping this current

To find what changed in TS since the last check, compare the `index.ts` of each package under `packages/*/src/lib/` with the tables above, then update the commit hashes and date at the top.
