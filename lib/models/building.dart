class Building {
  final String id;
  final int number;
  final String name;
  final double lat;
  final double lon;

  const Building({
    required this.id,
    required this.number,
    required this.name,
    required this.lat,
    required this.lon,
  });

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] as String,
      number: json['number'] as int,
      name: json['name'] as String,
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }
}

// Reviewed by Faisal