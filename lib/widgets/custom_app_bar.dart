import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_3_f25_project/screens/login.dart';

AppBar customAppBar({dynamic context, String title = ""}) {
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('userId');
    await prefs.remove('classCode');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  return AppBar(
    title: Text(title, style: TextStyle(color: Colors.white)),
    backgroundColor: Colors.blueAccent,

    actions: [
      ElevatedButton.icon(
        onPressed: () {
          logout(context);
        },
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepOrange,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    ],
  );
}
