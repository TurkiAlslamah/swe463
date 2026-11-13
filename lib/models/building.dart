
class Building {
  final String id;
  final int number;
  final String name;
  final double lat;
  final double lon;

  /// Pin position on assets/campus_map.png, from 0 (left/top)
  /// to 1 (right/bottom).
  final double mapX;
  final double mapY;

  const Building({
    required this.id,
    required this.number,
    required this.name,
    required this.lat,
    required this.lon,
    this.mapX = 0.5,
    this.mapY = 0.5,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] as String,
      number: json['number'] as int,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
      mapX: (json['mapX'] as num?)?.toDouble() ?? 0.5,
      mapY: (json['mapY'] as num?)?.toDouble() ?? 0.5,
    );
  }

  /// Short text drawn inside the map pin.
  String get shortLabel => id == 'library' ? 'Lib' : '$number';
}

// Reviewed by Faisal
