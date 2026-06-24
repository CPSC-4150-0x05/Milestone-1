import 'package:flutter/material.dart';

class BottomNavScaffold extends StatelessWidget {
  final int currentIndex;
  final Widget body;
  final String title;

  const BottomNavScaffold({
    super.key,
    required this.currentIndex,
    required this.body,
    required this.title,
  });

  void _onTapNav(int index, BuildContext context) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/wordlist');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/practice');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/progress');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => _onTapNav(i, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Words',
          ),
          NavigationDestination(
            icon: Icon(Icons.mic_none_rounded),
            selectedIcon: Icon(Icons.mic_rounded),
            label: 'Practice',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}
