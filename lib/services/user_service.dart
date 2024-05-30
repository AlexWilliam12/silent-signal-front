import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  Future<Map<String, dynamic>> fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.get('token')! as String;
    String host = prefs.get('host')! as String;
    final response = await http.get(Uri.parse('http://$host/user'), headers: {
      'Authorization': 'Bearer $token',
    });
    return response.statusCode == 200
        ? json.decode(response.body)
        : {'error': response.body};
  }
}
