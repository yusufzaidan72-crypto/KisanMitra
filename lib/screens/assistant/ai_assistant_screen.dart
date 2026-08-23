import 'package:flutter/material.dart';
import '../../models/irrigation_advice.dart' show ChatMessage;
import '../../services/demo/demo_ai_service.dart';
import '../../utils/utils.dart';
import '../../localization/app_localizations.dart';

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
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🤖', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(l.aiAssistant),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {
              _messages.clear();
              _addWelcomeMessage();
            }),
            tooltip: l.resetChat,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.length <= 1
                ? _buildSuggestionsView(suggestions, l)
                : _buildChatView(),
          ),
          _buildInputArea(l),
        ],
      ),
    );
  }

  Widget _buildSuggestionsView(
      List<Map<String, String>> suggestions, AppLocalizations l) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Welcome bubble
          _buildMessageBubble(_messages.first),
          const SizedBox(height: 20),
          // Demo badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.secondarySurface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.science_outlined,
                    size: 14, color: AppColors.secondary),
                const SizedBox(width: 6),
                Text(
                  l.demoModeLabel,
                  style: const TextStyle(
                      color: AppColors.secondaryDark, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(l.suggestedQuestions,
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          ...suggestions.map(
            (q) => GestureDetector(
              onTap: () => _sendMessage(q['text']!),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(q['emoji']!,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(q['text']!,
                            style: AppTextStyles.bodyMedium)),
                    const Icon(Icons.arrow_forward_ios,
                        size: 14, color: AppColors.textSecondary),
                  ],
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
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, i) => _buildMessageBubble(_messages[i]),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Center(
                  child: Text('🤖', style: TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: msg.isLoading
                  ? const SizedBox(
                      width: 40,
                      height: 20,
                      child: LinearProgressIndicator(
                          backgroundColor: Colors.transparent,
                          color: AppColors.primary),
                    )
                  : Text(
                      msg.text,
                      style: TextStyle(
                        color: isUser ? Colors.white : AppColors.textPrimary,
                        fontSize: 14,
                        height: 1.5,
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
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: const Center(
                  child: Text('👨‍🌾', style: TextStyle(fontSize: 18))),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textCtrl,
              maxLines: 3,
              minLines: 1,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: l.typeQuestion,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                filled: true,
                fillColor: AppColors.background,
              ),
              onSubmitted: _sendMessage,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.mic_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isLoading
                ? null
                : () => _sendMessage(_textCtrl.text),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: _isLoading ? null : AppColors.primaryGradient,
                color: _isLoading ? AppColors.border : null,
                shape: BoxShape.circle,
                boxShadow: _isLoading
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
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
