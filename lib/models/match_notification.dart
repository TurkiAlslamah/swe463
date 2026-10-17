class MatchNotification {
  final String id;
  final String userId;
  final String lostReportId;
  final String foundReportId;
  final bool isRead;

  const MatchNotification({
    required this.id,
    required this.userId,
    required this.lostReportId,
    required this.foundReportId,
    required this.isRead,
  });

  MatchNotification copyWith({bool? isRead}) {
    return MatchNotification(
      id: id,
      userId: userId,
      lostReportId: lostReportId,
      foundReportId: foundReportId,
      isRead: isRead ?? this.isRead,
    );
  }

  factory MatchNotification.fromMap(Map<String, dynamic> map) {
    return MatchNotification(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      lostReportId: map['lost_report_id'] as String,
      foundReportId: map['found_report_id'] as String,
      isRead: map['is_read'] as bool,
    );
  }
}
