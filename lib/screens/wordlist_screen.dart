import 'dart:math';
import 'package:flutter/material.dart';
import 'package:team_3_f25_project/models/wordlist.dart';
import 'package:team_3_f25_project/services/list_service.dart';
import 'package:team_3_f25_project/widgets/custom_app_bar.dart';

// --- Color Definitions (matching other screens) ---
const Color kPrimaryColor = Colors.blueAccent;
const Color kLightBackgroundColor = Color(0xFFE3F2FD);
const Color kEncouragementColor = Colors.lightBlue;

class WordlistScreen extends StatefulWidget {
  final int listId;
  const WordlistScreen({super.key, required this.listId});

  @override
  State<WordlistScreen> createState() => _WordlistScreenState();
}

class _WordlistScreenState extends State<WordlistScreen> {
  String? listCategory;
  List<WordList>? wordsInList;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  void _loadList() async {
    setState(() => _isLoading = true);
    listCategory = await WordService.getCategory(widget.listId);
    wordsInList = await WordService.getWords(widget.listId);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightBackgroundColor,
      appBar: AppBar(
        title: Text(
          listCategory ?? "Word List",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Card with List Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: kEncouragementColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kEncouragementColor, width: 2),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.book, color: kPrimaryColor, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                listCategory ?? "Word List",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: kPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${wordsInList?.length ?? 0} word${(wordsInList?.length ?? 0) != 1 ? 's' : ''}",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Words List
                  Expanded(
                    child: wordsInList == null || wordsInList!.isEmpty
                        ? Center(
                            child: Text(
                              "No words in this list",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: wordsInList?.length ?? 0,
                            itemBuilder: (context, index) {
                              final word = wordsInList?[index].word;
                              final sentence1 = wordsInList?[index].sentence1;
                              final sentence2 = wordsInList?[index].sentence2;
                              final sentence3 = wordsInList?[index].sentence3;

                              return Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                color: Colors.white,
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
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
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    word ?? "Word",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E88E5),
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      sentence1 ?? "",
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        0,
                                        16,
                                        16,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Divider(),
                                          const SizedBox(height: 8),
                                          _buildSentenceRow(
                                            "1",
                                            sentence1 ?? "",
                                          ),
                                          const SizedBox(height: 8),
                                          _buildSentenceRow(
                                            "2",
                                            sentence2 ?? "",
                                          ),
                                          const SizedBox(height: 8),
                                          _buildSentenceRow(
                                            "3",
                                            sentence3 ?? "",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSentenceRow(String number, String sentence) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: kEncouragementColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: kEncouragementColor, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: kPrimaryColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            sentence,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
