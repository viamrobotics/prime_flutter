import 'package:flutter/widgets.dart';

/// Off the web there is no browser to host AG Grid, so there is no view.
bool get agGridSupported => false;

Widget buildAgGridView({
  Key? key,
  required List<Map<String, Object?>> columnDefs,
  required List<Map<String, Object?>> rowData,
  required Map<String, Object?> gridOptions,
  required String? scriptUrl,
  required List<String> styleUrls,
  required String themeClass,
  required void Function(int rowIndex)? onRowClicked,
  required Widget fallback,
}) => fallback;
