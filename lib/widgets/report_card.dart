import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/report.dart';
import '../services/report_service.dart';

/// One report row, used on Home, Search, Saved Reports and My Account.
class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.report,
    this.onTap,
    this.showType = false,
    this.trailing,
  });

  final Report report;
  final VoidCallback? onTap;
  final bool showType;
  final Widget? trailing;

  static String formatDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('MMM d').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final parts = <String>[
      if (showType) report.type == ReportType.found ? 'Found' : 'Lost',
      ReportService.buildingLabel(report.buildingId),
      formatDate(report.occurredAt),
    ];
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.image, color: scheme.onSurfaceVariant),
        ),
        title: Text(report.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(parts.join(' · ')),
        trailing: trailing,
      ),
    );
  }
}
