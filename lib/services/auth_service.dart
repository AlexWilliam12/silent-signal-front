import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  Future<Map<String, dynamic>> login(String username, String password) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String host = pref.get('host')! as String;
    final response = await http.post(Uri.parse('http://$host/auth/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }));
    return response.statusCode == 200
        ? json.decode(response.body)
        : {'error': response.body};
  }

  Future<Map<String, dynamic>> register(String username, String password) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String host = pref.get('host')! as String;
    final response = await http.post(Uri.parse('http://$host/auth/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'username': username,
          'password': password,
        }));
    return response.statusCode == 200
        ? json.decode(response.body)
        : {'error': response.body};
  }

  Future<Map<String, dynamic>> validateToken(String token) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String host = pref.get('host')! as String;
    final response = await http.post(Uri.parse('http://$host/auth/validate-token'),
        headers: {
          'Authorization': 'Bearer $token',
        });
    return response.statusCode == 200
        ? {}
        : {'error': response.body};
  }

  Future<Map<String, dynamic>> validateHash(String hash) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String host = pref.get('host')! as String;
    final response = await http.post(Uri.parse('http://$host/auth/validate-hash'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'hash': hash,
        }));
    return response.statusCode == 200
        ? json.decode(response.body)
        : {'error': response.body};
  }
}
