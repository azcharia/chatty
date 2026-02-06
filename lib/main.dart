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

  // Initialize services
  await NotificationService().initialize();
  await ReminderService().initialize();
  await AkanePreferencesService().initialize();
  await AyashaPreferencesService().initialize();
  await CharacterConfig.loadCurrentCharacter();

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
