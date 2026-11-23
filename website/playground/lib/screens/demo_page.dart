import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

/// Holds one piece of state for a demo.
class _Demo<T> extends StatefulWidget {
  final T initial;
  final Widget Function(BuildContext context, T value, ValueChanged<T> set) builder;

  const _Demo(this.initial, this.builder);

  @override
  State<_Demo<T>> createState() => _DemoState<T>();
}

class _DemoState<T> extends State<_Demo<T>> {
  late T _value = widget.initial;

  @override
  Widget build(BuildContext context) => widget.builder(context, _value, (next) => setState(() => _value = next));
}

class _File {
  final String path;
  final String name;
  final List<_File>? children;

  const _File(this.path, this.name, [this.children]);
}

const _files = [
  _File('src', 'src', [_File('src/main.go', 'main.go'), _File('src/teleop.py', 'teleop.py')]),
  _File('config.json', 'config.json'),
];

List<ChartPoint> _readings(double base, double swing, double phase, {Set<int> gaps = const {}}) => [
  for (var i = 0; i < 60; i++)
    ChartPoint(DateTime(2026, 11, 19, 18, i), gaps.contains(i) ? null : base + swing * math.sin(i / 6 + phase) + (i % 5) * swing / 20),
];

const _json = '{\n  "name": "arm-1",\n  "speed": 50,\n  "debug": false\n}';

final List<SelectOption> _components = SelectOption.fromStrings(['Arm', 'Base', 'Board', 'Camera', 'Gantry', 'Gripper', 'Motor', 'Sensor']);

/// Every docs preview for the components added in 0.3.0, keyed by the
/// `name` query parameter of the `/demo` route.
final Map<String, WidgetBuilder> demos = {
  'banner': (context) => Column(
    mainAxisSize: MainAxisSize.min,
    spacing: 12,
    children: [
      for (final variant in BannerVariant.values)
        PrimeBanner(
          variant: variant,
          loading: variant == BannerVariant.pending,
          title: Text('A ${variant.name} banner'),
          subtitle: const Text('With a subtitle.'),
        ),
    ],
  ),
  'banner-outlined': (context) => Column(
    mainAxisSize: MainAxisSize.min,
    spacing: 12,
    children: [
      PrimeBanner(
        appearance: BannerAppearance.outlined,
        title: const Text('Module deprecated'),
        subtitle: const Text('my-camera uses a module that is no longer maintained.'),
        onClose: () {},
      ),
      const PrimeBanner(appearance: BannerAppearance.outlined, variant: BannerVariant.pending, subtitle: Text('Deploying the module')),
    ],
  ),
  'banner-actions': (context) => PrimeBanner(
    variant: BannerVariant.warning,
    title: const Text('Credentials expire soon'),
    subtitle: const Text('Rotate the API key before Friday.'),
    actionEmphasize: Button(label: const Text('Open settings'), onPressed: () {}),
    expandableDetails: const Text('Key ending in 4f2a expires in 3 days.'),
    onClose: () {},
  ),
  'site-banner': (context) => Column(
    mainAxisSize: MainAxisSize.min,
    spacing: 12,
    children: [
      SiteBanner(heading: 'We are investigating an issue', value: 'Data sync may be delayed', linkText: 'Status', onLinkTap: () {}),
      SiteBanner(variant: SiteBannerVariant.info, value: 'Scheduled maintenance tonight at 10pm ET', onDismiss: () {}),
      SiteBanner(
        variant: SiteBannerVariant.announcement,
        badge: 'New',
        segments: [
          const SiteBannerSegment('Teleop is here.', style: SiteBannerSegmentStyle.strong),
          SiteBannerSegment('Read more', onTap: () {}),
        ],
        onDismiss: () {},
      ),
    ],
  ),
  'notification': (context) => NotificationContainer(
    child: Builder(
      builder: (context) => Center(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Button(
              label: const Text('Success'),
              onPressed: () => Notify.of(context).success('Saved', message: 'Your changes are live.'),
            ),
            Button(
              label: const Text('Danger'),
              onPressed: () => Notify.of(context).danger('Failed', message: 'Could not reach the machine.'),
            ),
            Button(label: const Text('Pending'), onPressed: () => Notify.of(context).pending('Uploading', persist: true)),
          ],
        ),
      ),
    ),
  ),
  'icon-button': (context) => Wrap(
    spacing: 12,
    runSpacing: 12,
    children: [
      for (final variant in IconButtonVariant.values)
        IconButton(icon: const Icon(PrimeIcons.trashCanOutline), label: variant.name, variant: variant, onPressed: () {}),
      const IconButton(icon: Icon(PrimeIcons.plus), label: 'Loading', loading: true, variant: IconButtonVariant.secondary),
    ],
  ),
  'tooltip': (context) => const Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 32,
    children: [
      Tooltip(message: 'Shown on hover or long press', child: Icon(PrimeIcons.informationOutline)),
      Tooltip(message: 'Always visible', visibility: TooltipVisibility.visible, placement: FloatingPlacement.right, child: Text('Pinned')),
    ],
  ),
  'menu': (context) => _Demo<(bool, String)>(
    (false, 'comfortable'),
    (context, value, set) => Menu(
      trigger: const Button(label: Text('View'), icon: Icon(PrimeIcons.filterSliders)),
      items: [
        MenuItem(icon: PrimeIcons.refresh, shortcut: '⌘R', onTap: () {}, child: const Text('Refresh')),
        MenuCheckboxItem(checked: value.$1, onChanged: (next) => set((next, value.$2)), child: const Text('Show hidden')),
        const MenuSeparator(),
        MenuRadioGroup<String>(
          value: value.$2,
          onChanged: (next) => set((value.$1, next)),
          heading: const Text('Density'),
          children: const [
            MenuRadioItem(value: 'comfortable', child: Text('Comfortable')),
            MenuRadioItem(value: 'compact', child: Text('Compact')),
          ],
        ),
        const MenuSeparator(),
        MenuSub(
          items: [
            MenuItem(onTap: () {}, child: const Text('CSV')),
            MenuItem(onTap: () {}, child: const Text('JSON')),
          ],
          child: const Text('Export as'),
        ),
        MenuItem(icon: PrimeIcons.trashCanOutline, variant: MenuItemVariant.danger, onTap: () {}, child: const Text('Delete')),
      ],
    ),
  ),
  'menubar': (context) => Menubar(
    menus: [
      MenubarMenu(
        label: const Text('File'),
        items: [
          MenuItem(shortcut: '⌘N', onTap: () {}, child: const Text('New')),
          MenuItem(shortcut: '⌘O', onTap: () {}, child: const Text('Open')),
        ],
      ),
      MenubarMenu(
        label: const Text('Edit'),
        items: [MenuItem(shortcut: '⌘Z', onTap: () {}, child: const Text('Undo'))],
      ),
      MenubarMenu(
        label: const Text('View'),
        items: [MenuItem(onTap: () {}, child: const Text('Zoom in'))],
      ),
    ],
  ),
  'context-menu-region': (context) => ContextMenuRegion(
    items: [
      MenuItem(icon: PrimeIcons.contentCopy, onTap: () {}, child: const Text('Copy')),
      MenuItem(icon: PrimeIcons.contentPaste, onTap: () {}, child: const Text('Paste')),
    ],
    child: Container(
      width: 280,
      height: 96,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: PrimeTheme.of(context).colorScheme.borderSubtle),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text('Right-click or long-press here'),
    ),
  ),
  'floating-menu': (context) => _Demo<bool>(
    false,
    (context, isOpen, set) => FloatingMenu(
      isOpen: isOpen,
      onChange: set,
      control: const Padding(padding: EdgeInsets.all(8), child: Icon(PrimeIcons.dotsHorizontal)),
      items: [
        ContextMenuItem(icon: PrimeIcons.pencilOutline, onTap: () => set(false), child: const Text('Rename')),
        const ContextMenuSeparator(),
        ContextMenuItem(
          icon: PrimeIcons.trashCanOutline,
          variant: ContextMenuItemVariant.danger,
          onTap: () => set(false),
          child: const Text('Delete'),
        ),
      ],
    ),
  ),
  'popover': (context) => Popover(
    trigger: const Button(label: Text('Share')),
    contentBuilder: (context, close) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        const Text('Anyone with the link can view this machine.'),
        Button(label: const Text('Copy link'), variant: ButtonVariant.primary, onPressed: close),
      ],
    ),
  ),
  'nav-dropdown': (context) => _Demo<String>(
    '/overview',
    (context, value, set) => SizedBox(
      width: 280,
      child: NavDropdown<String>(
        selected: value,
        onSelected: set,
        options: const [
          NavOption(label: 'Overview', value: '/overview'),
          NavOption(label: 'Logs', value: '/logs', description: 'Live and historical'),
          NavOption(label: 'Config', value: '/config', detail: 'JSON'),
        ],
      ),
    ),
  ),
  'pill': (context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      Pill(value: 'Chocolate chip', onRemove: (_) {}),
      const Pill(value: 'Read only', readOnly: true),
      Pill(value: 'camera', icon: PrimeIcons.cameraOutline, iconTooltip: 'Component', onRemove: (_) {}),
      Pill(value: 'dark', variant: PillVariant.dark, icon: PrimeIcons.tagOutline, onRemove: (_) {}),
      Pill(value: 'info', variant: PillVariant.info, onRemove: (_) {}),
      Pill(value: 'warning', variant: PillVariant.warning, onRemove: (_) {}),
    ],
  ),
  'status-pill': (context) => const Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      StatusPill(label: 'Live', variant: StatusPillVariant.success, tooltip: 'Connected 2 minutes ago'),
      StatusPill(label: 'Degraded', variant: StatusPillVariant.warning),
      StatusPill(label: 'Offline', variant: StatusPillVariant.danger),
      StatusPill(label: 'Inactive', variant: StatusPillVariant.inactive),
      StatusPill(label: 'Configuring', variant: StatusPillVariant.inactive, loading: true),
    ],
  ),
  'status-dot': (context) => const Row(
    mainAxisSize: MainAxisSize.min,
    spacing: 16,
    children: [
      StatusDot(label: 'None'),
      StatusDot(state: StatusDotState.info, label: 'Info'),
      StatusDot(state: StatusDotState.success, label: 'Online'),
      StatusDot(state: StatusDotState.warning, label: 'Degraded'),
      StatusDot(state: StatusDotState.danger, label: 'Offline'),
      StatusDot(state: StatusDotState.danger, variant: StatusDotVariant.hollow, label: 'Hollow'),
      StatusDot(state: StatusDotState.info, working: true, label: 'Working'),
    ],
  ),
  'kbd': (context) => const KbdGroup(
    children: [
      Kbd(child: Icon(PrimeIcons.appleKeyboardCommand)),
      Kbd(child: Text('S')),
    ],
  ),
  'code-snippet': (context) => const CodeSnippet(
    caption: Text('Install the server, then start it.'),
    code: 'curl -fsSL https://example.com/install.sh | sh\nviam-server -config /etc/viam.json',
  ),
  'inline-code': (context) =>
      const Row(mainAxisSize: MainAxisSize.min, spacing: 6, children: [Text('Restart'), InlineCode('viam-server'), Text('to apply.')]),
  'code-editor': (context) => _Demo<String>(
    _json,
    (context, value, set) => CodeEditor(semanticLabel: 'Config', language: CodeEditorLanguage.json, value: value, onChanged: set),
  ),
  'code-editor-diff': (context) => _Demo<String>(
    _json.replaceFirst('50', '80').replaceFirst('false', 'true'),
    (context, value, set) => CodeEditor(language: CodeEditorLanguage.json, original: _json, value: value, onChanged: set),
  ),
  'code-editor-split': (context) => CodeEditor(
    language: CodeEditorLanguage.json,
    original: _json,
    value: _json.replaceFirst('50', '80'),
    diff: CodeEditorDiff.split,
    wrapLines: true,
  ),
  'field': (context) => const Field(
    required: true,
    state: InputState.error,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Label(label: Text('Email')),
        Input(placeholder: 'you@example.com'),
        Hint(child: Text('Enter a valid address.')),
      ],
    ),
  ),
  'label': (context) => const Column(
    mainAxisSize: MainAxisSize.min,
    spacing: 12,
    children: [
      Label(
        label: Text('Name'),
        required: true,
        child: Input(placeholder: 'Machine name'),
      ),
      Label(label: Text('Notes'), detail: '(optional)', child: Input()),
      Label(label: Text('Left'), position: LabelPosition.left, child: Input()),
    ],
  ),
  'checkbox': (context) => _Demo<bool>(
    false,
    (context, value, set) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(checked: value, onChanged: set, label: const Text('Accept the terms')),
        Checkbox(checked: false, indeterminate: true, onChanged: (_) {}, label: const Text('Indeterminate')),
        const Checkbox(checked: true, disabled: true, label: Text('Disabled')),
      ],
    ),
  ),
  'radio': (context) => _Demo<String?>(
    'daily',
    (context, value, set) => Radio<String>(
      legend: const Text('Sync frequency'),
      required: true,
      selected: value,
      onChanged: set,
      options: const [
        RadioOption(label: 'Daily', value: 'daily', description: 'Every day at midnight'),
        RadioOption(label: 'Weekly', value: 'weekly'),
        RadioOption(label: 'Never', value: 'never', disabled: true),
      ],
    ),
  ),
  'textarea': (context) => const Textarea(placeholder: 'Anything else we should know?'),
  'numeric-input': (context) =>
      _Demo<num?>(3, (context, value, set) => NumericInput(type: NumericInputType.integer, value: value, min: 0, max: 10, onChanged: set)),
  'slider-input': (context) =>
      _Demo<num?>(0.5, (context, value, set) => SliderInput(value: value, step: 0.1, min: 0, max: 1, onChanged: set)),
  'range-input': (context) => _Demo<num>(40, (context, value, set) => RangeInput(value: value, step: 10, suffix: '%', onChanged: set)),
  'vector-input': (context) =>
      _Demo<Map<String, num>>({'x': 0, 'y': 1.5, 'z': -2}, (context, value, set) => VectorInput(values: value, step: 0.5, onChanged: set)),
  'searchable-select': (context) => _Demo<String>(
    '',
    (context, value, set) =>
        SearchableSelect(options: _components, value: value, exclusive: true, placeholder: 'Search components', onChanged: set),
  ),
  'multiselect': (context) => _Demo<List<String>>(
    ['Arm'],
    (context, value, set) =>
        Multiselect(options: _components, selected: value, clearable: true, placeholder: 'Add components', onChanged: set),
  ),
  'combobox': (context) => _Demo<String?>(
    'motor',
    (context, value, set) => Combobox<String>(
      items: const [
        ComboboxItem(value: 'camera', label: 'Camera'),
        ComboboxItem(value: 'motor', label: 'Motor'),
        ComboboxItem(value: 'base', label: 'Base'),
        ComboboxItem(value: 'arm', label: 'Arm'),
      ],
      value: value,
      placeholder: 'Search resource types',
      emptyText: 'No matching resource type',
      onChanged: set,
    ),
  ),
  'date-range-picker': (context) => _Demo<DateRange?>(
    DateRange(start: DateTime(2026, 3, 10), end: DateTime(2026, 3, 16)),
    (context, value, set) => DateRangePicker(value: value, onChanged: set),
  ),
  'date-picker': (context) => _Demo<DateTime?>(DateTime(2026, 3, 10), (context, value, set) => DatePicker(value: value, onChanged: set)),
  'relative-time-picker': (context) =>
      _Demo<String?>('now-15m', (context, value, set) => RelativeTimePicker(value: value, onChanged: (time) => set(time.value))),
  'breadcrumbs': (context) => const Breadcrumbs(crumbs: ['Dessert', 'Cookie', 'Chocolate chip']),
  'navigation-breadcrumb': (context) => NavigationBreadcrumb(
    children: [
      NavigationBreadcrumbLink(onTap: () {}, child: const Text('Fleet')),
      const NavigationBreadcrumbSeparator(),
      const NavigationBreadcrumbEllipsis(),
      const NavigationBreadcrumbSeparator(),
      const NavigationBreadcrumbPage(child: Text('arm-1')),
    ],
  ),
  'expandable': (context) => Expandable(
    triggerBuilder: (context, isOpen) => Text(isOpen ? 'Hide advanced options' : 'Show advanced options'),
    content: const Padding(padding: EdgeInsets.only(top: 12), child: Text('Advanced options go here.')),
  ),
  'collapsible': (context) => const Collapsible(title: Text('Advanced'), initiallyOpen: true, child: Text('More settings live here.')),
  'takeover': (context) => Button(
    label: const Text('Open takeover'),
    onPressed: () => Takeover.show<void>(
      context: context,
      builder: (context) => const Takeover(
        header: TakeoverHeader(
          children: [
            Expanded(child: TakeoverTitle(child: Text('Setup wizard'))),
            TakeoverClose(),
          ],
        ),
        child: Center(child: Text('Your content here')),
      ),
    ),
  ),
  'modal': (context) => Button(
    label: const Text('Open modal'),
    onPressed: () => Modal.show<void>(
      context: context,
      title: const Text('Print a statement?'),
      message: const Text('This writes a line to the console.'),
      actionsBuilder: (context) => [
        Button(label: const Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
        Button(label: const Text('Print'), variant: ButtonVariant.primary, onPressed: () => Navigator.of(context).pop()),
      ],
    ),
  ),
  'table': (context) => const PrimeTable(
    columnWidths: {0: FlexColumnWidth(2)},
    header: [Text('Machine'), Text('Part'), Text('Status')],
    rows: [
      PrimeTableRow(cells: [Text('rover'), Text('main'), Text('Live')]),
      PrimeTableRow(cells: [Text('arm-1'), Text('main'), Text('Deployed')], variant: TableRowVariant.success),
      PrimeTableRow(cells: [Text('arm-2'), Text('main'), Text('Offline')], variant: TableRowVariant.error),
      PrimeTableRow(cells: [Text('drone'), Text('main'), Text('Archived')], variant: TableRowVariant.disabled),
    ],
  ),
  'data-grid': (context) => DataGrid<({String name, int parts})>(
    height: 240,
    rows: const [
      (name: 'rover', parts: 3),
      (name: 'arm-1', parts: 12),
      (name: 'arm-2', parts: 12),
      (name: 'drone', parts: 1),
      (name: 'gantry', parts: 6),
      (name: 'kiosk', parts: 2),
    ],
    initialSort: const DataGridSort('name'),
    onRowTap: (_) {},
    columns: [
      DataGridColumn(id: 'name', header: const Text('Machine'), value: (row) => row.name, flex: 2),
      DataGridColumn(id: 'parts', header: const Text('Parts'), value: (row) => row.parts, alignment: Alignment.centerRight),
    ],
  ),
  'ag-grid': (context) => const AGGridTable<Map<String, Object?>>(
    height: 300,
    scriptUrl: 'https://cdn.jsdelivr.net/npm/ag-grid-community@33.0.3/dist/ag-grid-community.min.js',
    gridOptions: {'pagination': true, 'paginationPageSize': 20},
    columnDefs: [
      ColDef(field: 'name', headerName: 'Machine', flex: 2),
      ColDef(field: 'parts', headerName: 'Parts'),
      ColDef(field: 'status', headerName: 'Status'),
    ],
    rowData: [
      {'name': 'rover', 'parts': 3, 'status': 'Live'},
      {'name': 'arm-1', 'parts': 12, 'status': 'Deployed', 'variant': 'success'},
      {'name': 'arm-2', 'parts': 12, 'status': 'Offline', 'variant': 'error'},
      {'name': 'drone', 'parts': 1, 'status': 'Archived', 'variant': 'disabled'},
    ],
  ),
  'panes': (context) => _Demo<LayoutNode<String>?>(
    const SplitNode<String>(
      id: 'root',
      direction: SplitDirection.row,
      ratio: 0.35,
      first: PaneNode(id: 'files', data: 'Files'),
      second: SplitNode<String>(
        id: 'right',
        direction: SplitDirection.column,
        ratio: 0.6,
        first: PaneNode(id: 'editor', data: 'Editor'),
        second: StackNode<String>(
          id: 'bottom',
          activeId: 'logs',
          panes: [
            PaneNode(id: 'logs', data: 'Logs'),
            PaneNode(id: 'problems', data: 'Problems'),
          ],
        ),
      ),
    ),
    (context, layout, set) => SizedBox(
      height: 320,
      child: Panes<String>(
        layout: layout,
        onLayoutChanged: set,
        paneLabel: (pane) => pane.data,
        paneBuilder: (context, pane, state) => Center(child: Text(pane.data)),
      ),
    ),
  ),
  'panes-rearrange': (context) => _Demo<LayoutNode<String>?>(
    floatPane(
      const SplitNode<String>(
        id: 'root',
        direction: SplitDirection.row,
        first: PaneNode(id: 'files', data: 'Files'),
        second: SplitNode<String>(
          id: 'right',
          direction: SplitDirection.column,
          first: PaneNode(id: 'editor', data: 'Editor'),
          second: PaneNode(id: 'logs', data: 'Logs'),
        ),
      ),
      'logs',
      const FloatRect(x: 220, y: 120, width: 240, height: 150),
      'logs-window',
      'floats',
    ),
    (context, layout, set) => SizedBox(
      height: 360,
      child: Panes<String>(
        layout: layout,
        onLayoutChanged: set,
        paneLabel: (pane) => pane.data,
        paneBuilder: (context, pane, state) => Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: PaneDragTrigger(
                    child: Padding(padding: const EdgeInsets.all(8), child: Text(pane.data)),
                  ),
                ),
                PaneMoveTrigger(
                  label: 'Move ${pane.data}',
                  child: const Padding(padding: EdgeInsets.all(8), child: Icon(PrimeIcons.cursorMove, size: 16)),
                ),
              ],
            ),
            const Expanded(child: SizedBox.expand()),
          ],
        ),
      ),
    ),
  ),
  'code-editor-fold': (context) => _Demo<String>(
    '{\n  "components": [\n    {\n      "name": "arm-1",\n      "attributes": { "speed": 50 }\n    }\n  ],\n  "debug": false\n}',
    (context, value, set) => CodeEditor(semanticLabel: 'Config', language: CodeEditorLanguage.json, value: value, onChanged: set),
  ),
  'keybindings': (context) => Keybindings(
    child: _Demo<int>(
      0,
      (context, count, set) => Hotkey(
        binding: const Keybinding(id: 'increment', description: 'Add one', group: 'Counter', key: 'k'),
        onInvoke: () => set(count + 1),
        child: Hotkey(
          binding: const Keybinding(id: 'reset', description: 'Reset', group: 'Counter', key: 'backspace', shift: true),
          onInvoke: () => set(0),
          child: Builder(
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 12,
              children: [
                Text('Count: $count'),
                for (final binding in Keybindings.of(context).bindings)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 8,
                    children: [
                      KbdGroup(children: [for (final part in keybindingParts(binding)) Kbd(child: Text(part))]),
                      Text(binding.description),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
  'split-pane': (context) => _Demo<double>(
    0.4,
    (context, ratio, set) => SizedBox(
      height: 200,
      child: SplitPane(
        ratio: ratio,
        onRatioChanged: set,
        first: const Center(child: Text('First')),
        second: const Center(child: Text('Second')),
      ),
    ),
  ),
  'chart': (context) => Chart(
    semanticLabel: 'Cell temperature',
    series: [
      ChartSeries(name: 'cell-01', unit: '°C', points: _readings(24, 4, 0)),
      ChartSeries(
        name: 'cell-02',
        unit: '°C',
        points: _readings(21, 3, 2, gaps: const {20, 21, 22}),
      ),
    ],
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChartLegend(),
        SizedBox(height: 8),
        SizedBox(height: 240, child: ChartPlot()),
      ],
    ),
  ),
  'tree-view': (context) => SizedBox(
    width: 280,
    child: TreeView<_File>(
      semanticLabel: 'Files',
      nodes: _files,
      nodeToValue: (file) => file.path,
      nodeToString: (file) => file.name,
      nodeToChildren: (file) => file.children,
      initiallyExpanded: const {'src'},
      branchClick: TreeBranchClick.toggle,
      showIndentGuides: true,
    ),
  ),
  'controls': (context) => _Demo<(num?, PointValue, num)>(
    (60, const PointValue(x: 0, y: 1.5, z: -2), 0.8),
    (context, value, set) => SizedBox(
      width: 320,
      child: Panel(
        title: 'Camera',
        children: [
          NumberField(
            label: 'FOV',
            labelWidth: 72,
            min: 10,
            max: 120,
            value: value.$1,
            onChanged: (next) => set((next, value.$2, value.$3)),
          ),
          PointField(label: 'Position', step: 0.1, value: value.$2, onChanged: (next) => set((value.$1, next, value.$3))),
          Folder(
            title: 'Lighting',
            children: [
              SliderField(
                label: 'Intensity',
                min: 0,
                max: 1,
                step: 0.01,
                value: value.$3,
                onChanged: (next) => set((value.$1, value.$2, next)),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
};

/// Renders one entry of [demos] for a docs preview iframe.
class DemoPage extends StatelessWidget {
  final String name;

  const DemoPage({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final builder = demos[name];
    return Scaffold(
      body: DefaultTextStyle(
        style: theme.textTheme.bodySmall,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: builder == null ? Text('Unknown demo "$name"') : Builder(builder: builder),
            ),
          ),
        ),
      ),
    );
  }
}
