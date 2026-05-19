// Conditional import dispatcher.
// On web (dart.library.html available) → web_download_web.dart (dart:html).
// All other platforms              → web_download_stub.dart (no-op).
export 'web_download_stub.dart'
    if (dart.library.html) 'web_download_web.dart';
