
import 'package:flutter_test/flutter_test.dart';
import 'package:laqait/models/building.dart';
import 'package:laqait/services/building_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads every building from assets/buildings.json', () async {
    final buildings = await BuildingService.loadAll();
    expect(buildings, isNotEmpty);
    expect(buildings.map((b) => b.id), containsAll(['22', 'library', '76']));
  });

  test('map positions are inside the map image (0..1)', () async {
    for (final b in await BuildingService.loadAll()) {
      expect(b.mapX, inInclusiveRange(0, 1), reason: b.name);
      expect(b.mapY, inInclusiveRange(0, 1), reason: b.name);
    }
  });

  test('find() returns the building or null', () async {
    final buildings = await BuildingService.loadAll();
    expect(BuildingService.find(buildings, '22')?.name, 'Building 22');
    expect(BuildingService.find(buildings, 'nope'), isNull);
  });

  test('shortLabel shows the number, or Lib for the library', () {
    const b22 = Building(id: '22', number: 22, name: 'B22', lat: 0, lon: 0);
    const lib =
        Building(id: 'library', number: 21, name: 'Library', lat: 0, lon: 0);
    expect(b22.shortLabel, '22');
    expect(lib.shortLabel, 'Lib');
    expect(b22.mapX, 0.5);
  });
}
