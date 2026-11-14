import '../providers/auth_provider.dart';

/// Form validators for Sign In and Sign Up.
/// Each one returns an error message, or null when the value is valid.
class Validators {
  Validators._();

  static final RegExp _emailShape = RegExp(r'^[^@\s]+@[^@\s]+$');

  static String? name(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your name';
    if (v.length < 2) return 'Name is too short';
    return null;
  }

  static String? kfupmEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your email';
    if (!_emailShape.hasMatch(v) || !AuthProvider.isKfupmEmail(v)) {
      return 'Use your @kfupm.edu.sa email';
    }
    return null;
  }

  /// Sign In only checks that a password was typed.
  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password';
    return null;
  }

  /// Sign Up: Supabase needs at least 6 characters.
  static String? newPassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter a password';
    if (value.length < 6) return 'Use at least 6 characters';
    return null;
  }

  static String? confirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) return 'Repeat your password';
    if (value != password) return 'Passwords do not match';
    return null;
  }
}
