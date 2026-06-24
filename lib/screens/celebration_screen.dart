import 'package:flutter/material.dart';
import 'package:team_3_f25_project/screens/progress_screen.dart';

class CelebrationScreen extends StatelessWidget {
  final int? nextListId;
  const CelebrationScreen({super.key, this.nextListId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      appBar: AppBar(centerTitle: true, backgroundColor: Colors.green.shade400),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Big icon and header message
              Icon(
                Icons.star_rounded,
                color: Colors.yellow.shade700,
                size: 250,
              ),
              const SizedBox(height: 20),
              Text(
                'Awesome Job!',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Colors.green.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              if (nextListId != null)
                FilledButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProgressScreen(listId: nextListId!),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.arrow_circle_right,
                    size: 100,
                    color: Colors.yellow.shade700,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
