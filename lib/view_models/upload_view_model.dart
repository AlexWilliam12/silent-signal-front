import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UploadViewModel {
  Future<void> uploadUserPicture(File file) async {
    final pref = await SharedPreferences.getInstance();
    final host = pref.get('host');
    final token = pref.get('token');
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://$host/upload/user/picture'),
    );
    final type = lookupMimeType(file.path) ?? 'application/octet-stream';
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType.parse(type),
      ),
    );
    request.headers['Authorization'] = 'Bearer $token';
    await request.send();
  }

  Future<void> updatePicture(File file) async {
    final pref = await SharedPreferences.getInstance();
    final host = pref.get('host');
    final token = pref.get('token');
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('http://$host/upload/user/picture'),
    );
    final type = lookupMimeType(file.path) ?? 'application/octet-stream';
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType.parse(type),
      ),
    );
    request.headers['Authorization'] = 'Bearer $token';
    await request.send();
  }

  Future<String> uploadChatFile(File file) async {
    final pref = await SharedPreferences.getInstance();
    final host = pref.get('host');
    final token = pref.get('token');
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'http://$host/upload/chat/file',
      ),
    );
    final type = lookupMimeType(file.path) ?? 'application/octet-stream';
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType.parse(type),
      ),
    );
    request.headers['Authorization'] = 'Bearer $token';
    final response = await request.send();
    if (response.statusCode == 201) {
      return response.headers['location'] as String;
    }
    return '';
  }
}
