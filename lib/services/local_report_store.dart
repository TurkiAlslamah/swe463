import '../models/report.dart';

/// TEMPORARY data source, used only when the Supabase keys are not provided.
///
/// It keeps the sample reports from the Figma frames in memory so every
/// screen can still be demonstrated offline. Only ReportService uses it, so
/// it can be deleted in Phase 4 without changing any screen or provider.
class LocalReportStore {
  LocalReportStore() : _reports = _sample();

  final List<Report> _reports;

  Future<List<Report>> fetchAll() async {
    // Short wait so the loading state is visible, like a real request.
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return List<Report>.from(_reports);
  }

  Future<Report> add(Report report) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final saved = report.id.isNotEmpty
        ? report
        : report.copyWith(id: 'r${DateTime.now().microsecondsSinceEpoch}');
    _reports.insert(0, saved);
    return saved;
  }

  Future<void> updateStatus(String id, ReportStatus status) async {
    final i = _reports.indexWhere((r) => r.id == id);
    if (i != -1) _reports[i] = _reports[i].copyWith(status: status);
  }

  static List<Report> _sample() {
    final now = DateTime.now();
    Report r(String id, ReportType type, String title, String desc, String cat,
        String b, int daysAgo, String owner,
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
      r('r5', f, 'Black wallet', 'Found in the prayer room.', 'Wallets', '4', 4,
          'u2'),
      r('r6', f, 'Casio calculator', 'Found after the exam in room 101.',
          'Electronics', '6', 0, 'u3'),
      r('r7', l, 'Gray backpack', 'Gray backpack with a laptop inside.', 'Bags',
          '76', 0, 'u1'),
      r('r8', l, 'Casio calculator', 'fx-991 with my name on the back.',
          'Electronics', '6', 1, 'u1'),
      r('r9', l, 'House keys', 'Three keys on a red ring.', 'Keys', '22', 5,
          'u4'),
    ];
  }
}
