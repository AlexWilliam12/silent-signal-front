import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:refactoring/models/sensitive_user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserViewModel with ChangeNotifier {
  SensitiveUserModel? _user;

  SensitiveUserModel? get user => _user;

  Future<void> fetchUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.get('token')! as String;
    String host = prefs.get('host')! as String;
    final response = await http.get(
      Uri.parse('http://$host/user'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    _user = response.statusCode == 200
        ? SensitiveUserModel.fromJson(jsonDecode(response.body))
        : null;
    notifyListeners();
  }

  Future<String> saveContact(String contact) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.get('token')! as String;
    String host = prefs.get('host')! as String;
    final response = await http.post(
      Uri.parse('http://$host/user/contact?name=$contact'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    return response.statusCode == 200
        ? 'Contact saved successfully!'
        : response.body;
  }

  Future<String> deleteContacts(List<String> contacts) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.get('token')! as String;
    String host = prefs.get('host')! as String;
    final response = await http.delete(
      Uri.parse('http://$host/user/contact'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(contacts.map((contact) => {'name': contact}).toList()),
    );
    return response.statusCode == 200
        ? 'Successfully deleted contacts!'
        : response.body;
  }

  Future<void> updateTemporaryMessages(String? interval) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.get('token')! as String;
    String host = prefs.get('host')! as String;
    final response = await http.post(
      Uri.parse('http://$host/user/temporary/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'time': interval}),
    );
    debugPrint(response.body);
  }
}
