import 'dart:js_interop';
import 'dart:js_interop_unsafe';

JSObject get _document => globalContext['document'] as JSObject;

List<JSObject> _all(String selector) {
  final list = _document.callMethod<JSObject>('querySelectorAll'.toJS, selector.toJS);
  final length = (list['length'] as JSNumber).toDartInt;
  return [for (int i = 0; i < length; i++) list.callMethod<JSObject>('item'.toJS, i.toJS)];
}

/// The text of every element matching [selector], in page order.
List<String> textsOf(String selector) => [
  for (final element in _all(selector)) ((element['textContent'] as JSString?)?.toDart ?? '').trim(),
];

/// Clicks the first element matching [selector], as a user would.
bool clickFirst(String selector) {
  final elements = _all(selector);
  if (elements.isEmpty) return false;
  elements.first.callMethod<JSAny?>('click'.toJS);
  return true;
}

int countOf(String selector) => _all(selector).length;
