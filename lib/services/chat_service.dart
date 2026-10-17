import '../models/conversation.dart';
import '../models/message.dart';
import 'report_service.dart';

/// Conversations and messages. Phase 3 will move this to the Supabase
/// `conversations` and `messages` tables with Realtime; for now it uses
/// sample data so the screens can be navigated.
class ChatService {
  static const Map<String, String> userNames = {
    'u1': 'Omar Alqahtani',
    'u2': 'Ahmed',
    'u3': 'Saad',
    'u4': 'Khalid',
  };

  final List<Conversation> _conversations = [];
  final Map<String, List<Message>> _messages = {};

  ChatService() {
    final now = DateTime.now();
    const me = ReportService.currentUserId;
    _conversations.addAll([
      Conversation(id: 'c1', reportId: 'r1', userA: me, userB: 'u2',
          lastMessageAt: now.subtract(const Duration(minutes: 5))),
      Conversation(id: 'c2', reportId: 'r3', userA: me, userB: 'u3',
          lastMessageAt: now.subtract(const Duration(days: 1))),
      Conversation(id: 'c3', reportId: 'r5', userA: me, userB: 'u4',
          lastMessageAt: now.subtract(const Duration(days: 3))),
    ]);
    Message m(String id, String c, String s, String t, int minsAgo) => Message(
        id: id, conversationId: c, senderId: s, text: t,
        sentAt: now.subtract(Duration(minutes: minsAgo)));
    _messages['c1'] = [
      m('m1', 'c1', 'u2', 'Hi, I think the AirPods case is mine', 20),
      m('m2', 'c1', me, 'What color is the case?', 18),
      m('m3', 'c1', 'u2', 'Black, with a scratch on the lid', 15),
      m('m4', 'c1', me, 'Yes. I\'m in Building 22 now', 12),
      m('m5', 'c1', 'u2', 'Is it still in Building 22?', 5),
    ];
    _messages['c2'] = [m('m6', 'c2', 'u3', 'Thanks, I got the keys', 1440)];
    _messages['c3'] = [m('m7', 'c3', 'u4', 'Where can we meet?', 4320)];
  }

  Future<List<Conversation>> fetchConversations() async =>
      List<Conversation>.from(_conversations);

  Future<List<Message>> fetchMessages(String conversationId) async =>
      List<Message>.from(_messages[conversationId] ?? const []);

  Future<Message> sendMessage(String conversationId, String text) async {
    final msg = Message(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      conversationId: conversationId,
      senderId: ReportService.currentUserId,
      text: text,
      sentAt: DateTime.now(),
    );
    _messages.putIfAbsent(conversationId, () => []).add(msg);
    return msg;
  }
}
