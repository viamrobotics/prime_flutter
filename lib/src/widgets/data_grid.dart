import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';
import 'ag_grid/ag_grid_stub.dart' if (dart.library.js_interop) 'ag_grid/ag_grid_web.dart' as ag;
import 'internal/pressable.dart';
import 'prime_icons.dart';
import 'table.dart';

/// One column of a [DataGrid].
class DataGridColumn<T> {
  /// Unique within the grid; reported by [DataGrid.onSortChanged].
  final String id;

  final Widget header;

  /// The cell's value, used for the default cell text and for sorting.
  final Object? Function(T row)? value;

  /// Renders the cell. Defaults to the text of [value].
  final Widget Function(BuildContext context, T row)? cellBuilder;

  /// A fixed width. When null the column shares the leftover space by [flex].
  final double? width;
  final int flex;

  /// Whether tapping the header sorts by this column. Needs [value] or
  /// [comparator].
  final bool sortable;

  /// Orders two rows ascending. Defaults to comparing [value].
  final int Function(T a, T b)? comparator;

  final Alignment alignment;

  const DataGridColumn({
    required this.id,
    required this.header,
    this.value,
    this.cellBuilder,
    this.width,
    this.flex = 1,
    this.sortable = true,
    this.comparator,
    this.alignment = Alignment.centerLeft,
  });
}

/// The grid's current sort: a column and a direction.
class DataGridSort {
  final String columnId;
  final bool ascending;

  const DataGridSort(this.columnId, {this.ascending = true});
}

/// A data grid with a sticky header, sortable columns, and virtualized rows.
///
/// This is the Flutter counterpart of the web library's AG Grid table.
///
/// ```dart
/// DataGrid<Machine>(
///   height: 320,
///   rows: machines,
///   columns: [
///     DataGridColumn(id: 'name', header: const Text('Name'), value: (m) => m.name, flex: 2),
///     DataGridColumn(id: 'parts', header: const Text('Parts'), value: (m) => m.parts, alignment: Alignment.centerRight),
///     DataGridColumn(id: 'status', header: const Text('Status'), cellBuilder: (context, m) => StatusPill(...), sortable: false),
///   ],
///   rowVariant: (m) => m.offline ? TableRowVariant.error : TableRowVariant.none,
///   onRowTap: open,
/// )
/// ```
///
/// With a [height] the body scrolls under the header and only visible rows
/// are built. Without one the grid sizes to its rows.
class DataGrid<T> extends StatefulWidget {
  final List<DataGridColumn<T>> columns;
  final List<T> rows;

  /// A fixed height for the whole grid, header included.
  final double? height;

  final double rowHeight;
  final double headerHeight;

  /// The communicated state of a row.
  final TableRowVariant Function(T row)? rowVariant;

  final ValueChanged<T>? onRowTap;

  /// The initial sort.
  final DataGridSort? initialSort;

  /// Called when the user changes the sort; null means unsorted.
  final ValueChanged<DataGridSort?>? onSortChanged;

  /// Shown in place of the body when [rows] is empty.
  final WidgetBuilder? emptyBuilder;

  const DataGrid({
    super.key,
    required this.columns,
    required this.rows,
    this.height,
    this.rowHeight = 40,
    this.headerHeight = 36,
    this.rowVariant,
    this.onRowTap,
    this.initialSort,
    this.onSortChanged,
    this.emptyBuilder,
  });

  @override
  State<DataGrid<T>> createState() => _DataGridState<T>();
}

class _DataGridState<T> extends State<DataGrid<T>> {
  late DataGridSort? _sort = widget.initialSort;

  int _compareValues(Object? a, Object? b) {
    if (a == null || b == null) return a == null ? (b == null ? 0 : 1) : -1;
    if (a is num && b is num) return a.compareTo(b);
    if (a is Comparable && a.runtimeType == b.runtimeType) return a.compareTo(b);
    return a.toString().toLowerCase().compareTo(b.toString().toLowerCase());
  }

  List<T> get _sortedRows {
    final sort = _sort;
    if (sort == null) return widget.rows;
    final column = widget.columns.where((column) => column.id == sort.columnId).firstOrNull;
    if (column == null || (column.comparator == null && column.value == null)) return widget.rows;
    final compare = column.comparator ?? (T a, T b) => _compareValues(column.value!(a), column.value!(b));
    final sorted = [...widget.rows]..sort(compare);
    return sort.ascending ? sorted : sorted.reversed.toList();
  }

  /// Cycles a column through ascending, descending, and unsorted.
  void _toggleSort(DataGridColumn<T> column) {
    final current = _sort;
    final DataGridSort? next;
    if (current?.columnId != column.id) {
      next = DataGridSort(column.id);
    } else if (current!.ascending) {
      next = DataGridSort(column.id, ascending: false);
    } else {
      next = null;
    }
    setState(() => _sort = next);
    widget.onSortChanged?.call(next);
  }

  Widget _cells(List<Widget> cells) {
    return Row(
      children: [
        for (int i = 0; i < cells.length; i++)
          widget.columns[i].width != null
              ? SizedBox(width: widget.columns[i].width, child: cells[i])
              : Expanded(flex: widget.columns[i].flex, child: cells[i]),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final style = theme.textTheme.bodySmall.copyWith(fontSize: 12, height: 1.3, fontWeight: FontWeight.w600, color: c.textSecondary);

    return Container(
      height: widget.headerHeight,
      decoration: BoxDecoration(
        color: c.surfaceOffset,
        border: Border(bottom: BorderSide(color: c.borderSubtle)),
      ),
      child: _cells([
        for (final column in widget.columns)
          () {
            final canSort = column.sortable && (column.value != null || column.comparator != null);
            final sorted = _sort?.columnId == column.id;
            final label = Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: column.alignment.x > 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: DefaultTextStyle(style: style, maxLines: 1, overflow: TextOverflow.ellipsis, child: column.header),
                  ),
                  if (sorted) ...[
                    const SizedBox(width: 4),
                    Transform.rotate(
                      angle: _sort!.ascending ? 0 : math.pi,
                      child: Icon(PrimeIcons.arrowUp, size: 14, color: c.textSecondary),
                    ),
                  ],
                ],
              ),
            );
            if (!canSort) return label;
            return Pressable(
              onTap: () => _toggleSort(column),
              builder: (context, hovered, pressed) => Container(
                height: widget.headerHeight,
                color: pressed ? c.surfaceHighlight : (hovered ? c.surfaceHover : null),
                child: label,
              ),
            );
          }(),
      ]),
    );
  }

  Widget _buildRow(BuildContext context, T row) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final variant = widget.rowVariant?.call(row) ?? TableRowVariant.none;
    final (Color background, Color foreground) = switch (variant) {
      TableRowVariant.none => (c.surfaceBase, c.textPrimary),
      TableRowVariant.success => (c.statusSuccessLight, c.statusSuccessDark),
      TableRowVariant.error => (c.statusDangerLight, c.statusDangerDark),
      TableRowVariant.disabled => (c.surfaceOffset, c.textPlaceholder),
    };

    Widget build(bool hovered, bool pressed) => Container(
      height: widget.rowHeight,
      decoration: BoxDecoration(
        color: pressed ? c.surfaceHighlight : (hovered && variant == TableRowVariant.none ? c.surfaceHover : background),
        border: Border(bottom: BorderSide(color: c.borderSubtle)),
      ),
      child: DefaultTextStyle(
        style: theme.textTheme.bodySmall.copyWith(height: 1.3, color: foreground),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: _cells([
          for (final column in widget.columns)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Align(
                alignment: column.alignment,
                child: column.cellBuilder?.call(context, row) ?? Text('${column.value?.call(row) ?? ''}'),
              ),
            ),
        ]),
      ),
    );

    if (widget.onRowTap == null) return build(false, false);
    return Pressable(onTap: () => widget.onRowTap!(row), builder: (context, hovered, pressed) => build(hovered, pressed));
  }

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final rows = _sortedRows;
    final radius = BorderRadius.circular(theme.cornerRadius);
    final empty = rows.isEmpty
        ? (widget.emptyBuilder?.call(context) ??
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text('No rows to show', style: theme.textTheme.bodySmall.copyWith(color: c.textTertiary)),
                ),
              ))
        : null;

    final Widget body;
    if (widget.height != null) {
      body = Expanded(
        child:
            empty ??
            ListView.builder(
              padding: EdgeInsets.zero,
              itemExtent: widget.rowHeight,
              itemCount: rows.length,
              itemBuilder: (context, index) => _buildRow(context, rows[index]),
            ),
      );
    } else {
      body = empty ?? Column(mainAxisSize: MainAxisSize.min, children: [for (final row in rows) _buildRow(context, row)]);
    }

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: c.surfaceBase,
        borderRadius: radius,
        border: Border.all(color: c.borderSubtle),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [_buildHeader(context), body],
        ),
      ),
    );
  }
}

/// A column definition for [AGGridTable], shaped like AG Grid's `ColDef`.
class ColDef<T> {
  /// The key read from each row when rows are maps. Also the column's id.
  final String? field;

  /// The header text. Defaults to [field].
  final String? headerName;

  /// Computes the cell value. Takes precedence over [field].
  final Object? Function(T row)? valueGetter;

  /// Renders the cell. Defaults to the text of the value.
  final Widget Function(BuildContext context, T row)? cellRenderer;

  final double? width;
  final int flex;
  final bool sortable;

  /// Orders two rows ascending. Defaults to comparing the cell values.
  final int Function(T a, T b)? comparator;

  final Alignment alignment;

  const ColDef({
    this.field,
    this.headerName,
    this.valueGetter,
    this.cellRenderer,
    this.width,
    this.flex = 1,
    this.sortable = true,
    this.comparator,
    this.alignment = Alignment.centerLeft,
  });
}

/// The web library's `AGGridTable`: `columnDefs`, `rowData`, and a required
/// `height`.
///
/// **On the web it is the real AG Grid.** When the `agGrid` global is on the
/// page, or [scriptUrl] says where to load it from, the grid is created with
/// `agGrid.createGrid` inside a platform view, and [gridOptions] is passed
/// straight through, so AG Grid's own options apply (pagination, filters,
/// row selection, and so on). The package loads nothing on its own: without
/// the global and without a [scriptUrl] it draws the native grid.
///
/// **On iOS, Android, and desktop there is no browser to run AG Grid in**, so
/// the same column definitions, value getters, sorting, and row variants are
/// drawn natively by [DataGrid], and [gridOptions] has no effect.
///
/// [ColDef.cellRenderer] builds Flutter widgets, which AG Grid's DOM cells
/// cannot host; in the real grid those cells show the cell value as text.
/// A row that is a map with a `variant` key (`success`, `disabled`, or
/// `error`) takes that variant, as on the web.
///
/// ```dart
/// AGGridTable<Map<String, Object?>>(
///   height: 320,
///   scriptUrl: 'https://cdn.jsdelivr.net/npm/ag-grid-community@33.0.3/dist/ag-grid-community.min.js',
///   gridOptions: const {'pagination': true, 'paginationPageSize': 20},
///   columnDefs: const [
///     ColDef(field: 'name', headerName: 'Name', flex: 2),
///     ColDef(field: 'parts', headerName: 'Parts'),
///   ],
///   rowData: const [
///     {'name': 'rover', 'parts': 3},
///     {'name': 'arm-2', 'parts': 12, 'variant': 'error'},
///   ],
/// )
/// ```
class AGGridTable<T> extends StatelessWidget {
  /// Defines the columns to render.
  final List<ColDef<T>> columnDefs;

  /// Defines the rows to render.
  final List<T> rowData;

  /// The height of the table.
  final double height;

  /// Overrides how a row's variant is found.
  final TableRowVariant Function(T row)? rowVariant;

  final ValueChanged<T>? onRowClicked;

  /// The initial sort.
  final DataGridSort? initialSort;
  final ValueChanged<DataGridSort?>? onSortChanged;

  /// AG Grid's own grid options, passed through to the real grid on the web.
  /// JSON-like values only. No effect where the grid is drawn natively.
  final Map<String, Object?> gridOptions;

  /// Where to load the AG Grid script from on the web when the page has not
  /// loaded it already. Null loads nothing.
  final String? scriptUrl;

  /// Stylesheets to add for the real grid, for AG Grid versions that ship
  /// their theme as CSS.
  final List<String> styleUrls;

  /// The class set on the grid's host element.
  final String themeClass;

  /// Set to false to draw the native grid on the web too.
  final bool useAgGrid;

  /// Whether this platform can host the real AG Grid at all.
  static bool get isAgGridSupported => ag.agGridSupported;

  const AGGridTable({
    super.key,
    required this.columnDefs,
    required this.rowData,
    required this.height,
    this.rowVariant,
    this.onRowClicked,
    this.initialSort,
    this.onSortChanged,
    this.gridOptions = const {},
    this.scriptUrl,
    this.styleUrls = const [],
    this.themeClass = 'ag-theme-quartz',
    this.useAgGrid = true,
  });

  static TableRowVariant _variantOf(Object? row) {
    final variant = row is Map ? row['variant'] : null;
    return switch (variant) {
      'success' => TableRowVariant.success,
      'disabled' => TableRowVariant.disabled,
      'error' => TableRowVariant.error,
      TableRowVariant() => variant,
      _ => TableRowVariant.none,
    };
  }

  Object? _valueOf(ColDef<T> def, T row) {
    if (def.valueGetter != null) return def.valueGetter!(row);
    final field = def.field;
    return field != null && row is Map ? row[field] : null;
  }

  /// Plain, JSON-like values for the JavaScript grid.
  static Object? _plain(Object? value) => value == null || value is num || value is bool || value is String ? value : value.toString();

  @override
  Widget build(BuildContext context) {
    final native = _buildNative(context);
    if (!useAgGrid || !ag.agGridSupported) return native;

    final variantOf = rowVariant ?? _variantOf;
    return SizedBox(
      height: height,
      child: ag.buildAgGridView(
        columnDefs: [
          for (int i = 0; i < columnDefs.length; i++)
            {
              'field': columnDefs[i].field ?? 'column$i',
              'headerName': columnDefs[i].headerName ?? columnDefs[i].field ?? '',
              'sortable': columnDefs[i].sortable,
              if (columnDefs[i].width != null) 'width': columnDefs[i].width else 'flex': columnDefs[i].flex,
            },
        ],
        rowData: [
          for (int r = 0; r < rowData.length; r++)
            {
              for (int i = 0; i < columnDefs.length; i++) columnDefs[i].field ?? 'column$i': _plain(_valueOf(columnDefs[i], rowData[r])),
              if (variantOf(rowData[r]) != TableRowVariant.none) 'variant': variantOf(rowData[r]).name,
              '__primeIndex': r,
            },
        ],
        gridOptions: gridOptions,
        scriptUrl: scriptUrl,
        styleUrls: styleUrls,
        themeClass: themeClass,
        onRowClicked: onRowClicked == null
            ? null
            : (index) {
                if (index >= 0 && index < rowData.length) onRowClicked!(rowData[index]);
              },
        fallback: native,
      ),
    );
  }

  Widget _buildNative(BuildContext context) {
    return DataGrid<T>(
      height: height,
      rows: rowData,
      rowVariant: rowVariant ?? _variantOf,
      onRowTap: onRowClicked,
      initialSort: initialSort,
      onSortChanged: onSortChanged,
      columns: [
        for (int i = 0; i < columnDefs.length; i++)
          () {
            final def = columnDefs[i];
            final field = def.field;
            final Object? Function(T row)? value = def.valueGetter ?? (field == null ? null : (T row) => row is Map ? row[field] : null);
            return DataGridColumn<T>(
              id: field ?? 'column-$i',
              header: Text(def.headerName ?? field ?? ''),
              value: value,
              cellBuilder: def.cellRenderer,
              width: def.width,
              flex: def.flex,
              sortable: def.sortable,
              comparator: def.comparator,
              alignment: def.alignment,
            );
          }(),
      ],
    );
  }
}
