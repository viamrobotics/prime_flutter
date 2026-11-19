import 'package:flutter/widgets.dart';

import '../theme/prime_theme.dart';

/// How a [PrimeTable] sizes its columns.
enum TableVariant {
  /// Columns size to their content.
  auto,

  /// Columns share the width equally unless [PrimeTable.columnWidths] says
  /// otherwise.
  fixed,
}

/// The communicated state of a [PrimeTableRow].
enum TableRowVariant { none, success, disabled, error }

/// One body row of a [PrimeTable].
class PrimeTableRow {
  final List<Widget> cells;
  final TableRowVariant variant;
  final LocalKey? key;

  const PrimeTableRow({required this.cells, this.variant = TableRowVariant.none, this.key});
}

/// A simple data table with a header row.
///
/// Named `PrimeTable` because `Table` is taken by `flutter/widgets`. The web
/// library's `TableHeader`, `TableHeaderCell`, `TableBody`, `TableRow` and
/// `TableCell` map to [header], [rows] and [PrimeTableRow.cells].
///
/// ```dart
/// PrimeTable(
///   variant: TableVariant.fixed,
///   columnWidths: const {0: FlexColumnWidth(2)},
///   header: const [Text('Name'), Text('Status')],
///   rows: const [
///     PrimeTableRow(cells: [Text('arm-1'), Text('Live')]),
///     PrimeTableRow(cells: [Text('arm-2'), Text('Offline')], variant: TableRowVariant.error),
///   ],
/// )
/// ```
class PrimeTable extends StatelessWidget {
  /// Header cells. Omit for a headerless table.
  final List<Widget>? header;

  final List<PrimeTableRow> rows;

  final TableVariant variant;

  /// Per-column width overrides.
  final Map<int, TableColumnWidth>? columnWidths;

  /// Padding inside every cell.
  final EdgeInsetsGeometry cellPadding;

  const PrimeTable({
    super.key,
    this.header,
    required this.rows,
    this.variant = TableVariant.fixed,
    this.columnWidths,
    this.cellPadding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    final c = theme.colorScheme;
    final baseStyle = theme.textTheme.bodySmall.copyWith(height: 1.3);
    final divider = Border(bottom: BorderSide(color: c.borderSubtle));

    Widget cell(Widget child, Color color) => Padding(
      padding: cellPadding,
      child: DefaultTextStyle(style: baseStyle.copyWith(color: color), child: child),
    );

    return Table(
      defaultColumnWidth: variant == TableVariant.fixed ? const FlexColumnWidth() : const IntrinsicColumnWidth(),
      columnWidths: columnWidths,
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        if (header != null)
          TableRow(
            decoration: BoxDecoration(color: c.surfaceOffset, border: divider),
            children: [for (final child in header!) cell(child, c.textPrimary)],
          ),
        for (final row in rows)
          TableRow(
            key: row.key,
            decoration: BoxDecoration(
              color: switch (row.variant) {
                TableRowVariant.none => c.surfaceBase,
                TableRowVariant.success => c.statusSuccessLight,
                TableRowVariant.error => c.statusDangerLight,
                TableRowVariant.disabled => c.surfaceOffset,
              },
              border: divider,
            ),
            children: [
              for (final child in row.cells)
                cell(child, switch (row.variant) {
                  TableRowVariant.none => c.textPrimary,
                  TableRowVariant.success => c.statusSuccessDark,
                  TableRowVariant.error => c.statusDangerDark,
                  TableRowVariant.disabled => c.textPlaceholder,
                }),
            ],
          ),
      ],
    );
  }
}
