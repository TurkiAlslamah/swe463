import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/building.dart';
import '../models/report.dart';
import '../providers/auth_provider.dart';
import '../providers/reports_provider.dart';
import '../providers/saved_provider.dart';
import '../services/building_service.dart';
import '../services/report_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/report_photo.dart';
import '../widgets/status_chip.dart';

/// Frame 07 - one report: message the finder, save it,
/// or (owner) mark it as recovered. Features F4, F5, F7, F8.
class ReportDetailsScreen extends StatefulWidget {
  const ReportDetailsScreen({super.key, required this.reportId});

  final String reportId;

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  final Future<List<Building>> _buildings = BuildingService.loadAll();
  bool _updating = false;

  void _toggleSaved(Report report) {
    final saved = context.read<SavedProvider>();
    final wasSaved = saved.isSaved(report.id);
    saved.toggle(report.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(wasSaved ? 'Removed from saved' : 'Saved'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => saved.toggle(report.id),
        ),
      ));
  }

  Future<void> _markRecovered(Report report) async {
    final reports = context.read<ReportsProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Mark as recovered?'),
        content: const Text(
            'Everyone will see that this item went back to its owner.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Mark recovered'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _updating = true);
    try {
      await reports.markRecovered(report.id);
      messenger
          .showSnackBar(const SnackBar(content: Text('Marked as recovered')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(
          content: Text('Could not update the report. ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _updating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reports = context.watch<ReportsProvider>();
    final report = reports.byId(widget.reportId);
    final isSaved = context.watch<SavedProvider>().isSaved(widget.reportId);
    final userId = context.watch<AuthProvider>().user?.id;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (report == null) {
      return Scaffold(
        appBar: AppBar(),
        body: reports.isLoading
            ? const Center(child: CircularProgressIndicator())
            : EmptyState(
                icon: Icons.search_off,
                message: 'Report not found',
                actionLabel: 'Go back',
                onAction: () => context.pop(),
              ),
      );
    }

    final isOwner = userId != null && report.ownerId == userId;
    final recovered = report.status == ReportStatus.recovered;

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (!isOwner)
            IconButton(
              tooltip: isSaved ? 'Remove from saved' : 'Save',
              icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
              onPressed: () => _toggleSaved(report),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ReportPhoto(
            url: report.photoUrl,
            width: double.infinity,
            height: 200,
            iconSize: 48,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              Chip(
                visualDensity: VisualDensity.compact,
                label: Text(report.type == ReportType.found ? 'Found' : 'Lost'),
              ),
              StatusChip(status: report.status),
              if (isOwner)
                const Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: Icon(Icons.person, size: 16),
                  label: Text('Your report'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(report.title, style: textTheme.headlineSmall),
          _InfoRow(
            icon: Icons.location_on,
            text: ReportService.buildingLabel(report.buildingId),
          ),
          _InfoRow(
            icon: Icons.calendar_today,
            text: DateFormat('EEE, MMM d · h:mm a').format(report.occurredAt),
          ),
          _InfoRow(icon: Icons.category, text: report.category),
          const SizedBox(height: 4),
          Text(
            report.description.isEmpty ? 'No description' : report.description,
            style: report.description.isEmpty
                ? textTheme.bodyMedium?.copyWith(color: scheme.outline)
                : textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<Building>>(
            future: _buildings,
            builder: (context, snapshot) => _MapPreview(
              building: snapshot.hasData
                  ? BuildingService.find(snapshot.data!, report.buildingId)
                  : null,
              label: ReportService.buildingLabel(report.buildingId),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isOwner
              ? FilledButton.icon(
                  onPressed: (recovered || _updating)
                      ? null
                      : () => _markRecovered(report),
                  icon: _updating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(recovered ? Icons.check : Icons.task_alt),
                  label: Text(recovered ? 'Recovered' : 'Mark as recovered'),
                )
              : FilledButton(
                  // F4 (chat) is Phase 4 work: this opens the sample chat.
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: Icon(icon),
      title: Text(text),
    );
  }
}

/// Small campus map with a pin on the report's building (F7).
class _MapPreview extends StatelessWidget {
  const _MapPreview({required this.building, required this.label});

  final Building? building;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final b = building;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 160,
        child: LayoutBuilder(
          builder: (context, box) => Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/campus_map.png', fit: BoxFit.fill),
              ),
              Positioned(
                left: (b?.mapX ?? 0.5) * box.maxWidth - 20,
                top: (b?.mapY ?? 0.5) * box.maxHeight - 40,
                child: Icon(Icons.location_on, size: 40, color: scheme.error),
              ),
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(label,
                      style: Theme.of(context).textTheme.labelMedium),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
