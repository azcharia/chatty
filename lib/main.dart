import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'providers/chat_provider.dart';
import 'providers/theme_provider.dart';
import 'config/character_config.dart';
import 'services/notification_service.dart';
import 'services/reminder_service.dart';
import 'services/akane_preferences_service.dart';
import 'services/ayasha_preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services with try-catch safety guards to prevent native crashes on startup
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('NotificationService init error: $e');
  }

  try {
    await ReminderService().initialize();
  } catch (e) {
    debugPrint('ReminderService init error: $e');
  }

  try {
    await AkanePreferencesService().initialize();
  } catch (e) {
    debugPrint('AkanePreferencesService init error: $e');
  }

  try {
    await AyashaPreferencesService().initialize();
  } catch (e) {
    debugPrint('AyashaPreferencesService init error: $e');
  }

  try {
    await CharacterConfig.loadCurrentCharacter();
  } catch (e) {
    debugPrint('CharacterConfig load error: $e');
  }

  runApp(const ChattyApp());
}

class ChattyApp extends StatelessWidget {
  const ChattyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider()..initialize(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Chatty - AI Companion',
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
