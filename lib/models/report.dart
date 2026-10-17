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

  Report copyWith({ReportStatus? status}) {
    return Report(
      id: id,
      type: type,
      title: title,
      description: description,
      category: category,
      buildingId: buildingId,
      photoUrl: photoUrl,
      occurredAt: occurredAt,
      status: status ?? this.status,
      ownerId: ownerId,
    );
  }

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'] as String,
      type: ReportType.values.byName(map['type'] as String),
      title: map['title'] as String,
      description: (map['description'] ?? '') as String,
      category: map['category'] as String,
      buildingId: map['building_id'] as String,
      photoUrl: map['photo_url'] as String?,
      occurredAt: DateTime.parse(map['occurred_at'] as String),
      status: ReportStatus.values.byName(map['status'] as String),
      ownerId: map['owner_id'] as String,
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
      'occurred_at': occurredAt.toIso8601String(),
      'status': status.name,
      'owner_id': ownerId,
    };
  }
}
