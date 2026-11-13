enum ReportType { lost, found }

enum ReportStatus { active, recovered }

class Report {
  final String id;
  final ReportType type;
  final String title;
  final String description;
  final String category;
  final String buildingId;
  final String? photoUrl; // required for found reports
  final DateTime occurredAt;
  final ReportStatus status;
  final String ownerId;

  const Report({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.category,
    required this.buildingId,
    this.photoUrl,
    required this.occurredAt,
    required this.status,
    required this.ownerId,
  });

  Report copyWith({
    String? id,
    ReportStatus? status,
    String? photoUrl,
    String? ownerId,
  }) {
    return Report(
      id: id ?? this.id,
      type: type,
      title: title,
      description: description,
      category: category,
      buildingId: buildingId,
      photoUrl: photoUrl ?? this.photoUrl,
      occurredAt: occurredAt,
      status: status ?? this.status,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  /// Reads one row of the Supabase `reports` table.
  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'].toString(),
      type: ReportType.values.byName(map['type'] as String),
      title: map['title'] as String,
      description: (map['description'] ?? '') as String,
      category: map['category'] as String,
      buildingId: map['building_id'].toString(),
      photoUrl: map['photo_url'] as String?,
      // Supabase stores UTC; show it in the phone's time zone.
      occurredAt: DateTime.parse(map['occurred_at'] as String).toLocal(),
      status: ReportStatus.values.byName(map['status'] as String),
      ownerId: map['owner_id'].toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'description': description,
      'category': category,
      'building_id': buildingId,
      'photo_url': photoUrl,
      'occurred_at': occurredAt.toUtc().toIso8601String(),
      'status': status.name,
      'owner_id': ownerId,
    };
  }
}

// Reviewed by Faisal
