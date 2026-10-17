import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/report.dart';
import '../providers/reports_provider.dart';
import '../providers/saved_provider.dart';
import '../services/report_service.dart';
import '../widgets/status_chip.dart';

/// Frame 07 - one report: message the finder, save it,
/// or (owner) mark it as recovered. Features F4, F5, F7, F8.
class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({super.key, required this.reportId});

  final String reportId;

  @override
  Widget build(BuildContext context) {
    final report = context.watch<ReportsProvider>().byId(reportId);
    final saved = context.watch<SavedProvider>();
    final scheme = Theme.of(context).colorScheme;

    if (report == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Report not found')),
      );
    }

    final isOwner = report.ownerId == ReportService.currentUserId;
    final isSaved = saved.isSaved(report.id);

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!isOwner)
            IconButton(
              tooltip: isSaved ? 'Remove from saved' : 'Save',
              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
              onPressed: () {
                saved.toggle(report.id);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text(isSaved ? 'Removed' : 'Saved'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () => saved.toggle(report.id),
                    ),
                  ));
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.image, size: 48, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              Chip(
                visualDensity: VisualDensity.compact,
                label:
                    Text(report.type == ReportType.found ? 'Found' : 'Lost'),
              ),
              StatusChip(status: report.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(report.title, style: Theme.of(context).textTheme.headlineSmall),
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.location_on),
            title: Text(ReportService.buildingLabel(report.buildingId)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.calendar_today),
            title: Text(DateFormat('EEE, MMM d').format(report.occurredAt)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.category),
            title: Text(report.category),
          ),
          Text(report.description),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/campus_map.png', fit: BoxFit.cover),
                  Center(
                    child: Icon(Icons.location_on,
                        size: 40, color: scheme.error),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isOwner
              ? FilledButton(
                  onPressed: report.status == ReportStatus.recovered
                      ? null
                      : () => context
                          .read<ReportsProvider>()
                          .markRecovered(report.id),
                  child: Text(report.status == ReportStatus.recovered
                      ? 'Recovered'
                      : 'Mark as recovered'),
                )
              : FilledButton(
                  // Placeholder: opens the sample conversation.
                  onPressed: () => context.push('/chats/c1'),
                  child: Text(report.type == ReportType.found
                      ? 'Message finder'
                      : 'Message owner'),
                ),
        ),
      ),
    );
  }
}
