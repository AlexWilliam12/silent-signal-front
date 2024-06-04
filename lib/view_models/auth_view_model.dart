import 'dart:convert';

import 'package:refactoring/models/auth_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthViewModel {
  Future<String> login(AuthModel model) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String host = preferences.get('host')! as String;
    final response = await http.post(
      Uri.parse('http://$host/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': model.username,
        'password': model.password,
      }),
    );
    if (response.statusCode == 200) {
      await preferences.setString('token', jsonDecode(response.body)['token']);
      return '';
    }
    return response.body;
  }

  Future<String> register(AuthModel model) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String host = preferences.get('host')! as String;
    final response = await http.post(
      Uri.parse('http://$host/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'username': model.username,
        'password': model.password,
      }),
    );
    if (response.statusCode == 200) {
      await preferences.setString('token', jsonDecode(response.body)['token']);
      return '';
    }
    return response.body;
  }

  Future<bool> validateToken(String token) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String host = preferences.get('host')! as String;
    final response = await http.post(
      Uri.parse('http://$host/auth/validate/token'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200;
  }

  Future<String> validateHash(String hash) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String host = preferences.get('host')! as String;
    final response = await http.post(
      Uri.parse('http://$host/auth/validate/hash'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'hash': hash,
      }),
    );
    if (response.statusCode == 200) {
      await preferences.setString('token', jsonDecode(response.body)['token']);
      return '';
    }
    return response.body;
  }
}
