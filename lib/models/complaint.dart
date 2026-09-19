import '../core/constants/complaint_status.dart';
import '../core/constants/complaint_priority.dart';

class Complaint {
  final String id;
  final String complaintNumber;
  final String studentId;
  final String categoryId;
  final String? assignedWardenId;
  final String? assignedStaffId;
  final String hostelId;
  final String blockId;
  final String floorId;
  final String roomId;
  final String title;
  final String? description;
  final ComplaintPriority priority;
  final ComplaintStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? acceptedAt;
  final DateTime? assignedAt;
  final DateTime? startedAt;
  final DateTime? resolvedAt;
  final DateTime? verifiedAt;
  final DateTime? closedAt;
  final DateTime? reopenedAt;
  final DateTime? slaDeadline;
  final String? resolutionRemark;
  final String? resolutionImagePath;

  // Joined data (optional)
  final String? categoryName;
  final String? studentName;
  final String? studentIdentifier;
  final String? hostelName;
  final String? blockName;
  final String? floorName;
  final String? roomNumber;
  final String? wardenName;
  final String? staffName;

  const Complaint({
    required this.id,
    required this.complaintNumber,
    required this.studentId,
    required this.categoryId,
    this.assignedWardenId,
    this.assignedStaffId,
    required this.hostelId,
    required this.blockId,
    required this.floorId,
    required this.roomId,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedAt,
    this.assignedAt,
    this.startedAt,
    this.resolvedAt,
    this.verifiedAt,
    this.closedAt,
    this.reopenedAt,
    this.slaDeadline,
    this.resolutionRemark,
    this.resolutionImagePath,
    this.categoryName,
    this.studentName,
    this.studentIdentifier,
    this.hostelName,
    this.blockName,
    this.floorName,
    this.roomNumber,
    this.wardenName,
    this.staffName,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] as String,
      complaintNumber: json['complaint_number'] as String,
      studentId: json['student_id'] as String,
      categoryId: json['category_id'] as String,
      assignedWardenId: json['assigned_warden_id'] as String?,
      assignedStaffId: json['assigned_staff_id'] as String?,
      hostelId: json['hostel_id'] as String,
      blockId: json['block_id'] as String,
      floorId: json['floor_id'] as String,
      roomId: json['room_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: parseComplaintPriority(json['priority'] as String),
      status: parseComplaintStatus(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      assignedAt: json['assigned_at'] != null
          ? DateTime.parse(json['assigned_at'] as String)
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'] as String)
          : null,
      reopenedAt: json['reopened_at'] != null
          ? DateTime.parse(json['reopened_at'] as String)
          : null,
      slaDeadline: json['sla_deadline'] != null
          ? DateTime.parse(json['sla_deadline'] as String)
          : null,
      resolutionRemark: json['resolution_remark'] as String?,
      resolutionImagePath: json['resolution_image_path'] as String?,
      categoryName: json['category_name'] as String?,
      studentName: json['student_name'] as String?,
      studentIdentifier: json['student_identifier'] as String?,
      hostelName: json['hostel_name'] as String?,
      blockName: json['block_name'] as String?,
      floorName: json['floor_name'] as String?,
      roomNumber: json['room_number'] as String?,
      wardenName: json['warden_name'] as String?,
      staffName: json['staff_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaint_number': complaintNumber,
      'student_id': studentId,
      'category_id': categoryId,
      'assigned_warden_id': assignedWardenId,
      'assigned_staff_id': assignedStaffId,
      'hostel_id': hostelId,
      'block_id': blockId,
      'floor_id': floorId,
      'room_id': roomId,
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'assigned_at': assignedAt?.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'resolved_at': resolvedAt?.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
      'closed_at': closedAt?.toIso8601String(),
      'reopened_at': reopenedAt?.toIso8601String(),
      'sla_deadline': slaDeadline?.toIso8601String(),
      'resolution_remark': resolutionRemark,
      'resolution_image_path': resolutionImagePath,
    };
  }

  String get locationDisplay {
    final parts = <String>[];
    if (hostelName != null) parts.add(hostelName!);
    if (blockName != null) parts.add(blockName!);
    if (floorName != null) parts.add(floorName!);
    if (roomNumber != null) parts.add('Room $roomNumber');
    return parts.join(', ');
  }
}
