import 'package:flutter_test/flutter_test.dart';
import 'package:laqait/models/report.dart';
import 'package:laqait/services/report_service.dart';

Report _draft() => Report(
      id: '',
      type: ReportType.found,
      title: 'Blue umbrella',
      description: 'Left in room 101',
      category: 'Other',
      buildingId: '22',
      occurredAt: DateTime(2026, 10, 15, 10, 30),
      status: ReportStatus.active,
      ownerId: 'u1',
    );

void main() {
  group('Report model', () {
    test('survives a toMap / fromMap round trip', () {
      final r = _draft().copyWith(id: 'abc');
      final back = Report.fromMap(r.toMap());
      expect(back.id, 'abc');
      expect(back.type, ReportType.found);
      expect(back.title, 'Blue umbrella');
      expect(back.buildingId, '22');
      expect(back.occurredAt, r.occurredAt);
      expect(back.status, ReportStatus.active);
    });

    test('reads Supabase UTC times as local time', () {
      final r = Report.fromMap({
        'id': 'x',
        'type': 'lost',
        'title': 'Keys',
        'description': null,
        'category': 'Keys',
        'building_id': '59',
        'photo_url': null,
        'occurred_at': '2026-10-15T07:30:00+00:00',
        'status': 'active',
        'owner_id': 'u9',
      });
      expect(r.occurredAt.isUtc, isFalse);
      expect(r.occurredAt.toUtc(), DateTime.utc(2026, 10, 15, 7, 30));
      expect(r.description, '');
    });
  });

  group('ReportService (local demo store)', () {
    test('a new report gets an id and appears first', () async {
      final service = ReportService();
      final saved = await service.addReport(_draft());
      expect(saved.id, isNotEmpty);
      final all = await service.fetchReports();
      expect(all.first.id, saved.id);
      expect(all.first.title, 'Blue umbrella');
    });

    test('updateStatus marks a report as recovered', () async {
      final service = ReportService();
      final first = (await service.fetchReports()).first;
      await service.updateStatus(first.id, ReportStatus.recovered);
      final again = (await service.fetchReports()).first;
      expect(again.status, ReportStatus.recovered);
    });

    test('describe() keeps ReportFailure messages', () {
      expect(ReportService.describe(const ReportFailure('Oops')), 'Oops');
      expect(ReportService.describe(Exception('x')), contains('No connection'));
    });
  });
}
