
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/building.dart';

/// Reads campus buildings from assets/buildings.json.
/// Caches the list after the first load.
class BuildingService {
  BuildingService._();

  static List<Building>? _cache;

  static Future<List<Building>> loadAll() async {
    final cached = _cache;
    if (cached != null) return cached;

    final raw = await rootBundle.loadString('assets/buildings.json');
    final list =
        (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();

    final buildings = [
      for (final j in list) Building.fromJson(j),
    ];

    _cache = buildings;
    return buildings;
  }

  /// Returns a building by ID, or null if not found.
  static Building? find(List<Building> buildings, String id) {
    for (final b in buildings) {
      if (b.id == id) return b;
    }
    return null;
  }
}
