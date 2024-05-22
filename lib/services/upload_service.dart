import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mime/mime.dart';

class UploadService {
  static final UploadService _instance = UploadService._internal();

  factory UploadService() {
    return _instance;
  }

  UploadService._internal();

  Future<void> uploadPicture(File file) async {
    final pref = await SharedPreferences.getInstance();
    final host = pref.get('host');
    final request =
        http.MultipartRequest('POST', Uri.parse('http://$host/upload/picture'));
    final type = lookupMimeType(file.path) ?? 'application/octet-stream';
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType.parse(type),
      ),
    );
    final response = await request.send();
    if (response.statusCode != 200) {
      debugPrint(await response.stream.bytesToString());
    }
  }
}
