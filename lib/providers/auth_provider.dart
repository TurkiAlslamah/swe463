import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/report_service.dart';

/// Signed-in user and session. Placeholder sign-in for the starter app;
/// Phase 3 replaces it with Supabase Auth.
class AuthProvider extends ChangeNotifier {
  AppUser? _user;

  AppUser? get user => _user;
  bool get isSignedIn => _user != null;

  static bool isKfupmEmail(String email) =>
      email.trim().toLowerCase().endsWith('@kfupm.edu.sa');

  Future<void> signIn(String email, String password) async {
    _user = AppUser(
      id: ReportService.currentUserId,
      name: 'Omar Alqahtani',
      email: email.trim(),
    );
    notifyListeners();
  }

  Future<void> signUp(String name, String email, String password) async {
    _user = AppUser(
      id: ReportService.currentUserId,
      name: name.trim(),
      email: email.trim(),
    );
    notifyListeners();
  }

  void signOut() {
    _user = null;
    notifyListeners();
  }
}
