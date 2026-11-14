import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/report.dart';
import '../providers/reports_provider.dart';
import '../providers/saved_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/report_card.dart';
import '../widgets/report_list_skeleton.dart';

/// Frame 08 - Saved Reports, opened from My Account (F8).
/// Saved ids are kept on the phone by SavedProvider (shared_preferences).
class SavedReportsScreen extends StatelessWidget {
  const SavedReportsScreen({super.key});

  void _remove(BuildContext context, SavedProvider saved, Report report) {
    saved.toggle(report.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Removed "${report.title}"'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => saved.toggle(report.id),
        ),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedProvider>();
    final reports = context.watch<ReportsProvider>();
    final items = saved.ids.map(reports.byId).whereType<Report>().toList();

    Widget body;
    if (reports.isLoading && reports.reports.isEmpty) {
      body = const ReportListSkeleton(count: 3);
    } else if (items.isEmpty) {
      body = const EmptyState(
        icon: Icons.bookmark_border,
        message: 'No saved reports yet',
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: items.length,
        itemBuilder: (context, i) => ReportCard(
          report: items[i],
          showType: true,
          onTap: () => context.push('/reports/${items[i].id}'),
          trailing: IconButton(
            tooltip: 'Remove from saved',
            icon: const Icon(Icons.bookmark),
            onPressed: () => _remove(context, saved, items[i]),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(items.isEmpty
            ? 'Saved reports'
            : 'Saved reports (${items.length})'),
      ),
      body: body,
    );
  }
}
