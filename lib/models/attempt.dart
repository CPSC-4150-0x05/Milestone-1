// lib/models/attempt.dart
import 'dart:convert';

class Attempt {
  final int? uid;
  final String wordText;
  final int? listId;
  final int score;
  final String feedback;
  final DateTime createdAt;
  final Duration duration;
  final String recordingPath;

  Attempt({
    required this.uid,
    required this.wordText,
    required this.listId,
    required this.score,
    required this.feedback,
    required this.createdAt,
    required this.duration,
    required this.recordingPath,
  });

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'wordText': wordText,
    'listId': listId,
    'score': score,
    'feedback': feedback,
    'createdAt': createdAt.toIso8601String(),
    'durationMs': duration.inMilliseconds,
    'recordingPath': recordingPath,
  };

  static Attempt fromMap(Map<String, dynamic> map) => Attempt(
    uid: map['uid'] as int,
    wordText: map['wordText'] as String,
    listId: map['listId'] as int,
    score: map['score'] as int,
    feedback: map['feedback'] as String,
    createdAt: DateTime.parse(map['createdAt'] as String),
    duration: Duration(milliseconds: (map['durationMs'] as num).toInt()),
    recordingPath: map['recordingPath'] as String,
  );

  String toJson() => jsonEncode(toMap());
  static Attempt fromJson(String s) => fromMap(jsonDecode(s));
}
