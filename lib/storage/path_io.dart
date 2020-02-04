import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> getPath() async {
  final p = Platform.isIOS
      ? await getLibraryDirectory()
      : await getExternalStorageDirectory();
  return p.path;
}
