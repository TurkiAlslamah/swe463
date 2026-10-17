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
  // Connects to Supabase only when keys are provided with --dart-define.
  // The starter app runs on local sample data without them.
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
  late final GoRouter _router = createRouter(_auth);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: _auth),
        ChangeNotifierProvider(create: (_) => ReportsProvider()..loadReports()),
        ChangeNotifierProvider(create: (_) => ChatProvider()..loadConversations()),
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
