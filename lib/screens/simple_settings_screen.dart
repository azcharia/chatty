import 'package:flutter/material.dart';
import 'groq_settings_screen.dart';

class SimpleSettingsScreen extends StatelessWidget {
  const SimpleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the new Groq settings screen
    return const GroqSettingsScreen();
  }
}
