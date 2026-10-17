import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/reports_provider.dart';
import '../widgets/report_card.dart';
import '../widgets/status_chip.dart';

/// Frame 12 - My Account: own reports with status, saved reports, sign out.
/// Features F5 and F8.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final mine = context.watch<ReportsProvider>().mine;
    final scheme = Theme.of(context).colorScheme;
    final name = auth.user?.name ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              child: Text(name.isEmpty ? '?' : name[0]),
            ),
            title: Text(name),
            subtitle: Text(auth.user?.email ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_border),
            title: const Text('Saved reports'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/saved'),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text('My reports',
                style: Theme.of(context).textTheme.labelLarge),
          ),
          for (final r in mine)
            ReportCard(
              report: r,
              showType: true,
              trailing: StatusChip(status: r.status),
              onTap: () => context.push('/reports/${r.id}'),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: () => context.read<AuthProvider>().signOut(),
          ),
        ],
      ),
    );
  }
}
