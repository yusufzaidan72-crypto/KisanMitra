import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../localization/app_localizations.dart';
import '../../models/irrigation_advice.dart' show ChatMessage;
import '../../services/demo/demo_ai_service.dart';
import '../../utils/lovable_colors.dart';
import '../../widgets/lovable_glass.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final List<ChatMessage> _messages = [];
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isLoading = false;
  final _service = DemoAIService();

  List<Map<String, String>> _getSuggestions(AppLocalizations l) {
    return [
      {'emoji': '🌾', 'text': l.suggestGrow},
      {'emoji': '🌿', 'text': l.suggestLeaves},
      {'emoji': '💧', 'text': l.suggestIrrigate},
      {'emoji': '🌧', 'text': l.suggestRain},
      {'emoji': '🛡️', 'text': l.suggestProtect},
      {'emoji': '📊', 'text': l.suggestPrice},
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _messages.isEmpty) {
        _addWelcomeMessage();
      }
    });
  }

  void _addWelcomeMessage() {
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    setState(() {
      _messages.add(ChatMessage(
        id: 'welcome',
        text: l.assistantWelcome,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final suggestions = _getSuggestions(l);

    return Scaffold(
      backgroundColor: const Color(0xFFF0FDF4),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background photo
          CachedNetworkImage(
            imageUrl: LovableColors.bgImageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: const Color(0xFFD1FAE5)),
            errorWidget: (_, __, ___) => Container(color: const Color(0xFFD1FAE5)),
          ),

          // Gradient overlay
          Container(
            decoration: const BoxDecoration(gradient: LovableColors.bgOverlay),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(l),
                Expanded(
                  child: _messages.length <= 1
                      ? _buildSuggestionsView(suggestions, l)
                      : _buildChatView(),
                ),
                _buildInputArea(l),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: LovableColors.glassStrong,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: LovableColors.glassBorder),
              boxShadow: LovableColors.shadowGlass,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: LovableColors.forest),
                  onPressed: () => Navigator.pop(context),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    gradient: LovableColors.ctaGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.bot, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  l.aiAssistant,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: LovableColors.forest,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.rotateCcw, color: LovableColors.forest, size: 18),
                  onPressed: () => setState(() {
                    _messages.clear();
                    _addWelcomeMessage();
                  }),
                  tooltip: l.resetChat,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionsView(
      List<Map<String, String>> suggestions, AppLocalizations l) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          _buildMessageBubble(_messages.first),
          const SizedBox(height: 16),
          GlassChip(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.sparkles, size: 14, color: LovableColors.emeraldAccent),
                const SizedBox(width: 6),
                Text(
                  l.demoModeLabel,
                  style: GoogleFonts.plusJakartaSans(
                    color: LovableColors.slateGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.suggestedQuestions,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: LovableColors.forest,
            ),
          ),
          const SizedBox(height: 12),
          ...suggestions.map(
            (q) => GestureDetector(
              onTap: () => _sendMessage(q['text']!),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: LovableGlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Text(q['emoji']!, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          q['text']!,
                          style: GoogleFonts.plusJakartaSans(
                            color: LovableColors.forest,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(LucideIcons.arrowRight, size: 16, color: LovableColors.slateGreen),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatView() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      itemCount: _messages.length,
      itemBuilder: (context, i) => _buildMessageBubble(_messages[i]),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: LovableColors.ctaGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.bot, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? LovableColors.emeraldAccent : LovableColors.glassStrong,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: isUser ? const Radius.circular(20) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
                    ),
                    border: Border.all(
                      color: isUser ? Colors.transparent : LovableColors.glassBorder,
                    ),
                  ),
                  child: msg.isLoading
                      ? const SizedBox(
                          width: 40,
                          height: 20,
                          child: LinearProgressIndicator(color: Colors.white),
                        )
                      : Text(
                          msg.text,
                          style: GoogleFonts.plusJakartaSans(
                            color: isUser ? Colors.white : LovableColors.forest,
                            fontSize: 14,
                            height: 1.5,
                            fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: LovableColors.glassStrong,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.user, color: LovableColors.forest, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: LovableColors.glassStrong,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: LovableColors.glassBorder),
              boxShadow: LovableColors.shadowGlass,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    maxLines: 3,
                    minLines: 1,
                    style: GoogleFonts.plusJakartaSans(color: LovableColors.forest, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: l.typeQuestion,
                      hintStyle: GoogleFonts.plusJakartaSans(color: LovableColors.slateGreen, fontSize: 14),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                GestureDetector(
                  onTap: _isLoading ? null : () => _sendMessage(_textCtrl.text),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LovableColors.ctaGradient,
                      shape: BoxShape.circle,
                      boxShadow: LovableColors.shadowGlow,
                    ),
                    child: const Icon(LucideIcons.send, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _textCtrl.clear();

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: trimmed,
      isUser: true,
      timestamp: DateTime.now(),
    );
    final loadingMsg = ChatMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_loading',
      text: '...',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );

    setState(() {
      _messages.add(userMsg);
      _messages.add(loadingMsg);
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final l = AppLocalizations.of(context);
      final response = await _service.askQuestion(
        trimmed,
        language: l.locale.languageCode,
      );
      setState(() {
        _messages.remove(loadingMsg);
        _messages.add(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } catch (e) {
      if (!mounted) return;
      final l = AppLocalizations.of(context);
      setState(() {
        _messages.remove(loadingMsg);
        _messages.add(ChatMessage(
          id: 'err',
          text: l.assistantError,
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    }
    setState(() => _isLoading = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
