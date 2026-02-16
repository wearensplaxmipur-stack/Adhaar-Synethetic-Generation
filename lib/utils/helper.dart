
import 'dart:typed_data';

import 'pdf_helper_mobile.dart'
if (dart.library.html) 'pdf_helper_web.dart';

Future<void> savePdf(Uint8List bytes, String fileName) {
  return savePdfImpl(bytes, fileName);
}
