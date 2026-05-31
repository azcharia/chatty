import 'package:flutter/material.dart';
import 'openrouter_settings_screen.dart';

class SimpleSettingsScreen extends StatelessWidget {
  const SimpleSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the new OpenRouter settings screen
    return const OpenRouterSettingsScreen();
  }
}
