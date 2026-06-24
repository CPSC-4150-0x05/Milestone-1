import 'package:flutter/material.dart';
import 'package:team_3_f25_project/services/user_db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_3_f25_project/screens/login.dart';
import 'package:audioplayers/audioplayers.dart';

class MissedWordsScreen extends StatefulWidget {
  final String? email;
  final String classCode;
  final String? studentName;

  const MissedWordsScreen({
    super.key,
    this.email,
    required this.classCode,
    this.studentName,
  });

  @override
  State<MissedWordsScreen> createState() => _MissedWordsScreenState();
}

class _MissedWordsScreenState extends State<MissedWordsScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final future = widget.email != null
        ? DatabaseHelper.instance.getMissedWordsByStudent(widget.email!)
        : DatabaseHelper.instance.getClassMissedWords(widget.classCode);

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(
          widget.email != null
              ? "${widget.studentName} Missed Words"
              : "Class Missed Words",
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent[50],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final missedWords = snapshot.data!;

          return Column(
            children: [
              if (widget.email != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),

                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // User ID
                          Expanded(
                            child: Text(
                              'User ID: ${widget.email}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Reset Password Button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange.shade400,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.lock_reset, size: 18),
                            label: const Text(
                              'Reset Password',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            onPressed: () {
                              DatabaseHelper.instance.resetPassword(
                                widget.email!,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          '${widget.studentName}\'s password has been reset to \'ssssssss\'',
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              // Missed Words List
              Expanded(
                child: missedWords.isEmpty
                    ? Center(
                        child: Text(
                          widget.email != null
                              ? "No missed words! ${widget.studentName} is doing a great job!"
                              : "No missed words for the class! Everyone is doing a great job!",
                          style: const TextStyle(fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: missedWords.length,
                        itemBuilder: (context, index) {
                          final word = missedWords[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
                                    final player = AudioPlayer();
                                    final path = word['lastRecording'];

                                    if (path == null || path.isEmpty) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "No recording data available for the word",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    try {
                                      await player.play(DeviceFileSource(path));
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Error Playing Audio. It's likely the original audio is saved on another device.",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: widget.email != null
                                                  ? Row(
                                                      spacing: 20.0,
                                                      children: [
                                                        Icon(
                                                          Icons.play_circle,
                                                          size: 35,
                                                          color:
                                                              Colors.blueAccent,
                                                        ),
                                                        Text(
                                                          word['wordText'],
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black87,
                                                              ),
                                                        ),
                                                      ],
                                                    )
                                                  : Text(
                                                      word['wordText'],
                                                      style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.blueAccent,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                "Attempts: ${word['attempts']}",
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
