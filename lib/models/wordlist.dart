//import 'package:flutter/services.dart' show rootBundle;
//import 'package:csv/csv.dart';

class WordWithSentences {
  final String word;
  final String sentence1;
  final String sentence2;
  final String sentence3;

  WordWithSentences({
    required this.word,
    required this.sentence1,
    required this.sentence2,
    required this.sentence3,
  });
}

// Class for word list
class WordList {
  final int id;
  final int listId;
  int priority;
  final String category;
  final String word;
  final String sentence1;
  final String sentence2;
  final String sentence3;

  // Word list constructor
  WordList({
    required this.id,
    required this.listId,
    required this.priority,
    required this.category,
    required this.word,
    required this.sentence1,
    required this.sentence2,
    required this.sentence3,
  });

  factory WordList.fromCSV(List<dynamic> type) {
    return WordList(
      id: int.parse(type[0]),
      listId: int.parse(type[1]),
      priority: int.parse(type[2]),
      category: type[3],
      word: type[4],
      sentence1: type[5],
      sentence2: type[6],
      sentence3: type[7],
    );
  }
}
