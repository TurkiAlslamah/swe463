import 'package:flutter/foundation.dart';

import '../models/match_notification.dart';
import '../services/report_service.dart';

/// Smart-match notifications and the unread count shown on the Home bell.
class NotificationsProvider extends ChangeNotifier {
  List<MatchNotification> items = [];

  int get unreadCount => items.where((n) => !n.isRead).length;

  Future<void> load() async {
    // Sample data. Phase 3: Supabase `notifications` table + Realtime.
    items = const [
      MatchNotification(
        id: 'n1',
        userId: ReportService.currentUserId,
        lostReportId: 'r8',
        foundReportId: 'r6',
        isRead: false,
      ),
      MatchNotification(
        id: 'n2',
        userId: ReportService.currentUserId,
        lostReportId: 'r7',
        foundReportId: 'r1',
        isRead: true,
      ),
    ];
    notifyListeners();
  }

  void markRead(String id) {
    items = [
      for (final n in items) n.id == id ? n.copyWith(isRead: true) : n,
    ];
    notifyListeners();
  }
}
