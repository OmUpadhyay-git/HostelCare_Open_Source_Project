class ComplaintCategory {
  final String id;
  final String name;
  final String? description;
  final int slaHours;
  final String defaultPriority;
  final String? responsibleDepartment;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ComplaintCategory({
    required this.id,
    required this.name,
    this.description,
    required this.slaHours,
    required this.defaultPriority,
    this.responsibleDepartment,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ComplaintCategory.fromJson(Map<String, dynamic> json) {
    return ComplaintCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      slaHours: json['sla_hours'] as int? ?? 48,
      defaultPriority: json['default_priority'] as String? ?? 'medium',
      responsibleDepartment: json['responsible_department'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sla_hours': slaHours,
      'default_priority': defaultPriority,
      'responsible_department': responsibleDepartment,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
