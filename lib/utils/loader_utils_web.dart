import 'dart:js_interop';

@JS('removeLoadingIndicator')
external void _removeLoadingIndicator();

void removeWebLoadingIndicator() {
  _removeLoadingIndicator();
}
