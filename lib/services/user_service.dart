import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:silent_signal/models/sensitive_user.dart';

class UserService {
  static final _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  Future<SensitiveUser?> fetchUser() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String token = prefs.get('token')! as String;
      String host = prefs.get('host')! as String;
      final response = await http.get(
        Uri.parse('http://$host/user'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200
          ? SensitiveUser.fromJson(
              jsonDecode(response.body),
            )
          : null;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
