import 'package:flutter/material.dart';

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
    _AiMessage(
      text: 'Hi 👋 I\'m your AI stylist assistant. How can I help you today?',
      isUser: false,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    setState(() {
      _messages.add(
        _AiMessage(
          text: _controller.text.trim(),
          isUser: true,
        ),
      );
    });

    _controller.clear();

    // Auto scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Simulate AI response
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add(
          const _AiMessage(
            text:
                '🤖 I\'m analyzing your request and will suggest the best options!',
            isUser: false,
          ),
        );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
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
            const Text('AI Assistant'),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Column(
        children: [
          /// ───────────── CHAT LIST ─────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _messages.length,
              itemBuilder: (_, index) {
                final msg = _messages[index];
                return _MessageBubble(message: msg);
              },
            ),
          ),

          /// ───────────── SUGGESTIONS ─────────────
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChipPill(
                    label: 'Best time to book',
                    selected: false,
                    onTap: () {
                      _controller.text = 'What is the best time to book?';
                      _sendMessage();
                    },
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ChipPill(
                    label: 'Nearby salons',
                    selected: false,
                    onTap: () {
                      _controller.text = 'Show me nearby salons';
                      _sendMessage();
                    },
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  ChipPill(
                    label: 'Haircare tips',
                    selected: false,
                    onTap: () {
                      _controller.text = 'Give me haircare tips';
                      _sendMessage();
                    },
                  ),
                ],
              ),
            ),
          ),

          /// ───────────── INPUT BAR ─────────────
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
                        hintText: 'Ask me anything about salons or bookings…',
                        hintStyle: AppTextStyles.body.copyWith(
                          color: AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                      ),
                      style: AppTextStyles.body,
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
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
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ───────────────── MESSAGE MODEL ───────────────── */

class _AiMessage {
  final String text;
  final bool isUser;

  const _AiMessage({
    required this.text,
    required this.isUser,
  });
}

/* ───────────────── MESSAGE BUBBLE ───────────────── */

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
