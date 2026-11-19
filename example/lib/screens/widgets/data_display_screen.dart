import 'package:flutter/widgets.dart';
import 'package:prime_flutter/prime_flutter.dart';

import 'showcase.dart';

class DataDisplayScreen extends StatelessWidget {
  const DataDisplayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = PrimeTheme.of(context);
    return ShowcasePage(
      title: 'Data display',
      description: 'Tables and read-only code.',
      sections: [
        const ShowcaseSection(
          title: 'Table',
          description: 'Row variants communicate state.',
          child: PrimeTable(
            columnWidths: {0: FlexColumnWidth(2)},
            header: [Text('Machine'), Text('Part'), Text('Status')],
            rows: [
              PrimeTableRow(cells: [Text('rover'), Text('main'), Text('Live')]),
              PrimeTableRow(cells: [Text('arm-1'), Text('main'), Text('Deployed')], variant: TableRowVariant.success),
              PrimeTableRow(cells: [Text('arm-2'), Text('main'), Text('Offline')], variant: TableRowVariant.error),
              PrimeTableRow(cells: [Text('drone'), Text('main'), Text('Archived')], variant: TableRowVariant.disabled),
            ],
          ),
        ),
        ShowcaseSection(
          title: 'Data grid',
          description: 'Tap a header to sort. The body scrolls under the sticky header.',
          child: DataGrid<({String name, int parts, StatusDotState state})>(
            height: 236,
            rows: const [
              (name: 'rover', parts: 3, state: StatusDotState.success),
              (name: 'arm-1', parts: 12, state: StatusDotState.success),
              (name: 'arm-2', parts: 12, state: StatusDotState.danger),
              (name: 'drone', parts: 1, state: StatusDotState.warning),
              (name: 'gantry', parts: 6, state: StatusDotState.disabled),
              (name: 'kiosk', parts: 2, state: StatusDotState.info),
            ],
            initialSort: const DataGridSort('name'),
            onRowTap: (_) {},
            columns: [
              DataGridColumn(id: 'name', header: const Text('Machine'), value: (row) => row.name, flex: 2),
              DataGridColumn(id: 'parts', header: const Text('Parts'), value: (row) => row.parts, alignment: Alignment.centerRight),
              DataGridColumn(
                id: 'state',
                header: const Text('State'),
                value: (row) => row.state.name,
                cellBuilder: (context, row) => Row(
                  spacing: 8,
                  children: [
                    StatusDot(state: row.state, label: row.state.name),
                    Text(row.state.name),
                  ],
                ),
              ),
            ],
          ),
        ),
        const ShowcaseSection(
          title: 'Status dot',
          child: Row(
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
        ),
        const ShowcaseSection(
          title: 'Code snippet',
          child: CodeSnippet(
            caption: Text('Install the server, then start it.'),
            code: 'curl -fsSL https://example.com/install.sh | sh\nviam-server -config /etc/viam.json',
          ),
        ),
        ShowcaseSection(
          title: 'Inline code',
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              Text('Restart', style: theme.textTheme.bodyDefault),
              const InlineCode('viam-server'),
              Text('to apply the change.', style: theme.textTheme.bodyDefault),
            ],
          ),
        ),
      ],
    );
  }
}
