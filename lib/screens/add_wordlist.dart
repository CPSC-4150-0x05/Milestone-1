import 'package:flutter/material.dart';
import '../services/list_service.dart';
import '../models/wordlist.dart';

// --- Color Definitions (matching WordlistManagementScreen) ---
const Color kPrimaryColor = Colors.blueAccent;
const Color kLightBackgroundColor = Color(0xFFE3F2FD);
const Color kEncouragementColor = Colors.lightBlue;

class AddWordlistScreen extends StatefulWidget {
  const AddWordlistScreen({super.key});

  @override
  State<AddWordlistScreen> createState() => _AddWordlistScreenState();
}

class _AddWordlistScreenState extends State<AddWordlistScreen> {
  final TextEditingController _titleController = TextEditingController();
  List<WordWithSentences> words = [];

  void _addWordDialog() {
    final wordCtrl = TextEditingController();
    final s1Ctrl = TextEditingController();
    final s2Ctrl = TextEditingController();
    final s3Ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Add Word",
          style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor),
        ),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: wordCtrl,
                decoration: InputDecoration(
                  labelText: "Word",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: kPrimaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: s1Ctrl,
                decoration: InputDecoration(
                  labelText: "Sentence 1",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: kPrimaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: s2Ctrl,
                decoration: InputDecoration(
                  labelText: "Sentence 2",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: kPrimaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: s3Ctrl,
                decoration: InputDecoration(
                  labelText: "Sentence 3",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: kPrimaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (wordCtrl.text.isNotEmpty &&
                  s1Ctrl.text.isNotEmpty &&
                  s2Ctrl.text.isNotEmpty &&
                  s3Ctrl.text.isNotEmpty) {
                setState(() {
                  words.add(
                    WordWithSentences(
                      word: wordCtrl.text.trim(),
                      sentence1: s1Ctrl.text.trim(),
                      sentence2: s2Ctrl.text.trim(),
                      sentence3: s3Ctrl.text.trim(),
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  /// Import CSV
  Future<void> _importCSV() async {
    final imported = await WordService.importCSV();

    if (imported == null || imported.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No CSV found or file empty.")),
      );
      return;
    }

    setState(() {
      words.addAll(imported);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Imported ${imported.length} words.")),
    );
  }

  /// SAVE LIST
  Future<void> _saveList() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("List Title is required")));
      return;
    }
    if (words.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Add at least 1 word")));
      return;
    }

    await WordService.addListOfWords(words, _titleController.text.trim());

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Create Word List",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions Container (matching WordlistManagement style)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kEncouragementColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: kEncouragementColor, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: kPrimaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "CSV format: word,sentence1,sentence2,sentence3\nOr enter words manually below",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Import CSV Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _importCSV,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Import Wordlist CSV"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // List Title Input
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "List Title",
                  labelStyle: const TextStyle(color: kPrimaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: kPrimaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 20),

              // Add Word Button
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _addWordDialog,
                    icon: const Icon(Icons.add),
                    label: const Text("Add Word"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "${words.length} word${words.length != 1 ? 's' : ''} added",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Words List
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: words.length,
                itemBuilder: (_, i) {
                  final w = words[i];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    color: Colors.white,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      title: Text(
                        w.word,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          w.sentence1,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => words.removeAt(i)),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveList,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    "Save Word List",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
