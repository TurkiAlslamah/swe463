import 'package:flutter/foundation.dart';

import '../models/match_notification.dart';
import '../services/report_service.dart';
import '../services/supabase_service.dart';

/// Smart-match notifications and the unread count shown on the Home bell.
class NotificationsProvider extends ChangeNotifier {
  List<MatchNotification> items = [];

  int get unreadCount => items.where((n) => !n.isRead).length;

  Future<void> load() async {
    if (SupabaseService.isConfigured) {
      // F6 (smart match) is Phase 4 work: the `notifications` table and its
      // database trigger do not exist yet, so the list starts empty.
      items = [];
      notifyListeners();
      return;
    }
    // Local demo mode: sample alerts that point at the sample reports.
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
