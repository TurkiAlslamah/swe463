import 'package:flutter/foundation.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import '../services/chat_service.dart';

/// Conversations and messages.
class ChatProvider extends ChangeNotifier {
  ChatProvider({ChatService? service}) : _service = service ?? ChatService();

  final ChatService _service;

  List<Conversation> conversations = [];
  final Map<String, List<Message>> _messages = {};

  List<Message> messagesFor(String conversationId) =>
      _messages[conversationId] ?? const [];

  Message? lastMessage(String conversationId) {
    final list = _messages[conversationId];
    return (list == null || list.isEmpty) ? null : list.last;
  }

  String nameOf(String userId) => ChatService.userNames[userId] ?? 'User';

  Conversation? byId(String id) {
    for (final c in conversations) {
      if (c.id == id) return c;
    }
    return null;
  }

  Future<void> loadConversations() async {
    conversations = await _service.fetchConversations();
    for (final c in conversations) {
      _messages[c.id] = await _service.fetchMessages(c.id);
    }
    notifyListeners();
  }

  Future<void> send(String conversationId, String text) async {
    if (text.trim().isEmpty) return;
    final msg = await _service.sendMessage(conversationId, text.trim());
    _messages.putIfAbsent(conversationId, () => []).add(msg);
    notifyListeners();
  }
}
