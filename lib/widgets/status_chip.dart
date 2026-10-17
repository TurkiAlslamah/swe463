import 'package:flutter/material.dart';

import '../models/report.dart';

/// Active / Recovered label (Feature F5).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});

  final ReportStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = status == ReportStatus.active;
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: active ? null : const Icon(Icons.check, size: 16),
      label: Text(active ? 'Active' : 'Recovered'),
      backgroundColor:
          active ? scheme.primaryContainer : scheme.surfaceContainerHighest,
      side: BorderSide.none,
    );
  }
}
