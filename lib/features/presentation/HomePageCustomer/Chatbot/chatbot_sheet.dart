// lib/features/presentation/HomePageCustomer/Chatbot/chatbot_sheet.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/CustomerProviders/chatbot_provider.dart';
import '../../../providers/LoginProvider/auth_provider.dart'; // adjust path if needed

// ── Quick Questions Helper ────────────────────────────────────────────────────

List<String> getQuickQuestions(bool isLoggedIn) {
  if (isLoggedIn) {
    return [
      'How do I check my current bill?',
      'When is my bill due?',
      'What payment methods can I use?',
      'How do I report a billing issue?',
      'When is the next billing cycle?',
    ];
  }

  return [
    'How do I apply for a new water connection?',
    'What are your payment methods?',
    'Where is your office located?',
    'How do I create an account?',
    'How long does connection processing take?',
  ];
}
// ── Chatbot Sheet ─────────────────────────────────────────────────────────────

class ChatbotSheet extends StatefulWidget {
  const ChatbotSheet({Key? key}) : super(key: key);

  @override
  State<ChatbotSheet> createState() => _ChatbotSheetState();
}

class _ChatbotSheetState extends State<ChatbotSheet> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  Future<void> _handleSend(
    ChatbotProvider provider,
    bool isLoggedIn,
    String text,
  ) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _inputController.clear();
    await provider.sendMessage(trimmed, isAuthenticated: isLoggedIn);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final primary = Theme.of(context).primaryColor;

    // Read auth state from the existing AuthProvider (loggedIn, not isAuthenticated)
    final isLoggedIn = context.watch<AuthProvider>().loggedIn;

    return ChangeNotifierProvider(
      create: (_) => ChatbotProvider()..fetchHistory(),
      child: Consumer<ChatbotProvider>(
        builder: (context, provider, _) {
          if (provider.messages.isNotEmpty) _scrollToBottom();

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                _DragHandle(),
                _ChatHeader(primaryColor: primary),
                const Divider(height: 1, thickness: 0.5),
                Expanded(
                  child: Container(
                    color: Colors.grey[50],
                    child: _MessageList(
                      scrollController: _scrollController,
                      messages: provider.messages,
                      isTyping: provider.isTyping,
                      primaryColor: primary,
                    ),
                  ),
                ),
                const Divider(height: 1, thickness: 0.5),
                _QuickQuestions(
                  isLoggedIn: isLoggedIn,
                  primaryColor: primary,
                  onQuestionTap: (question) =>
                      _handleSend(provider, isLoggedIn, question),
                ),
                _InputBar(
                  controller: _inputController,
                  bottomInset: bottomInset,
                  primaryColor: primary,
                  onSend: () =>
                      _handleSend(provider, isLoggedIn, _inputController.text),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Drag Handle ───────────────────────────────────────────────────────────────

class _DragHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Container(
      width: 36,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(3),
      ),
    ),
  );
}

// ── Chat Header ───────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.primaryColor});
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: primaryColor,
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green[400],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Support Assistant',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                'Online · Typically replies instantly',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

// ── Message List ──────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  const _MessageList({
    required this.scrollController,
    required this.messages,
    required this.isTyping,
    required this.primaryColor,
  });

  final ScrollController scrollController;
  final List<ChatMessage> messages;
  final bool isTyping;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final itemCount = messages.length + (isTyping ? 1 : 0) + 1;

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == 0) return const _DateSeparator(label: 'Today');

        final msgIndex = index - 1;

        if (isTyping && msgIndex == messages.length) {
          return _TypingIndicator(primaryColor: primaryColor);
        }

        return _MessageBubble(
          message: messages[msgIndex],
          primaryColor: primaryColor,
        );
      },
    );
  }
}

// ── Date Separator ────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ),
      ),
    );
  }
}

// ── Message Bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.primaryColor});

  final ChatMessage message;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return Padding(
        padding: const EdgeInsets.only(left: 60, right: 16, bottom: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(4),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${message.time} · Delivered',
              style: TextStyle(fontSize: 10, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 60, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: primaryColor,
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(18),
                    ),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message.time,
                  style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Typing Indicator ──────────────────────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator({required this.primaryColor});
  final Color primaryColor;

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: widget.primaryColor,
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(18),
              ),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    final offset = ((_controller.value * 3) - i).clamp(
                      0.0,
                      1.0,
                    );
                    final opacity = (offset < 0.5 ? offset * 2 : 2 - offset * 2)
                        .clamp(0.3, 1.0);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Questions ───────────────────────────────────────────────────────────

class _QuickQuestions extends StatelessWidget {
  const _QuickQuestions({
    required this.isLoggedIn,
    required this.primaryColor,
    required this.onQuestionTap,
  });

  final bool isLoggedIn;
  final Color primaryColor;
  final void Function(String question) onQuestionTap;

  @override
  Widget build(BuildContext context) {
    final questions = getQuickQuestions(isLoggedIn);

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: questions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final question = questions[index];
          return GestureDetector(
            onTap: () => onQuestionTap(question),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: primaryColor.withOpacity(0.25),
                  width: 1,
                ),
              ),
              child: Text(
                question,
                style: TextStyle(
                  fontSize: 12,
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Input Bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.bottomInset,
    required this.primaryColor,
    required this.onSend,
  });

  final TextEditingController controller;
  final double bottomInset;
  final Color primaryColor;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottomInset),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                fillColor: Colors.grey[100],
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: primaryColor, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: primaryColor,
            borderRadius: BorderRadius.circular(50),
            child: InkWell(
              onTap: onSend,
              borderRadius: BorderRadius.circular(50),
              child: const Padding(
                padding: EdgeInsets.all(11),
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
