class StaffMember {
  final String id;
  final String profileId;
  final String staffId;
  final String? department;
  final String? specialization;
  final String? hostelId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data
  final String? fullName;
  final String? email;

  const StaffMember({
    required this.id,
    required this.profileId,
    required this.staffId,
    this.department,
    this.specialization,
    this.hostelId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.fullName,
    this.email,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      staffId: json['staff_id'] as String,
      department: json['department'] as String?,
      specialization: json['specialization'] as String?,
      hostelId: json['hostel_id'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'staff_id': staffId,
      'department': department,
      'specialization': specialization,
      'hostel_id': hostelId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName => fullName ?? staffId;
  String get departmentDisplay => department ?? 'General';
}
