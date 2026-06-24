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

const supabaseUrl = 'https://ewtkteekwuphxgeksiiy.supabase.co/rest/v1/';
const supabaseKey =
    'sb_publishable_s34XGOlJoDeP1juZMIDz8Q_VVSWuJQw';

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

    // No saved login yet, go to login screen
    if (savedEmail == null || userId == null) {
      setState(() => _home = const LoginScreen());
      return;
    }

    final user = await DatabaseHelper.instance.getUserByEmail(savedEmail);

    if (user == null) {
      setState(() => _home = const LoginScreen());
      return;
    }

    final currentListId = await db.getUserListId(userId);

    setState(
      () => _home = user.role == 'teacher'
          ? const DashboardScreen()
          : ProgressScreen(listId: currentListId ?? 1),
    );
  } catch (e) {
    debugPrint('Error loading session: $e');
    setState(() => _home = const LoginScreen());
  }
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
