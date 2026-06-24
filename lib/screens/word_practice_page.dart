import 'dart:io';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:team_3_f25_project/models/wordlist.dart';
import 'package:team_3_f25_project/services/list_service.dart';
import 'package:team_3_f25_project/widgets/custom_app_bar.dart';
import 'package:team_3_f25_project/widgets/record_button.dart';
import 'package:team_3_f25_project/widgets/word_card.dart';
import 'package:team_3_f25_project/models/attempt.dart';
import 'package:team_3_f25_project/screens/instant_feedback_screen.dart';
import 'package:team_3_f25_project/screens/celebration_screen.dart';
import 'package:record/record.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:team_3_f25_project/services/user_db.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_3_f25_project/data/homophones.dart';
import 'package:permission_handler/permission_handler.dart';

final db = DatabaseHelper.instance;

class WordPracticeScreen extends StatefulWidget {
  final db = DatabaseHelper.instance;
  WordPracticeScreen({super.key});

  @override
  State<WordPracticeScreen> createState() => _WordPracticeScreenState();
}

class _WordPracticeScreenState extends State<WordPracticeScreen> {
  // variables to keep track of progress
  SharedPreferences? prefs;
  int? userId;
  int? currentListId;
  List<WordList>? completeWordList;
  List<String>? wordsToPractice;
  int nextIndex = 0;

  String get currentWord {
    if (wordsToPractice == null || wordsToPractice!.isEmpty) return '';
    return wordsToPractice![nextIndex];
  }

  // WordList contains the sentences for the word as well
  WordList get currentWordObject {
    return completeWordList!.firstWhere((word) => word.word == currentWord);
  }

  // Error handling
  bool _loading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // variables for recording / listening
  final _speechToText = SpeechToText();
  final _recorder = AudioRecorder();
  int correctlyPronounced = 0;
  String recordingPath = "";
  bool _speechEnabled = false;
  bool _isListening = false;

  // timer variables
  Duration _elapsed = Duration.zero;
  Timer? _timer;
  static const Duration kMax = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _loadUserAndWords();
    _initSpeech();
  }

  // microphone permissions
  Future<bool> _requestMicrophonePermission() async {
    if (Platform.isIOS) {
      return true;
    }

    // Android: use permission_handler
    var status = await Permission.microphone.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      status = await Permission.microphone.request();
      if (status.isGranted) {
        setState(() {});
        return true;
      }
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {}
      return false;
    }

    if (status.isRestricted) {
      return false;
    }

    return false;
  }

  // populate variables for tracking progress
  Future<void> _loadUserAndWords() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      // gets shared preferences to load user data and see user progress
      prefs = await SharedPreferences.getInstance();
      userId = prefs!.getInt('userId');

      // get list of words to practice
      currentListId = await db.getUserListId(userId!);
      completeWordList = await WordService.getWords(currentListId!);

      // initialize list of only word strings
      wordsToPractice = completeWordList!.map((entry) => entry.word).toList();

      // find and remove words user has gotten correct in the past
      Set<String> correctWords = await widget.db.getAllCorrectWords(userId!);
      wordsToPractice!.removeWhere((word) => correctWords.contains(word));

      // used for progress tracking
      correctlyPronounced = completeWordList!.length - wordsToPractice!.length;

      // async management
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  // initialize speech to text functionality
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _nextWord(bool correct) {
    setState(() {
      if (correct) {
        // correct word was already removed from word to practice
        nextIndex = nextIndex % wordsToPractice!.length;
      } else {
        // incorrect word stays in list
        nextIndex = nextIndex + 1 % wordsToPractice!.length;
      }
    });
  }

  void _removeWordFromList() {
    // removes current word from words to practice
    if (wordsToPractice!.isNotEmpty) {
      wordsToPractice!.remove(currentWord);
    }
  }

  // user finished list
  void _finishList() async {
    // get next highest priority with list service
    int? nextListId = await WordService.getNextListID(currentListId!);

    // update database with new list ID
    if (nextListId != null) {
      await db.updateUserListId(userId!, nextListId);
    }

    // go to celebration screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CelebrationScreen(nextListId: nextListId),
      ),
    );
  }

  void _startListening() async {
    // mic permissions
    if (Platform.isIOS) {
      if (!_speechEnabled) {
        _speechEnabled = await _speechToText.initialize();
        if (!_speechEnabled) {
          return;
        }
      }
    } else {
      // Android: Check permission_handler first
      final hasPermission = await _requestMicrophonePermission();
      if (!hasPermission) {
        return;
      }
    }

    // start speech to text engine
    await _speechToText.listen(
      onResult: _onSpeechResult,
      localeId: 'en_US', // Specify the locale
      listenFor: kMax, // How long to listen
      pauseFor: const Duration(seconds: 2), // How long to wait for pause
    );

    // start recording
    final config = RecordConfig(
      encoder: AudioEncoder.aacLc, // -> .m4a
      sampleRate: 44100,
      bitRate: 128000,
    );
    recordingPath = await _nextPath();
    await _recorder.start(config, path: recordingPath);

    setState(() {
      _isListening = true;
      _elapsed = Duration.zero;
    });

    // keep track of time and push timeout screen if needed
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (t) {
      final next = _elapsed + const Duration(milliseconds: 200);
      if (next > kMax && _isListening) {
        _stopListening();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TimeOutScreen()),
        );
      } else {
        setState(() {
          _elapsed = next;
        });
      }
    });
  }

  // stop all recording and STT engines
  void _stopListening() async {
    setState(() {
      _timer?.cancel();
      _isListening = false;
    });
    await _speechToText.stop();
    await _recorder.stop();
  }

  bool _isCorrect(String recognizedWord) {
    // if speech to text already matched, no need for further checking
    if (recognizedWord.toLowerCase() == currentWord.toLowerCase()) {
      return true;
    }

    // if not, check for homophones
    return Homophones().isHomophone(recognizedWord, currentWord);
  }

  // process end of recording
  void _onSpeechResult(SpeechRecognitionResult? result) {
    // only process final result, not intermediate ones
    if (result!.finalResult) {
      // stop listening and check if correct
      _stopListening();
      bool correct = _isCorrect(result.recognizedWords);

      // add attempt to database
      widget.db.insertAttempt(
        Attempt(
          uid: userId!,
          wordText: currentWord,
          listId: currentListId,
          score: correct ? 1 : 0,
          createdAt: DateTime.now(),
          feedback: correct ? "Great job" : "Try again",
          recordingPath: recordingPath,
          duration: _elapsed,
        ),
      );

      // Feedback page to user
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              InstantFeedback(success: correct, wordObject: currentWordObject),
        ),
      ).then((_) {
        if (correct) {
          // increment correctly pronounced words and remove from user's practice list
          correctlyPronounced++;
          _removeWordFromList();
        }
        if (correctlyPronounced == completeWordList!.length ||
            wordsToPractice!.isEmpty) {
          // if all words have been correctly pronounced, finish list
          _finishList();
        } else {
          // move onto next word, whether correct or not
          _nextWord(correct);
        }
      });
    }
  }

  @override
  void dispose() {
    _speechToText.stop();
    _recorder.dispose();
    super.dispose();
  }

  Future<String> _nextPath() async {
    // make path for saving audio (local on device only)
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    return '${dir.path}/readright_$currentWord$ts.m4a';
  }

  // widget body
  Widget _buildBody() {
    // Loading state
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blueGrey),
      );
    }

    // Error state
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error: $_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadUserAndWords,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state - no words to practice
    if (wordsToPractice == null || wordsToPractice!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              'No words to practice!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('You\'ve mastered all words in this list!'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _finishList,
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    }

    // Everything okay
    return Center(
      child: Column(
        spacing: 10.0,
        children: [
          // progress at top of screen
          LinearProgressIndicator(
            value:
                correctlyPronounced /
                (correctlyPronounced + wordsToPractice!.length),
            color: Colors.green,
            backgroundColor: Colors.grey.shade300,
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Text(
              'Progress: $correctlyPronounced / ${completeWordList!.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          // word card and record button
          WordCard(
            wordText: currentWord,
            patternLabel: "Pattern label",
            sampleSentence: "Sample sentence",
          ),
          RecordButton(
            isRecording: _isListening,
            onTap: _speechEnabled
                ? () {
                    if (_isListening) {
                      _stopListening();
                    } else {
                      _startListening();
                    }
                  }
                : null,
          ),
          const SizedBox(height: 15.0),
          // Stop practicing button
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 250,
              // 250 is also the width of the record button
              decoration: BoxDecoration(
                color: Colors.orange[100],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                border: Border.all(color: Colors.orange, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.stop_rounded, size: 50, color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: customAppBar(context: context),
      body: _buildBody(),
    );
  }
}
