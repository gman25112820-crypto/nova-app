// Web implementation — compiled only when dart.library.html is available.
// Uses package:web (dart:js_interop) — the current Flutter Web standard.
import 'dart:js_interop';

import 'package:web/web.dart' as web;

void triggerDownload(String content, String fileName, String mimeType) {
  final web.Blob blob = web.Blob(
    [content.toJS].toJS,
    web.BlobPropertyBag(type: mimeType),
  );
  final String url = web.URL.createObjectURL(blob);
  final web.HTMLAnchorElement anchor =
      web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download = fileName;
  anchor.click();
  web.URL.revokeObjectURL(url);
}
