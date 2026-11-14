import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/report.dart';
import '../providers/notifications_provider.dart';
import '../providers/reports_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/report_card.dart';
import '../widgets/report_list_skeleton.dart';

/// Frame 03 - Home: recent Found and Lost reports in two tabs (F3).
/// Shows the loading, empty, error and default states from the design.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<NotificationsProvider>().unreadCount;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laqait'),
          actions: [
            IconButton(
              tooltip: 'Notifications',
              onPressed: () => context.push('/notifications'),
              icon: Badge(
                isLabelVisible: unread > 0,
                label: Text('$unread'),
                child: const Icon(Icons.notifications_outlined),
              ),
            ),
          ],
          bottom: const TabBar(tabs: [Tab(text: 'Found'), Tab(text: 'Lost')]),
        ),
        body: const TabBarView(
          children: [
            _ReportList(type: ReportType.found),
            _ReportList(type: ReportType.lost),
          ],
        ),
      ),
    );
  }
}

class _ReportList extends StatelessWidget {
  const _ReportList({required this.type});

  final ReportType type;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportsProvider>();

    // Loading (Frame 03 / Loading)
    if (provider.isLoading && provider.reports.isEmpty) {
      return const ReportListSkeleton();
    }

    // Error (Frame 03 / No connection)
    if (provider.error != null) {
      return EmptyState(
        icon: Icons.cloud_off,
        message: provider.error!,
        actionLabel: 'Retry',
        onAction: provider.loadReports,
      );
    }

    // Empty (Frame 03 / Empty)
    final items = type == ReportType.found ? provider.found : provider.lost;
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.inbox,
        message: type == ReportType.found
            ? 'No found reports yet'
            : 'No lost reports yet',
        actionLabel: 'Post report',
        onAction: () => context.go('/report'),
      );
    }

    // Default: pull down to refresh.
    return RefreshIndicator(
      onRefresh: provider.loadReports,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        itemBuilder: (context, i) => ReportCard(
          report: items[i],
          onTap: () => context.push('/reports/${items[i].id}'),
        ),
      ),
    );
  }
}
