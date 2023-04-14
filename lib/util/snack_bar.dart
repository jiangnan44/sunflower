import 'package:flutter/material.dart';

class GlobalSnackBar {
  static GlobalKey<ScaffoldMessengerState> key = GlobalKey<ScaffoldMessengerState>();

  static void show(String? msg) {
    if (msg == null || msg.isEmpty) return;
    key.currentState!
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }
}
