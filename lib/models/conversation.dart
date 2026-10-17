class Conversation {
  final String id;
  final String reportId;
  final String userA;
  final String userB;
  final DateTime lastMessageAt;

  const Conversation({
    required this.id,
    required this.reportId,
    required this.userA,
    required this.userB,
    required this.lastMessageAt,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as String,
      reportId: map['report_id'] as String,
      userA: map['user_a'] as String,
      userB: map['user_b'] as String,
      lastMessageAt: DateTime.parse(map['last_message_at'] as String),
    );
  }
}


// Reviewed by Faisal