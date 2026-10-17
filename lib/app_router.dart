import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'screens/account_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/chats_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_picker_screen.dart';
import 'screens/new_report_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/report_details_screen.dart';
import 'screens/saved_reports_screen.dart';
import 'screens/search_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';

/// Routes follow the navigation flow in Section 3 of the Phase 2 document.
GoRouter createRouter(AuthProvider auth) {
  return GoRouter(
    initialLocation: '/sign-in',
    refreshListenable: auth,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final onAuthPage = loc == '/sign-in' || loc == '/sign-up';
      if (!auth.isSignedIn && !onAuthPage) return '/sign-in';
      if (auth.isSignedIn && onAuthPage) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/sign-in', builder: (_, __) => const SignInScreen()),
      GoRoute(path: '/sign-up', builder: (_, __) => const SignUpScreen()),

      // Bottom navigation: Home, Search, Report, Chats, Account.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/search', builder: (_, __) => const SearchScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/report', builder: (_, __) => const NewReportScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/chats', builder: (_, __) => const ChatsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/account', builder: (_, __) => const AccountScreen()),
          ]),
        ],
      ),

      // Full-screen pages opened on top of the tabs.
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/map-picker',
        builder: (_, __) => const MapPickerScreen(),
      ),
      GoRoute(
        path: '/reports/:id',
        builder: (_, state) =>
            ReportDetailsScreen(reportId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/saved',
        builder: (_, __) => const SavedReportsScreen(),
      ),
      GoRoute(
        path: '/chats/:id',
        builder: (_, state) =>
            ChatScreen(conversationId: state.pathParameters['id']!),
      ),
    ],
  );
}

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Report',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
