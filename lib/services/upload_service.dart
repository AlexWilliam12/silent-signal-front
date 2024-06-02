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
    final response = await request.send();
    if (response.statusCode != 200) {
      debugPrint(await response.stream.bytesToString());
    }
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
    final response = await request.send();
    if (response.statusCode != 200) {
      debugPrint(await response.stream.bytesToString());
    }
  }

  Future<dynamic> uploadPrivateChatFile(File file, String recipient) async {
    final pref = await SharedPreferences.getInstance();
    final host = pref.get('host');
    final token = pref.get('token');
    final type = lookupMimeType(file.path) ?? 'application/octet-stream';
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'http://$host/upload/private/chat?recipient=$recipient&type=$type',
      ),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
        contentType: MediaType.parse(type),
      ),
    );
    request.headers['Authorization'] = 'Bearer $token';
    final response = await request.send();
    return response.statusCode == 201
        ? {'location': response.headers['location']}
        : {'error': response.stream.bytesToString()};
  }
}
