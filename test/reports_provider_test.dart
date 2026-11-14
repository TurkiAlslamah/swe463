import 'package:flutter_test/flutter_test.dart';
import 'package:laqait/models/report.dart';
import 'package:laqait/providers/reports_provider.dart';
import 'package:laqait/providers/saved_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReportsProvider (local demo data)', () {
    late ReportsProvider provider;

    setUp(() async {
      provider = ReportsProvider();
      await provider.loadReports();
    });

    test('loads found and lost reports', () {
      expect(provider.isLoading, isFalse);
      expect(provider.error, isNull);
      expect(provider.found, isNotEmpty);
      expect(provider.lost, isNotEmpty);
      expect(provider.found.every((r) => r.type == ReportType.found), isTrue);
      expect(provider.lost.every((r) => r.type == ReportType.lost), isTrue);
    });

    test('text search looks at the title (any case)', () {
      final titles = provider.search(query: 'AIRPODS').map((r) => r.title);
      expect(titles, contains('Black AirPods case'));
    });

    test('category and building filters work together', () {
      final keys = provider.search(category: 'Keys');
      expect(keys, isNotEmpty);
      expect(keys.every((r) => r.category == 'Keys'), isTrue);

      final keysIn22 = provider.search(category: 'Keys', buildingId: '22');
      expect(keysIn22, isNotEmpty);
      expect(
          keysIn22.every((r) => r.category == 'Keys' && r.buildingId == '22'),
          isTrue);
    });

    test('date filter keeps only reports from that day', () {
      final today = DateTime.now();
      final results = provider.search(onDate: today);
      expect(results, isNotEmpty);
      expect(results.every((r) => r.occurredAt.day == today.day), isTrue);
    });

    test('no match returns an empty list (empty state)', () {
      expect(provider.search(query: 'umbrella'), isEmpty);
    });

    test('markRecovered changes the status', () async {
      final id = provider.found.first.id;
      await provider.markRecovered(id);
      expect(provider.byId(id)!.status, ReportStatus.recovered);
    });
  });

  group('SavedProvider (shared_preferences)', () {
    test('toggle saves, persists and removes an id', () async {
      SharedPreferences.setMockInitialValues({});
      final saved = SavedProvider();
      await saved.load();

      await saved.toggle('r1');
      expect(saved.isSaved('r1'), isTrue);

      // A new provider reads the same id back from the phone storage.
      final reopened = SavedProvider();
      await reopened.load();
      expect(reopened.isSaved('r1'), isTrue);

      await saved.toggle('r1');
      expect(saved.isSaved('r1'), isFalse);
    });
  });
}
