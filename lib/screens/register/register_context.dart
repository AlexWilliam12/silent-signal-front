import 'dart:io';

import 'package:flutter/material.dart';

class RegisterContext with ChangeNotifier {
  String user = '';
  String password = '';
  File? picture;
  bool isTermsAccepted = false;
  final key = GlobalKey<FormState>();
}
