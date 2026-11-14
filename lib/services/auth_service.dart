import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import 'report_service.dart';
import 'supabase_service.dart';

/// An auth error whose message can be shown to the user as it is.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Sign in, sign up and sign out.
///
/// Uses Supabase Auth when the keys are provided. Without keys it keeps a
/// temporary local session so the app can still be demonstrated: any
/// @kfupm.edu.sa email and any password are accepted.
class AuthService {
  static const String _noConnection =
      'No connection. Check your internet and try again.';

  AppUser? _localUser;

  /// The signed-in user, or null. Supabase restores a saved session here.
  AppUser? get currentUser {
    if (!SupabaseService.isConfigured) return _localUser;
    final user = SupabaseService.client.auth.currentUser;
    return user == null ? null : _toAppUser(user);
  }

  /// Emits the user after every sign-in, sign-out or session refresh.
  /// The local demo session never changes by itself, so it emits nothing.
  Stream<AppUser?> get changes {
    if (!SupabaseService.isConfigured) return const Stream<AppUser?>.empty();
    return SupabaseService.client.auth.onAuthStateChange.map((state) {
      final user = state.session?.user;
      return user == null ? null : _toAppUser(user);
    });
  }

  Future<AppUser> signIn(String email, String password) async {
    if (!SupabaseService.isConfigured) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return _localUser = AppUser(
        id: ReportService.currentUserId,
        name: 'Omar Alqahtani',
        email: email.trim(),
      );
    }
    try {
      final res = await SupabaseService.client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = res.user;
      if (user == null) throw const AuthFailure('Sign in failed. Try again.');
      return _toAppUser(user);
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw AuthFailure(_friendly(e));
    } catch (_) {
      throw const AuthFailure(_noConnection);
    }
  }

  Future<AppUser> signUp(String name, String email, String password) async {
    if (!SupabaseService.isConfigured) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return _localUser = AppUser(
        id: ReportService.currentUserId,
        name: name.trim(),
        email: email.trim(),
      );
    }
    try {
      final res = await SupabaseService.client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim()},
      );
      final user = res.user;
      if (user == null) throw const AuthFailure('Sign up failed. Try again.');
      if (res.session == null) {
        // "Confirm email" is still ON in the Supabase dashboard.
        throw const AuthFailure(
            'Account created. Confirm your email, then sign in.');
      }
      return _toAppUser(user);
    } on AuthFailure {
      rethrow;
    } on AuthException catch (e) {
      throw AuthFailure(_friendly(e));
    } catch (_) {
      throw const AuthFailure(_noConnection);
    }
  }

  Future<void> signOut() async {
    _localUser = null;
    if (!SupabaseService.isConfigured) return;
    try {
      await SupabaseService.client.auth.signOut();
    } catch (_) {
      // The local session is already cleared; nothing else to do offline.
    }
  }

  static AppUser _toAppUser(User user) {
    final email = user.email ?? '';
    final name = user.userMetadata?['name'];
    return AppUser(
      id: user.id,
      name: (name is String && name.trim().isNotEmpty)
          ? name
          : email.split('@').first,
      email: email,
    );
  }

  /// Turns Supabase error text into a short message for the user.
  static String _friendly(AuthException e) {
    if (e is AuthRetryableFetchException) return _noConnection;
    final m = e.message.toLowerCase();
    if (m.contains('invalid login credentials')) {
      return 'Wrong email or password';
    }
    if (m.contains('already registered') || m.contains('already exists')) {
      return 'This email already has an account. Sign in instead.';
    }
    if (m.contains('email not confirmed')) {
      return 'Confirm your email first, then sign in';
    }
    if (m.contains('database error')) {
      // Raised by the trigger in supabase/schema.sql.
      return 'Use your @kfupm.edu.sa email';
    }
    return e.message;
  }
}
