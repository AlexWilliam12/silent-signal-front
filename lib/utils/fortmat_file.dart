import 'dart:io';

import 'package:path/path.dart' as path;

File formatFile(File originalFile, String extension) {
  final dir = path.dirname(originalFile.path);
  final base = path.basenameWithoutExtension(originalFile.path);
  final newPath = path.join(dir, '$base.$extension');
  final file = File(newPath);
  return originalFile.copySync(file.path);
}
