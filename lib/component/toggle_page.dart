import 'package:flutter/material.dart';
import 'package:mood_music_app/home_screen.dart';
import 'package:mood_music_app/prompt_screen.dart';

class TogglePage extends StatefulWidget {
  const TogglePage({super.key});

  @override
  State<TogglePage> createState() => _TogglePageState();
}

class _TogglePageState extends State<TogglePage> {
  bool _showHomeScreen = true;

  void _toggleScreen() {
    setState(() {
      _showHomeScreen = !_showHomeScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showHomeScreen) {
      return HomeScreen(
        showPromtScreen: _toggleScreen,
      );
    } else {
      return PromptScreen(
        showHomeScreen: _toggleScreen,
      );
    }
  }
}
