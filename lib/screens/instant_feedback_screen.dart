// Screen that student sees immediately after attempting the word
// Screen color and icon are dependant on whether the word was successfully pronounced or not

import 'package:flutter/material.dart';
import 'package:team_3_f25_project/models/wordlist.dart';
import 'dart:async';

import 'package:team_3_f25_project/services/text_to_speech.dart';

class TimeOutScreen extends StatefulWidget {
  const TimeOutScreen({super.key});

  @override
  State<TimeOutScreen> createState() => _TimeOutScreenState();
}

class _TimeOutScreenState extends State<TimeOutScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.blue[400],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 10,
            children: [
              Icon(Icons.lock_clock_outlined, color: Colors.white, size: 250),
              Text(
                "Timed Out. Try Again.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 45.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class InstantFeedback extends StatefulWidget {
  bool success;
  WordList wordObject;
  InstantFeedback({super.key, required this.success, required this.wordObject});

  @override
  State<InstantFeedback> createState() => _InstantFeedbackState();
}

class _InstantFeedbackState extends State<InstantFeedback> {
  TextToSpeech textToSpeech = TextToSpeech();

  Future<void> speakWordAndSentence() async {
    // punctuation helps it sound more natural, allegedly
    await textToSpeech.speak("${widget.wordObject.word}.");
    await Future.delayed(Duration(seconds: 1), () {
      textToSpeech.speak(widget.wordObject.sentence1);
    });
    textToSpeech.stop();
  }

  @override
  void initState() {
    super.initState();
    textToSpeech.initTts();
    speakWordAndSentence().then(
      (_) => {
        {
          Timer(Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          }),
        },
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    textToSpeech.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.success ? Colors.green : Colors.amber[600],
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 150.0, horizontal: 50.0),
          child: Center(
            child: Column(
              spacing: 25.0,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.wordObject.word,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 90.0,
                      color: Colors.white,
                      shadows: [
                        Shadow(color: Colors.black38, offset: Offset(1.5, 2)),
                      ],
                    ),
                  ),
                ),
                Icon(
                  widget.success ? Icons.check_rounded : Icons.close,
                  color: Colors.white,
                  size: 250,
                ),
                Text(
                  textAlign: TextAlign.center,
                  softWrap: true,
                  overflow: TextOverflow.clip,
                  widget.wordObject.sentence1,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 35.0,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black38, offset: Offset(1.5, 2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
