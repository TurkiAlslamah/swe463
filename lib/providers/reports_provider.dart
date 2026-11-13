import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/report.dart';
import '../services/report_service.dart';

/// Report lists, filters, loading/posting and error state.
class ReportsProvider extends ChangeNotifier {
  ReportsProvider({ReportService? service})
      : _service = service ?? ReportService();

  final ReportService _service;

  List<Report> _reports = [];
  bool isLoading = false;
  bool isPosting = false;
  String? error;
  String _userId = ReportService.currentUserId;

  List<Report> get reports => _reports;
  List<Report> get found =>
      _reports.where((r) => r.type == ReportType.found).toList();
  List<Report> get lost =>
      _reports.where((r) => r.type == ReportType.lost).toList();

  /// Reports posted by the signed-in user (My Account).
  List<Report> get mine => _reports.where((r) => r.ownerId == _userId).toList();

  /// Called by main.dart whenever the signed-in user changes.
  void setUser(String? userId) {
    _userId = userId ?? '';
    if (userId == null) {
      _reports = [];
      error = null;
    }
    notifyListeners();
  }

  Report? byId(String id) {
    for (final r in _reports) {
      if (r.id == id) return r;
    }
    return null;
  }

  Future<void> loadReports() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      _reports = await _service.fetchReports();
    } catch (e) {
      error = ReportService.describe(e);
    }
    isLoading = false;
    notifyListeners();
  }

  /// Posts a report and returns the saved copy (with its real id).
  /// Errors are re-thrown so the New Report screen can show them.
  Future<Report> addReport(Report report, {XFile? photo}) async {
    isPosting = true;
    notifyListeners();
    try {
      final saved = await _service.addReport(report, photo: photo);
      _reports = [saved, ..._reports.where((r) => r.id != saved.id)];
      return saved;
    } finally {
      isPosting = false;
      notifyListeners();
    }
  }

  Future<void> markRecovered(String id) async {
    await _service.updateStatus(id, ReportStatus.recovered);
    _reports = [
      for (final r in _reports)
        r.id == id ? r.copyWith(status: ReportStatus.recovered) : r,
    ];
    notifyListeners();
  }

  /// Search screen: text query plus optional category, building and date.
  List<Report> search({
    String query = '',
    String? category,
    String? buildingId,
    DateTime? onDate,
  }) {
    final q = query.trim().toLowerCase();
    return _reports.where((r) {
      if (q.isNotEmpty &&
          !r.title.toLowerCase().contains(q) &&
          !r.description.toLowerCase().contains(q)) {
        return false;
      }
      if (category != null && r.category != category) return false;
      if (buildingId != null && r.buildingId != buildingId) return false;
      if (onDate != null &&
          (r.occurredAt.year != onDate.year ||
              r.occurredAt.month != onDate.month ||
              r.occurredAt.day != onDate.day)) {
        return false;
      }
      return true;
    }).toList();
  }
}
