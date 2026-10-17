import '../models/report.dart';
import 'supabase_service.dart';

/// Reads and writes reports. Uses the Supabase `reports` table when it is
/// configured, otherwise the sample data below (same items as the Figma frames).
class ReportService {
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

  final List<Report> _sample = _buildSample();

  Future<List<Report>> fetchReports() async {
    if (SupabaseService.isConfigured) {
      final rows = await SupabaseService.client
          .from('reports')
          .select()
          .order('occurred_at', ascending: false);
      return rows.map((r) => Report.fromMap(r)).toList();
    }
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return List<Report>.from(_sample);
  }

  Future<Report> addReport(Report report) async {
    if (SupabaseService.isConfigured) {
      await SupabaseService.client.from('reports').insert(report.toMap());
    } else {
      _sample.insert(0, report);
    }
    return report;
  }

  Future<void> updateStatus(String id, ReportStatus status) async {
    if (SupabaseService.isConfigured) {
      await SupabaseService.client
          .from('reports')
          .update({'status': status.name}).eq('id', id);
      return;
    }
    final i = _sample.indexWhere((r) => r.id == id);
    if (i != -1) _sample[i] = _sample[i].copyWith(status: status);
  }

  static List<Report> _buildSample() {
    final now = DateTime.now();
    Report r(String id, ReportType type, String title, String desc,
        String cat, String b, int daysAgo, String owner,
        [ReportStatus status = ReportStatus.active]) {
      return Report(
        id: id,
        type: type,
        title: title,
        description: desc,
        category: cat,
        buildingId: b,
        occurredAt: now.subtract(Duration(days: daysAgo)),
        status: status,
        ownerId: owner,
      );
    }

    const f = ReportType.found;
    const l = ReportType.lost;
    return [
      r('r1', f, 'Black AirPods case', 'Found on a desk in room 120.',
          'Electronics', '22', 0, 'u2'),
      r('r2', f, 'Student ID card', 'Left at the front desk.', 'Cards & IDs',
          'library', 1, 'u3'),
      r('r3', f, 'Car keys with blue tag', 'Found near the parking gate.',
          'Keys', '59', 2, 'u4'),
      r('r4', f, 'Blue water bottle', 'Found in the cafeteria.', 'Bottles',
          '24', 3, 'u1', ReportStatus.recovered),
      r('r5', f, 'Black wallet', 'Found in the prayer room.', 'Wallets', '4',
          4, 'u2'),
      r('r6', f, 'Casio calculator', 'Found after the exam in room 101.',
          'Electronics', '6', 0, 'u3'),
      r('r7', l, 'Gray backpack', 'Gray backpack with a laptop inside.',
          'Bags', '76', 0, 'u1'),
      r('r8', l, 'Casio calculator', 'fx-991 with my name on the back.',
          'Electronics', '6', 1, 'u1'),
      r('r9', l, 'House keys', 'Three keys on a red ring.', 'Keys', '22', 5,
          'u4'),
    ];
  }
}
