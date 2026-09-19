class Student {
  final String id;
  final String profileId;
  final String studentId;
  final String hostelId;
  final String blockId;
  final String floorId;
  final String roomId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Student({
    required this.id,
    required this.profileId,
    required this.studentId,
    required this.hostelId,
    required this.blockId,
    required this.floorId,
    required this.roomId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      studentId: json['student_id'] as String,
      hostelId: json['hostel_id'] as String,
      blockId: json['block_id'] as String,
      floorId: json['floor_id'] as String,
      roomId: json['room_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'student_id': studentId,
      'hostel_id': hostelId,
      'block_id': blockId,
      'floor_id': floorId,
      'room_id': roomId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
