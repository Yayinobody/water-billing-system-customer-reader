// lib/features/providers/Customer/chatbot_provider.dart

import 'package:flutter/foundation.dart';
import '../../api/api.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;

  ChatMessage({required this.text, required this.isUser, String? time})
    : time = time ?? _formatNow();

  static String _formatNow() {
    final now = DateTime.now();
    final h = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final m = now.minute.toString().padLeft(2, '0');
    final period = now.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      time: json['time'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'time': time,
  };
}

class ChatbotProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _hasGreeted = false;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;

  static const List<String> _sensitiveKeywords = [
    'bill',
    'account',
    'balance',
    'usage',
  ];

  // Maps display text → intent_id for the backend
  static const Map<String, String> _intentMap = {
    'How much is my current bill?': 'bill',
    'How can I pay my bill?': 'payment',
    'When will be the next billing cycle?': 'bill',
    'How do I report a billing issue?': 'concern',
    'How do I apply for a water connection?': 'payment',
    'What payment methods are available?': 'payment',
    'Where is your office located?': 'concern',
    'How do I create an account?': 'concern',
  };

  Future<void> sendMessage(String text, {bool isAuthenticated = true}) async {
    if (text.trim().isEmpty) return;

    _addMessage(ChatMessage(text: text, isUser: true));

    if (!isAuthenticated && _containsSensitiveKeyword(text)) {
      await Future.delayed(const Duration(milliseconds: 400));
      _addMessage(
        ChatMessage(
          text:
              'Please log in to check your billing details. Would you like to log in now?',
          isUser: false,
        ),
      );
      return;
    }

    _setTyping(true);

    try {
      // Resolve intent_id if this message matches a known quick question
      final intentId = _intentMap[text];

      final response = await ApiService.post('/chat', {
        'message': text,
        if (intentId != null) 'intent_id': intentId,
      });

      final reply = response.data['reply'] as String? ?? 'No response';
      _addMessage(ChatMessage(text: reply, isUser: false));
    } catch (e) {
      _addMessage(ChatMessage(text: 'Error: $e', isUser: false));
    } finally {
      _setTyping(false);
    }
  }

  bool _containsSensitiveKeyword(String text) {
    final lower = text.toLowerCase();
    return _sensitiveKeywords.any((kw) => lower.contains(kw));
  }

  Future<void> fetchHistory() async {
    try {
      final data = await ApiService.get('/chat') as List<dynamic>;
      final history = data
          .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
          .toList();

      _messages
        ..clear()
        ..addAll(history);

      _addGreeting();
    } catch (_) {
      _addGreeting();
    }
  }

  void clearMessages() {
    _messages.clear();
    _hasGreeted = false;
    notifyListeners();
  }

  // ── Private helpers ─────────────────────────────────────────────────────────

  void _addMessage(ChatMessage message) {
    _messages.add(message);
    notifyListeners();
  }

  void _setTyping(bool value) {
    _isTyping = value;
    notifyListeners();
  }

  void _addGreeting() {
    if (_hasGreeted) return;
    _messages.insert(
      0,
      ChatMessage(text: 'Hello! How can I help you today?', isUser: false),
    );
    _hasGreeted = true;
    notifyListeners();
  }
}
