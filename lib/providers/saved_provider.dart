import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Saved report IDs, kept on the phone with shared_preferences (Feature F8).
class SavedProvider extends ChangeNotifier {
  static const String _key = 'saved_report_ids';

  final Set<String> _ids = {};

  Set<String> get ids => Set.unmodifiable(_ids);
  bool isSaved(String id) => _ids.contains(id);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _ids
      ..clear()
      ..addAll(prefs.getStringList(_key) ?? const []);
    notifyListeners();
  }

  Future<void> toggle(String id) async {
    if (!_ids.remove(id)) _ids.add(id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _ids.toList());
  }
}
