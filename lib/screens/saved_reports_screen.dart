import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/report.dart';
import '../providers/reports_provider.dart';
import '../providers/saved_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/report_card.dart';

/// Frame 08 - Saved Reports, opened from My Account (F8).
class SavedReportsScreen extends StatelessWidget {
  const SavedReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedProvider>();
    final reports = context.watch<ReportsProvider>();
    final items = saved.ids
        .map(reports.byId)
        .whereType<Report>()
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Saved reports')),
      body: items.isEmpty
          ? const EmptyState(
              icon: Icons.bookmark_border, message: 'No saved reports yet')
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              itemBuilder: (context, i) => ReportCard(
                report: items[i],
                showType: true,
                onTap: () => context.push('/reports/${items[i].id}'),
                trailing: IconButton(
                  tooltip: 'Remove',
                  icon: const Icon(Icons.bookmark),
                  onPressed: () => saved.toggle(items[i].id),
                ),
              ),
            ),
    );
  }
}
