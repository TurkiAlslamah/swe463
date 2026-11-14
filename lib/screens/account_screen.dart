import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/reports_provider.dart';
import '../providers/saved_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/report_card.dart';
import '../widgets/status_chip.dart';

/// Frame 12 - My Account: own reports with status, saved reports, sign out.
/// Features F5 and F8.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text(
            'You will need your KFUPM email and password to sign in again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    // The router goes back to Sign In by itself after sign-out.
    if (ok == true) auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final reports = context.watch<ReportsProvider>();
    final savedCount = context.watch<SavedProvider>().ids.length;
    final mine = reports.mine;
    final scheme = Theme.of(context).colorScheme;
    final name = auth.user?.name ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: RefreshIndicator(
        onRefresh: reports.loadReports,
        child: ListView(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Text(name.isEmpty ? '?' : name[0].toUpperCase()),
              ),
              title: Text(name, style: Theme.of(context).textTheme.titleMedium),
              subtitle: Text(auth.user?.email ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Saved reports'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (savedCount > 0)
                    Badge(
                      label: Text('$savedCount'),
                      backgroundColor: scheme.primary,
                      textColor: scheme.onPrimary,
                    ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () => context.push('/saved'),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                mine.isEmpty ? 'My reports' : 'My reports (${mine.length})',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            if (reports.isLoading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              )
            else if (reports.error != null)
              EmptyState(
                icon: Icons.cloud_off,
                message: reports.error!,
                actionLabel: 'Retry',
                onAction: reports.loadReports,
              )
            else if (mine.isEmpty)
              EmptyState(
                icon: Icons.post_add,
                message: 'You have not posted any reports yet',
                actionLabel: 'Post report',
                onAction: () => context.go('/report'),
              )
            else
              for (final r in mine)
                ReportCard(
                  report: r,
                  showType: true,
                  trailing: StatusChip(status: r.status),
                  onTap: () => context.push('/reports/${r.id}'),
                ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: scheme.error),
              title: Text('Sign out', style: TextStyle(color: scheme.error)),
              onTap: () => _confirmSignOut(context),
            ),
          ],
        ),
      ),
    );
  }
}
