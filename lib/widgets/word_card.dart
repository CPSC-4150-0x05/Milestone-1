import 'package:flutter/material.dart';

class WordCard extends StatelessWidget {
  final String wordText;
  final String patternLabel;
  final String sampleSentence;
  final VoidCallback? onPractice;

  const WordCard({
    super.key,
    required this.wordText,
    required this.patternLabel,
    required this.sampleSentence,
    this.onPractice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
      child: Center(
        //padding: const EdgeInsets.all(16),
        child: Container(
          padding: EdgeInsets.all(45.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              wordText,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 90.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
