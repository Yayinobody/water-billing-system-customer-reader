// lib/features/presentation/HomePageCustomer/Chatbot/chatbot_fab.dart

import 'package:flutter/material.dart';
import 'chatbot_sheet.dart';

void showChatbotSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const ChatbotSheet(),
  );
}