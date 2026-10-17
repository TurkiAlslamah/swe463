import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/notifications_provider.dart';
import '../providers/reports_provider.dart';
import '../services/report_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/report_card.dart';

/// Frame 11 - smart-match alerts for the user's lost reports (F6).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<NotificationsProvider>();
    final reports = context.watch<ReportsProvider>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notes.items.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_none,
              message: 'No notifications yet')
          : ListView.builder(
              itemCount: notes.items.length,
              itemBuilder: (context, i) {
                final n = notes.items[i];
                final lost = reports.byId(n.lostReportId);
                final found = reports.byId(n.foundReportId);
                final subtitle = found == null
                    ? ''
                    : 'Found · ${ReportService.buildingLabel(found.buildingId)}'
                        ' · ${ReportCard.formatDate(found.occurredAt)}';
                return ListTile(
                  leading: const Icon(Icons.image),
                  title: Text('Match for your ${lost?.title ?? 'item'}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(subtitle),
                  trailing: n.isRead
                      ? null
                      : Icon(Icons.circle, size: 10, color: scheme.primary),
                  onTap: () {
                    notes.markRead(n.id);
                    context.push('/reports/${n.foundReportId}');
                  },
                );
              },
            ),
    );
  }
}
