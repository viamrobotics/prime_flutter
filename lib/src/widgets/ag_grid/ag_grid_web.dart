import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

/// On the web the real AG Grid can be hosted in a platform view.
bool get agGridSupported => true;

JSObject get _document => globalContext['document'] as JSObject;

bool get _agGridLoaded => globalContext.has('agGrid');

final Map<String, Future<void>> _loads = {};

/// Adds a script or stylesheet to the page once, and completes when it has loaded.
Future<void> _load(String url, {required bool script}) {
  return _loads.putIfAbsent(url, () {
    final completer = Completer<void>();
    final element = _document.callMethod<JSObject>('createElement'.toJS, (script ? 'script' : 'link').toJS);
    if (script) {
      element['src'] = url.toJS;
    } else {
      element['rel'] = 'stylesheet'.toJS;
      element['href'] = url.toJS;
    }
    element['onload'] = (() => completer.complete()).toJS;
    element['onerror'] = (() => completer.completeError(StateError('Could not load $url'))).toJS;
    (_document['head'] as JSObject).callMethod<JSAny?>('appendChild'.toJS, element);
    return completer.future;
  });
}

int _nextViewId = 0;
bool _stylesAdded = false;

/// The row variant colors of the web component, as rules for the classes set by `getRowClass`.
void _addRowVariantStyles() {
  if (_stylesAdded) return;
  _stylesAdded = true;
  final style = _document.callMethod<JSObject>('createElement'.toJS, 'style'.toJS);
  style['textContent'] =
      '.prime-row-error{background-color:#fcecea !important;color:#be3536 !important}'
              '.prime-row-success{background-color:#e0fae3 !important;color:#3d7d3f !important}'
              '.prime-row-disabled{background-color:#fbfbfc !important;color:#9c9ca4 !important}'
          .toJS;
  (_document['head'] as JSObject).callMethod<JSAny?>('appendChild'.toJS, style);
}

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
}) {
  // Without the library on the page and with nowhere to get it from, draw the native grid.
  if (!_agGridLoaded && scriptUrl == null) return fallback;
  return _AgGridView(
    key: key,
    columnDefs: columnDefs,
    rowData: rowData,
    gridOptions: gridOptions,
    scriptUrl: scriptUrl,
    styleUrls: styleUrls,
    themeClass: themeClass,
    onRowClicked: onRowClicked,
    fallback: fallback,
  );
}

class _AgGridView extends StatefulWidget {
  final List<Map<String, Object?>> columnDefs;
  final List<Map<String, Object?>> rowData;
  final Map<String, Object?> gridOptions;
  final String? scriptUrl;
  final List<String> styleUrls;
  final String themeClass;
  final void Function(int rowIndex)? onRowClicked;
  final Widget fallback;

  const _AgGridView({
    super.key,
    required this.columnDefs,
    required this.rowData,
    required this.gridOptions,
    required this.scriptUrl,
    required this.styleUrls,
    required this.themeClass,
    required this.onRowClicked,
    required this.fallback,
  });

  @override
  State<_AgGridView> createState() => _AgGridViewState();
}

class _AgGridViewState extends State<_AgGridView> {
  late final String _viewType = 'prime-ag-grid-${_nextViewId++}';
  JSObject? _host;
  JSObject? _api;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final host = _document.callMethod<JSObject>('createElement'.toJS, 'div'.toJS);
      host['className'] = widget.themeClass.toJS;
      final style = host['style'] as JSObject;
      style['width'] = '100%'.toJS;
      style['height'] = '100%'.toJS;
      _host = host;
      _create();
      return host;
    });
  }

  Future<void> _create() async {
    try {
      _addRowVariantStyles();
      for (final url in widget.styleUrls) {
        await _load(url, script: false);
      }
      if (!_agGridLoaded && widget.scriptUrl != null) await _load(widget.scriptUrl!, script: true);
      final host = _host;
      if (!mounted || host == null || !_agGridLoaded) {
        if (mounted && !_agGridLoaded) setState(() => _failed = true);
        return;
      }
      final options = <String, Object?>{...widget.gridOptions, 'columnDefs': widget.columnDefs, 'rowData': widget.rowData}.jsify() as JSObject;
      // The row variants the web component marks, as AG Grid row classes.
      options['getRowClass'] = ((JSObject params) {
        final data = params['data'];
        final variant = data.isA<JSObject>() ? (data as JSObject)['variant'] : null;
        return variant.isA<JSString>() ? 'prime-row-${(variant as JSString).toDart}'.toJS : null;
      }).toJS;
      options['onRowClicked'] = ((JSObject event) {
        // The row's place in the data, not on screen: sorting and filtering reorder what is shown.
        final data = event['data'];
        final index = data.isA<JSObject>() ? (data as JSObject)['__primeIndex'] : null;
        if (index.isA<JSNumber>()) widget.onRowClicked?.call((index as JSNumber).toDartInt);
      }).toJS;
      final agGrid = globalContext['agGrid'] as JSObject;
      _api = agGrid.callMethod<JSObject>('createGrid'.toJS, host, options);
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void didUpdateWidget(_AgGridView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final api = _api;
    if (api == null) return;
    // Mirrors the web component: new column defs, rows, and options flow into the live grid.
    api.callMethod<JSAny?>(
      'updateGridOptions'.toJS,
      <String, Object?>{...widget.gridOptions, 'columnDefs': widget.columnDefs, 'rowData': widget.rowData}.jsify(),
    );
  }

  @override
  void dispose() {
    _api?.callMethod<JSAny?>('destroy'.toJS);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) return widget.fallback;
    return HtmlElementView(viewType: _viewType);
  }
}
