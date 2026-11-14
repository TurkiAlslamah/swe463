import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

/// Signed-in user and session. Shared by every screen and by the router,
/// which opens Home or Sign In whenever this provider notifies.
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? service}) : _service = service ?? AuthService() {
    // Supabase keeps the session on the phone, so the user stays signed in
    // after the app restarts.
    _user = _service.currentUser;
    _subscription = _service.changes.listen((user) {
      if (user?.id == _user?.id) return;
      _user = user;
      notifyListeners();
    });
  }

  final AuthService _service;
  late final StreamSubscription<AppUser?> _subscription;
  AppUser? _user;

  AppUser? get user => _user;
  bool get isSignedIn => _user != null;

  static bool isKfupmEmail(String email) =>
      email.trim().toLowerCase().endsWith('@kfupm.edu.sa');

  /// Throws [AuthFailure] with a message that can be shown to the user.
  Future<void> signIn(String email, String password) async {
    _user = await _service.signIn(email, password);
    notifyListeners();
  }

  /// Throws [AuthFailure] with a message that can be shown to the user.
  Future<void> signUp(String name, String email, String password) async {
    _user = await _service.signUp(name, email, password);
    notifyListeners();
  }

  Future<void> signOut() async {
    _user = null;
    notifyListeners();
    await _service.signOut();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
