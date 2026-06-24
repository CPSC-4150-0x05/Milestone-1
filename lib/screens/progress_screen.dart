import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_3_f25_project/models/user.dart';
import 'package:team_3_f25_project/models/wordlist.dart';
import 'package:team_3_f25_project/widgets/custom_app_bar.dart';
import '../services/user_db.dart';
import '../services/list_service.dart';

class ProgressScreen extends StatefulWidget {
  final int listId; // which word list this progress screen shows
  const ProgressScreen({super.key, required this.listId});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final db = DatabaseHelper.instance;
  SharedPreferences? prefs;
  int? userId;
  AppUser? user;
  double completion = 0;
  int totalWords = 0;
  int masteredWords = 0;
  List<WordList> words = [];
  List<Map<String, dynamic>> wordStatus = [];
  String? listCategory;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    prefs = await SharedPreferences.getInstance();
    userId = prefs!.getInt('userId');
    user = await DatabaseHelper.instance.getUser(userId!);
    listCategory = await WordService.getCategory(widget.listId);
    final wordsInList = await WordService.getWords(widget.listId);
    final allAttempts = await db.database.then((db) => db.query('attempts'));

    // Get list of correctly scored words
    final correctWords = allAttempts
        .where((a) => a['score'] == 1 && a['uid'] == userId)
        .map((a) => a['wordText'] as String)
        .toSet();

    setState(() {
      words = wordsInList;
      totalWords = words.length;
      masteredWords = words.where((w) => correctWords.contains(w.word)).length;
      completion = totalWords == 0 ? 0 : masteredWords / totalWords;

      // Map each word to its progress state
      wordStatus = words.map((w) {
        bool correct = correctWords.contains(w.word);
        return {'word': w.word, 'status': correct ? 'mastered' : 'pending'};
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      appBar: customAppBar(context: context),
      body: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/practice').then((_) {
          setState(() {
            _loadProgress();
          });
        }),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Hi ${user?.name}",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'You’ve mastered $masteredWords of $totalWords words!',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 20),
              // Circular progress bar
              SizedBox(
                width: 180,
                height: 180,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: completion,
                      strokeWidth: 100,
                      color: Colors.green,
                      backgroundColor: Colors.grey.shade300,
                    ),
                    Text(
                      '${(completion * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                listCategory ?? "",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),

              Expanded(
                child: ListView.builder(
                  itemCount: wordStatus.length,
                  itemBuilder: (context, index) {
                    final word = wordStatus[index]['word'];
                    final status = wordStatus[index]['status'];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        vertical: 6,
                        horizontal: 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      color: status == 'mastered'
                          ? Colors.green.shade100
                          : Colors.white,
                      child: ListTile(
                        leading: Icon(
                          status == 'mastered'
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          color: status == 'mastered'
                              ? Colors.green
                              : Colors.grey,
                          size: 32,
                        ),
                        title: Text(
                          word,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/practice').then((_) {
            setState(() {
              _loadProgress();
            });
          });
        },
        icon: const Icon(Icons.mic),
        label: const Text('Practice'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }
}
