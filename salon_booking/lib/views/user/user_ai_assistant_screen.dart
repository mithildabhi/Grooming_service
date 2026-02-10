// lib/screens/user/user_ai_assistant_screen.dart
// 🎨 AI Assistant with Modern Glassmorphic Design

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/user_chatbot_api.dart';
import '../../services/hairstyle_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/ui/glass_card.dart';

class UserAiAssistantScreen extends StatefulWidget {
  const UserAiAssistantScreen({super.key});

  @override
  State<UserAiAssistantScreen> createState() => _UserAiAssistantScreenState();
}

class _UserAiAssistantScreenState extends State<UserAiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ImagePicker _imagePicker = ImagePicker();

  bool _isLoading = false;
  bool _isAnalyzing = false;
  List<String> _suggestions = [];
  String? _currentGender;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
    _addBotMessage(_getWelcomeMessage());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String _getWelcomeMessage() {
    return """👋 Hi! I'm your SalonCare AI assistant.

I can help you with:
• 💇 **Hairstyle recommendations** (upload your photo!)
• 🔍 Finding salons near you
• 📅 Managing your bookings
• 💅 Beauty tips and advice

What would you like to do today?""";
  }

  Future<void> _loadSuggestions() async {
    try {
      final suggestions = await UserChatbotApi.getQuickSuggestions();
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
        });
      }
    } catch (e) {
      debugPrint('Error loading suggestions: $e');
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _addUserMessage(message);
    _messageController.clear();

    setState(() {
      _isLoading = true;
    });

    try {
      // ✅ FIXED: response is ChatbotResponse object, not Map
      final response = await UserChatbotApi.sendMessage(message);

      // ✅ FIXED: Access properties directly, not with []
      if (_shouldPromptForImage(response.response)) {
        _addBotMessage(response.response, showImageUploadOptions: true);
      } else {
        _addBotMessage(response.response);
      }

      // ✅ FIXED: No suggestions in ChatbotResponse, load separately
      await _loadSuggestions();
    } catch (e) {
      _addBotMessage('Sorry, I encountered an error. Please try again.');
      debugPrint('Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _shouldPromptForImage(String response) {
    final lowerResponse = response.toLowerCase();
    return lowerResponse.contains('upload') ||
        lowerResponse.contains('photo') ||
        lowerResponse.contains('camera') ||
        lowerResponse.contains('image') ||
        lowerResponse.contains('picture') ||
        lowerResponse.contains('hairstyle recommendation');
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _addBotMessage(String text, {bool showImageUploadOptions = false}) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: false,
          timestamp: DateTime.now(),
          showImageUploadOptions: showImageUploadOptions,
        ),
      );
    });
    _scrollToBottom();
  }

  void _addAnalysisResult(HairstyleAnalysisResult result) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: _formatAnalysisResult(result),
          isUser: false,
          timestamp: DateTime.now(),
          analysisResult: result,
        ),
      );
    });
    _scrollToBottom();
  }

  String _formatAnalysisResult(HairstyleAnalysisResult result) {
    if (!result.success) {
      return '❌ ${result.error ?? "Analysis failed. Please try again with a clearer photo."}';
    }

    final buffer = StringBuffer();
    buffer.writeln('✨ **Analysis Complete!**\n');

    buffer.writeln('🎭 **Your Face Shape:** ${result.faceShape}\n');

    if (result.currentHairstyle != null) {
      buffer.writeln(
        '💇 **Current Hair:** ${result.currentHairstyle!.description}\n',
      );
    }

    if (result.recommendations != null && result.recommendations!.isNotEmpty) {
      buffer.writeln('⭐ **Recommended Hairstyles:**\n');
      for (int i = 0; i < result.recommendations!.length; i++) {
        final rec = result.recommendations![i];
        buffer.writeln('**${i + 1}. ${rec.name}**');
        buffer.writeln('   ${rec.description}');
        buffer.writeln(
          '   • Difficulty: ${rec.difficulty} | Maintenance: ${rec.maintenance}\n',
        );
      }
    }

    if (result.stylingTips != null && result.stylingTips!.isNotEmpty) {
      buffer.writeln('\n💡 **Styling Tips:**');
      for (final tip in result.stylingTips!) {
        buffer.writeln('• $tip');
      }
    }

    if (result.recommendedProducts != null &&
        result.recommendedProducts!.isNotEmpty) {
      buffer.writeln('\n🛍️ **Recommended Products:**');
      for (final product in result.recommendedProducts!) {
        buffer.writeln('• $product');
      }
    }

    return buffer.toString();
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

  Future<void> _showGenderSelectionDialog() async {
    if (!mounted) return;

    final gender = await showDialog<String>(
      context: context,
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: AppColors.primary,
                    size: 48,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Select Gender',
                  style: AppTextStyles.heading.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'This helps us provide better recommendations:',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                _GenderOption(
                  icon: Icons.male,
                  label: 'Male',
                  color: Colors.blue,
                  onTap: () => Navigator.pop(context, 'male'),
                ),
                const SizedBox(height: AppSpacing.sm),
                _GenderOption(
                  icon: Icons.female,
                  label: 'Female',
                  color: Colors.pink,
                  onTap: () => Navigator.pop(context, 'female'),
                ),
                const SizedBox(height: AppSpacing.sm),
                _GenderOption(
                  icon: Icons.people,
                  label: 'Prefer not to say',
                  color: Colors.purple,
                  onTap: () => Navigator.pop(context, 'unisex'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (gender != null && mounted) {
      setState(() {
        _currentGender = gender;
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      if (_currentGender == null) {
        await _showGenderSelectionDialog();
        if (_currentGender == null) return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _analyzeHairstyle(File(image.path));
      }
    } catch (e) {
      _showErrorSnackbar('Failed to pick image: $e');
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      if (_currentGender == null) {
        await _showGenderSelectionDialog();
        if (_currentGender == null) return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        await _analyzeHairstyle(File(image.path));
      }
    } catch (e) {
      _showErrorSnackbar('Failed to capture image: $e');
    }
  }

  Future<void> _analyzeHairstyle(File imageFile) async {
    setState(() {
      _messages.add(
        ChatMessage(
          text: '📷 Uploaded photo for hairstyle analysis',
          isUser: true,
          timestamp: DateTime.now(),
          imageFile: imageFile,
        ),
      );
      _isAnalyzing = true;
    });

    _addBotMessage('🔍 Analyzing your photo...\nThis will take a few seconds.');
    _scrollToBottom();

    try {
      final result = await HairstyleService.analyzeHairstyle(
        imageFile: imageFile,
        gender: _currentGender ?? 'unisex',
      );

      setState(() {
        if (_messages.isNotEmpty && _messages.last.text.contains('Analyzing')) {
          _messages.removeLast();
        }
      });

      _addAnalysisResult(result);
    } catch (e) {
      setState(() {
        if (_messages.isNotEmpty && _messages.last.text.contains('Analyzing')) {
          _messages.removeLast();
        }
      });

      _addBotMessage(
        '❌ Failed to analyze your photo.\n\n'
        'Please try again with:\n'
        '• Good lighting\n'
        '• Clear front-facing photo\n'
        '• No sunglasses or hats\n\n'
        'Error: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                Text(
                  'Upload Photo for Hairstyle Analysis',
                  style: AppTextStyles.heading.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Get AI-powered hairstyle recommendations',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Gallery Option
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                  child: GlassCard(
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF536DFE), Color(0xFF7C4DFF)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Choose from Gallery',
                                style: AppTextStyles.subHeading.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pick an existing photo',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Camera Option
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                  child: GlassCard(
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00C853), Color(0xFF00E676)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Take Photo',
                                style: AppTextStyles.subHeading.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Use your camera',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Tips
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Use good lighting, face camera directly, no sunglasses/hats',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.primary),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: AppTextStyles.subHeading.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Your style companion',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.primary),
            tooltip: 'View History',
            onPressed: () async {
              try {
                final history = await HairstyleService.getAnalysisHistory(
                  limit: 10,
                );
                if (mounted) {
                  _showHistoryDialog(history);
                }
              } catch (e) {
                _showErrorSnackbar('Failed to load history');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textMuted),
            tooltip: 'Clear Chat',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    'Clear Chat?',
                    style: AppTextStyles.heading.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Text(
                    'This will clear your chat history.',
                    style: AppTextStyles.body,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Clear',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                try {
                  await UserChatbotApi.clearChatHistory();
                  setState(() {
                    _messages.clear();
                    _addBotMessage(_getWelcomeMessage());
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Chat history cleared'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  _showErrorSnackbar('Failed to clear chat history');
                }
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          if (_suggestions.isNotEmpty && !_isLoading)
            Container(
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => _sendMessage(_suggestions[index]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _suggestions[index],
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          if (_isLoading || _isAnalyzing)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    _isAnalyzing ? 'Analyzing your photo...' : 'Thinking...',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

          // Modern Input Container
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  // Camera Button
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.2),
                            AppColors.primary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.add_a_photo,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Text Input
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: AppTextStyles.body,
                        decoration: InputDecoration(
                          hintText: 'Ask me anything...',
                          hintStyle: AppTextStyles.body.copyWith(
                            color: AppColors.textMuted,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        textInputAction: TextInputAction.send,
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Send Button
                  GestureDetector(
                    onTap: () => _sendMessage(_messageController.text),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, Color(0xFF7B27FF)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF7B27FF)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 22),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: message.isUser
                        ? const LinearGradient(
                            colors: [AppColors.primary, Color(0xFF7B27FF)],
                          )
                        : null,
                    color: message.isUser ? null : AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: message.isUser
                            ? AppColors.primary.withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.imageFile != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            message.imageFile!,
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                      ],

                      Text(
                        message.text,
                        style: AppTextStyles.body.copyWith(
                          color: message.isUser
                              ? Colors.white
                              : AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),

                      if (message.showImageUploadOptions) ...[
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: 8,
                          children: [
                            _buildQuickActionButton(
                              Icons.photo_library,
                              'Gallery',
                              const LinearGradient(
                                colors: [Color(0xFF536DFE), Color(0xFF7C4DFF)],
                              ),
                              _pickImageFromGallery,
                            ),
                            _buildQuickActionButton(
                              Icons.camera_alt,
                              'Camera',
                              const LinearGradient(
                                colors: [Color(0xFF00C853), Color(0xFF00E676)],
                              ),
                              _pickImageFromCamera,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 22,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    IconData icon,
    String label,
    LinearGradient gradient,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistoryDialog(List<HairstyleHistoryItem> history) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: GlassCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history,
                    color: AppColors.primary,
                    size: 48,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Analysis History',
                  style: AppTextStyles.heading.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.maxFinite,
                  height: 300,
                  child: history.isEmpty
                      ? Center(
                          child: Text(
                            'No analysis history',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textMuted,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final item = history[index];
                            return Container(
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: GlassCard(
                                onTap: () async {
                                  try {
                                    final detail =
                                        await HairstyleService.getAnalysisDetail(
                                          item.id,
                                        );
                                    if (mounted) {
                                      Navigator.pop(context);
                                      _addAnalysisResult(detail);
                                    }
                                  } catch (e) {
                                    _showErrorSnackbar(
                                      'Failed to load details',
                                    );
                                  }
                                },
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                child: Row(
                                  children: [
                                    if (item.imageUrl != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          item.imageUrl!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    else
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.face,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.faceShape ?? 'Unknown',
                                            style: AppTextStyles.body.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${item.recommendationsCount} recommendations',
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                  color: AppColors.textMuted,
                                                ),
                                          ),
                                          Text(
                                            _formatDate(
                                              DateTime.parse(item.createdAt),
                                            ),
                                            style: AppTextStyles.caption
                                                .copyWith(
                                                  color: AppColors.textMuted,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: AppColors.textMuted,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final File? imageFile;
  final bool showImageUploadOptions;
  final HairstyleAnalysisResult? analysisResult;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageFile,
    this.showImageUploadOptions = false,
    this.analysisResult,
  });
}

/* ───────────────── GENDER OPTION WIDGET ───────────────── */

class _GenderOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _GenderOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
