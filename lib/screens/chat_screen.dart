import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/profile_picture_widget.dart';
import '../config/character_config.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _prevMessageCount = 0;

  @override
  void initState() {
    super.initState();
    // Reload chat for current character
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().switchCharacter();
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isNotEmpty) {
      context.read<ChatProvider>().sendMessage(message);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0, // For reverse ListView, 0 is the bottom
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final character = CharacterConfig.current;
    final activeColor = character.id == 'akane' ? Colors.pink.shade300 : Colors.blue.shade300;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: theme.colorScheme.surface.withValues(
                alpha: isDark ? 0.5 : 0.7,
              ),
            ),
          ),
        ),
        title: Consumer<ChatProvider>(
          builder: (context, chatProvider, child) {
            final profile = chatProvider.userProfile;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(character.avatar),
                    const SizedBox(width: 8),
                    Text(character.name),
                  ],
                ),
                if (profile != null)
                  Text(
                    'Chat dengan ${profile.nickname ?? profile.name}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            );
          },
        ),
        actions: [
          // Home Button
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            tooltip: 'Back to Home',
          ),
          // Theme Toggle Button
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(themeProvider.themeIcon),
                onPressed: () => themeProvider.toggleTheme(),
                tooltip: '${themeProvider.themeModeString} Mode',
              );
            },
          ),
          // Profile Picture Button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: const ProfilePictureWidget(size: 35, isEditable: false),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: character.id == 'akane'
                ? [
                    Colors.pink.shade300.withValues(alpha: isDark ? 0.08 : 0.12),
                    Colors.purple.shade300.withValues(alpha: isDark ? 0.08 : 0.12),
                    theme.colorScheme.surface,
                  ]
                : [
                    Colors.blue.shade300.withValues(alpha: isDark ? 0.08 : 0.12),
                    Colors.teal.shade300.withValues(alpha: isDark ? 0.08 : 0.12),
                    theme.colorScheme.surface,
                  ],
          ),
        ),
        child: SafeArea(
          top: false, // Let chat content flow behind AppBar
          bottom: true,
          child: Consumer<ChatProvider>(
            builder: (context, chatProvider, child) {
              if (chatProvider.isLoading) {
                _prevMessageCount = 0; // Reset count on character switch / load
                return const Center(child: CircularProgressIndicator());
              }

              // Cek penambahan pesan baru secara pintar untuk menghindari yanking-bottom bug saat membaca chat lama
              final currentCount = chatProvider.messages.length;
              if (currentCount > _prevMessageCount) {
                final isFirstLoad = _prevMessageCount == 0;
                final isNearBottom = !_scrollController.hasClients || _scrollController.offset < 200.0;

                if (isFirstLoad || isNearBottom) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                }
                _prevMessageCount = currentCount;
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(
                        top: MediaQuery.paddingOf(context).top + kToolbarHeight + 16,
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      reverse: true, // Start from bottom
                      itemCount:
                          chatProvider.messages.length +
                          (chatProvider.isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == 0 && chatProvider.isTyping) {
                          return const TypingIndicator();
                        }

                        final messageIndex =
                            chatProvider.isTyping ? index - 1 : index;
                        final reversedIndex =
                            chatProvider.messages.length - 1 - messageIndex;
                        final message = chatProvider.messages[reversedIndex];
                        return MessageBubble(message: message);
                      },
                    ),
                  ),
                  ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: isDark ? 0.6 : 0.85,
                          ),
                          border: Border(
                            top: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.05),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  hintText: 'Ketik pesan...',
                                  filled: true,
                                  fillColor: isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.02),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.black.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.1)
                                          : Colors.black.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide(
                                      color: activeColor,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                                maxLines: null,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _sendMessage(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FloatingActionButton(
                              onPressed: _sendMessage,
                              mini: true,
                              backgroundColor: activeColor,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              child: const Icon(Icons.send),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
