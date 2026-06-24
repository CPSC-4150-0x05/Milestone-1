import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:team_3_f25_project/screens/login.dart';
import 'package:team_3_f25_project/screens/dashboard.dart';
import 'package:team_3_f25_project/screens/progress_screen.dart';
import 'package:team_3_f25_project/screens/word_practice_page.dart';
import 'package:team_3_f25_project/screens/signup.dart';
import 'package:team_3_f25_project/services/user_db.dart';

const supabaseUrl = 'https://gelfwoihoznpghcpfylf.supabase.co';
const supabaseKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdlbGZ3b2lob3pucGdoY3BmeWxmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ3OTc3MTUsImV4cCI6MjA4MDM3MzcxNX0.y8yPV32YatDe5VBE-u6pzfU0SmL9l2BnlW1NpIlfgVU';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  // Local database
  final sync = await DatabaseHelper.instance.syncService;

  // Initial sync on app start
  await sync.fullSync(tableName: 'users', primaryKey: 'id');
  await sync.fullSync(tableName: 'attempts', primaryKey: 'id');
  await sync.fullSync(tableName: 'currentList', primaryKey: 'id');

  // Periodic background sync
  Timer.periodic(Duration(minutes: 1), (timer) {
    sync.fullSync(tableName: 'users', primaryKey: 'id');
    sync.fullSync(tableName: 'attempts', primaryKey: 'id');
    sync.fullSync(tableName: 'currentList', primaryKey: 'id');
  });
  runApp(ReadRightApp());
}

class ReadRightApp extends StatefulWidget {
  const ReadRightApp({super.key});

  @override
  State<ReadRightApp> createState() => _ReadRightAppState();
}

class _ReadRightAppState extends State<ReadRightApp> {
  Widget _home = const Scaffold(
    body: Center(child: CircularProgressIndicator()),
  );

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('email');
      final userId = prefs.getInt('userId');
      final currentListId = await db.getUserListId(userId!);
      if (savedEmail != null) {
        final user = await DatabaseHelper.instance.getUserByEmail(savedEmail);
        if (user != null) {
          setState(
            () => _home = user.role == 'teacher'
                ? const DashboardScreen()
                : ProgressScreen(listId: currentListId!),
          );
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading session: $e');
    }
    setState(() => _home = const LoginScreen());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReadRight',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: false),
      home: _home,
      routes: {
        '/dashboard': (context) => const DashboardScreen(),
        '/progress_screen': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return ProgressScreen(listId: args['listId'] ?? 1);
        },
        '/practice': (context) => WordPracticeScreen(),
        '/signup': (context) => const SignupScreen(),
      },
    );
  }
}
