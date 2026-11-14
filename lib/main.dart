import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'app_router.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/notifications_provider.dart';
import 'providers/reports_provider.dart';
import 'providers/saved_provider.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Connects to Supabase only when keys are given with
  // --dart-define-from-file=env.json. Without them the app runs in
  // local demo mode on sample data.
  await SupabaseService.init();
  runApp(const LaqaitApp());
}

class LaqaitApp extends StatefulWidget {
  const LaqaitApp({super.key});

  @override
  State<LaqaitApp> createState() => _LaqaitAppState();
}

class _LaqaitAppState extends State<LaqaitApp> {
  final AuthProvider _auth = AuthProvider();
  final ReportsProvider _reports = ReportsProvider();
  late final GoRouter _router = createRouter(_auth);
  String? _lastUserId;

  @override
  void initState() {
    super.initState();
    _auth.addListener(_onAuthChanged);
    _onAuthChanged();
  }

  /// Reloads the reports for each new user and clears them on sign-out.
  void _onAuthChanged() {
    final userId = _auth.user?.id;
    if (userId == _lastUserId) return;
    _lastUserId = userId;
    _reports.setUser(userId);
    if (userId != null) _reports.loadReports();
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    _router.dispose();
    _reports.dispose();
    _auth.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _auth),
        ChangeNotifierProvider<ReportsProvider>.value(value: _reports),
        ChangeNotifierProvider(
            create: (_) => ChatProvider()..loadConversations()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()..load()),
        ChangeNotifierProvider(create: (_) => SavedProvider()..load()),
      ],
      child: MaterialApp.router(
        title: 'Laqait',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF006A67),
          brightness: Brightness.light,
        ),
        routerConfig: _router,
      ),
    );
  }
}
