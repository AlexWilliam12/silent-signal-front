import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:refactoring/models/group_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GroupViewModel with ChangeNotifier {
  final _groups = <GroupModel>[];

  List<GroupModel> get groups => _groups;

  List<GroupModel> filter(String query) {
    return _groups.where((group) => group.name.contains(query)).toList();
  }

  Future<void> fetchAllGroups() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.get('token')! as String;
    String host = prefs.get('host')! as String;
    final response = await http.get(
      Uri.parse('http://$host/groups'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final groups = jsonDecode(response.body) as List;
      _groups.addAll(groups.map((json) => GroupModel.fromJson(json)));
      notifyListeners();
    }
  }

  Future<String> saveMember(String name) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.get('token')! as String;
    String host = prefs.get('host')! as String;
    final response = await http.post(
      Uri.parse('http://$host/group/member?groupName=$name'),
      headers: {'Authorization': 'Bearer $token'},
    );
    fetchAllGroups();
    return response.statusCode == 200
        ? 'Member saved successfully'
        : response.body;
  }

  Future<String> createGroup(String name, String description) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.get('token')! as String;
    String host = prefs.get('host')! as String;
    final response = await http.post(
      Uri.parse('http://$host/group'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'group_name': name, 'description': description}),
    );
    fetchAllGroups();
    return response.statusCode == 200
        ? 'Group created successfully'
        : 'Group already name exists';
  }
}
