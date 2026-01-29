// lib/views/user/user_ai_assistant_screen.dart
// ✅ COMPLETE IMPLEMENTATION - Real API Integration

// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import '../../config/api_config.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/ui/glass_card.dart';
import '../../widgets/ui/chip_pill.dart';

class UserAiAssistantScreen extends StatefulWidget {
  const UserAiAssistantScreen({super.key});

  @override
  State<UserAiAssistantScreen> createState() => _UserAiAssistantScreenState();
}

class _UserAiAssistantScreenState extends State<UserAiAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_AiMessage> _messages = [
    const _AiMessage(
      text: 'Hi 👋 I\'m your AI beauty assistant! I can help you find salons, book appointments, and give you haircare tips. What can I help you with today?',
      isUser: false,
    ),
  ];

  bool _isLoading = false;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// ✅ Load contextual suggestions from backend
  Future<void> _loadSuggestions() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final token = await user.getIdToken();

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/chatbot/user/suggestions/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _suggestions = List<String>.from(data['suggestions'] ?? []);
        });
      }
    } catch (e) {
      print('Error loading suggestions: $e');
      // Set default suggestions on error
      setState(() {
        _suggestions = [
          'Find salons near me',
          'Show my appointments',
          'Haircare tips',
          'How do I book?',
        ];
      });
    }
  }

  /// ✅ Send message to backend AI chatbot
  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final userMessage = _controller.text.trim();
    _controller.clear();

    // Add user message to UI
    setState(() {
      _messages.add(_AiMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _addBotMessage('Please log in to use the AI assistant.');
        return;
      }

      final token = await user.getIdToken();

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/chatbot/user/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': userMessage}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final botResponse = data['response'] as String;
        final intent = data['intent'] as String?;

        _addBotMessage(botResponse);

        // Handle specific intents (e.g., navigate to bookings)
        if (intent == 'my_bookings' && data['bookings'] != null) {
          // Could navigate to bookings tab
          // Get.toNamed('/appointments');
        }
      } else {
        _addBotMessage('Sorry, I couldn\'t process that. Please try again.');
      }
    } catch (e) {
      print('Chatbot error: $e');
      _addBotMessage(
        'I\'m having trouble connecting right now. Please check your internet connection and try again.',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(_AiMessage(text: text, isUser: false));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _useSuggestion(String suggestion) {
    _controller.text = suggestion;
    _sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              'AI Assistant',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Clear chat button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearChat,
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          /// ─────────────── CHAT LIST ───────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (_, index) {
                if (index == _messages.length && _isLoading) {
                  return _TypingIndicator();
                }
                final msg = _messages[index];
                return _MessageBubble(message: msg);
              },
            ),
          ),

          /// ─────────────── SUGGESTIONS ───────────────
          if (_suggestions.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _suggestions.map((suggestion) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChipPill(
                        label: suggestion,
                        onTap: () => _useSuggestion(suggestion),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          /// ─────────────── INPUT BAR ───────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask me anything about salons or beauty...',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                      ),
                      style: AppTextStyles.body,
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: !_isLoading,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearChat() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Clear Chat History?'),
        content: const Text('This will delete all messages from this conversation.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        final token = await user.getIdToken();

        await http.delete(
          Uri.parse('${ApiConfig.baseUrl}/chatbot/user/clear/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        setState(() {
          _messages.clear();
          _messages.add(const _AiMessage(
            text: 'Chat cleared! How can I help you today?',
            isUser: false,
          ));
        });
      } catch (e) {
        Get.snackbar('Error', 'Failed to clear chat history');
      }
    }
  }
}

/* ───────────────── MESSAGE MODEL ─────────────────── */

class _AiMessage {
  final String text;
  final bool isUser;

  const _AiMessage({
    required this.text,
    required this.isUser,
  });
}

/* ───────────────── MESSAGE BUBBLE ─────────────────── */

class _MessageBubble extends StatelessWidget {
  final _AiMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final alignment =
        message.isUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        constraints: const BoxConstraints(maxWidth: 280),
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          color: message.isUser
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surface,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              if (!message.isUser) const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message.text,
                  style: AppTextStyles.body.copyWith(
                    color: message.isUser
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ───────────────── TYPING INDICATOR ─────────────────── */

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          color: AppColors.surface,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const SizedBox(
                width: 40,
                height: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _TypingDot(delay: 0),
                    _TypingDot(delay: 200),
                    _TypingDot(delay: 400),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}