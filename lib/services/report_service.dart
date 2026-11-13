import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/report.dart';
import 'local_report_store.dart';
import 'supabase_service.dart';

/// An error whose message can be shown to the user as it is.
class ReportFailure implements Exception {
  const ReportFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Repository for reports. Providers talk only to this class.
///
/// * Supabase keys provided -> `reports` table + `report-photos` bucket.
/// * No keys (demo mode)    -> [LocalReportStore], a temporary memory store.
class ReportService {
  ReportService({LocalReportStore? local})
      : _local = local ?? LocalReportStore();

  final LocalReportStore _local;

  /// Id of the local demo user (owner of some sample reports).
  static const String currentUserId = 'u1';

  static const List<String> categories = [
    'Electronics',
    'Keys',
    'Cards & IDs',
    'Bags',
    'Bottles',
    'Wallets',
    'Other',
  ];

  static String buildingLabel(String buildingId) =>
      buildingId == 'library' ? 'Library' : 'Building $buildingId';

  bool get _online => SupabaseService.isConfigured;
  SupabaseClient get _db => SupabaseService.client;

  Future<List<Report>> fetchReports() async {
    if (!_online) return _local.fetchAll();
    final rows = await _db
        .from('reports')
        .select()
        .order('occurred_at', ascending: false);
    return rows.map(Report.fromMap).toList();
  }

  /// Uploads the photo (if any), saves the report and returns the stored
  /// copy, which carries the real id given by the database.
  Future<Report> addReport(Report report, {XFile? photo}) async {
    if (!_online) return _local.add(report.copyWith(photoUrl: photo?.path));

    final uid = _db.auth.currentUser?.id;
    if (uid == null) {
      throw const ReportFailure('Your session ended. Sign in again.');
    }
    final photoUrl = photo == null ? null : await _uploadPhoto(uid, photo);
    final row = report.toMap()
      ..remove('id') // Postgres creates the id.
      ..['owner_id'] = uid
      ..['photo_url'] = photoUrl;
    final saved = await _db.from('reports').insert(row).select().single();
    return Report.fromMap(saved);
  }

  Future<void> updateStatus(String id, ReportStatus status) async {
    if (!_online) return _local.updateStatus(id, status);
    final rows = await _db
        .from('reports')
        .update({'status': status.name})
        .eq('id', id)
        .select();
    if (rows.isEmpty) {
      throw const ReportFailure('Only the owner can change this report.');
    }
  }

  Future<String> _uploadPhoto(String uid, XFile photo) async {
    final bytes = await photo.readAsBytes();
    final isPng = photo.name.toLowerCase().endsWith('.png');
    final path =
        '$uid/${DateTime.now().millisecondsSinceEpoch}.${isPng ? 'png' : 'jpg'}';
    final bucket = _db.storage.from(SupabaseService.photoBucket);
    await bucket.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: isPng ? 'image/png' : 'image/jpeg'),
    );
    return bucket.getPublicUrl(path);
  }

  /// Turns any error into a short message for a SnackBar or error state.
  static String describe(Object error) {
    if (error is ReportFailure) return error.message;
    if (error is PostgrestException) return 'Server error: ${error.message}';
    if (error is StorageException) {
      return 'Photo upload failed: ${error.message}';
    }
    return 'No connection. Check your internet and try again.';
  }
}
