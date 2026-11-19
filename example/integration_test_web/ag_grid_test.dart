// Drives the real AG Grid that AGGridTable hosts on the web. Skipped elsewhere.
//   flutter run -d chrome -t integration_test_web/ag_grid_test.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:prime_flutter/prime_flutter.dart';

import 'support/dom_stub.dart' if (dart.library.js_interop) 'support/dom_web.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AGGridTable hosts the real AG Grid: options apply, headers sort, rows report clicks', (tester) async {
    final clicked = <Object?>[];
    List<Map<String, Object?>> rows = const [
      {'name': 'rover', 'parts': 3},
      {'name': 'arm', 'parts': 12, 'variant': 'error'},
      {'name': 'drone', 'parts': 1},
    ];
    late StateSetter rebuild;
    await tester.pumpWidget(
      PrimeApp(
        home: PrimeScaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return AGGridTable<Map<String, Object?>>(
                height: 320,
                scriptUrl: 'https://cdn.jsdelivr.net/npm/ag-grid-community@33.0.3/dist/ag-grid-community.min.js',
                gridOptions: const {'pagination': true, 'paginationPageSize': 20},
                onRowClicked: (row) => clicked.add(row['name']),
                columnDefs: const [
                  ColDef(field: 'name', headerName: 'Name', flex: 2),
                  ColDef(field: 'parts', headerName: 'Parts'),
                ],
                rowData: rows,
              );
            },
          ),
        ),
      ),
    );

    // The script loads from the network, so wait for the grid's rows to appear.
    List<String> names() => textsOf('.ag-center-cols-container .ag-row [col-id="name"]');
    for (int i = 0; i < 100 && names().length < 3; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(names().toSet(), {'rover', 'arm', 'drone'});
    expect(textsOf('.ag-header-cell-text'), ['Name', 'Parts']);

    // gridOptions reached AG Grid: its paging bar exists. The Prime row variant is on the row.
    expect(countOf('.ag-paging-panel'), greaterThan(0));
    expect(countOf('.ag-row.prime-row-error'), greaterThan(0));

    // AG Grid positions rows by index, not by DOM order.
    List<String> ordered(int count) => [
      for (int index = 0; index < count; index++)
        textsOf('.ag-center-cols-container .ag-row[row-index="$index"] [col-id="name"]').firstOrNull ?? '',
    ];
    expect(ordered(3), ['rover', 'arm', 'drone']);

    // AG Grid's own header click sorts the rows.
    expect(clickFirst('.ag-header-cell[col-id="name"] .ag-header-cell-label'), isTrue);
    await tester.pump(const Duration(milliseconds: 500));
    expect(ordered(3), ['arm', 'drone', 'rover']);

    // A click on a row reports the row from the data, whatever its place on screen.
    expect(clickFirst('.ag-center-cols-container .ag-row[row-index="2"] [col-id="name"]'), isTrue);
    await tester.pump(const Duration(milliseconds: 300));
    expect(clicked, ['rover']);

    // New row data from Flutter flows into the live grid.
    rebuild(
      () => rows = [
        ...rows,
        {'name': 'kiosk', 'parts': 2},
      ],
    );
    for (int i = 0; i < 20 && names().length < 4; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    expect(names().toSet(), {'rover', 'arm', 'drone', 'kiosk'});
  }, skip: !kIsWeb);
}
