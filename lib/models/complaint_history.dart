import '../core/constants/complaint_status.dart';

class ComplaintHistory {
  final String id;
  final String complaintId;
  final String changedBy;
  final ComplaintStatus? oldStatus;
  final ComplaintStatus? newStatus;
  final String action;
  final String? remark;
  final DateTime createdAt;

  // Joined data (optional)
  final String? changedByName;
  final String? changedByRole;

  const ComplaintHistory({
    required this.id,
    required this.complaintId,
    required this.changedBy,
    this.oldStatus,
    this.newStatus,
    required this.action,
    this.remark,
    required this.createdAt,
    this.changedByName,
    this.changedByRole,
  });

  factory ComplaintHistory.fromJson(Map<String, dynamic> json) {
    return ComplaintHistory(
      id: json['id'] as String,
      complaintId: json['complaint_id'] as String,
      changedBy: json['changed_by'] as String,
      oldStatus: json['old_status'] != null
          ? parseComplaintStatus(json['old_status'] as String)
          : null,
      newStatus: json['new_status'] != null
          ? parseComplaintStatus(json['new_status'] as String)
          : null,
      action: json['action'] as String,
      remark: json['remark'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      changedByName: json['changed_by_name'] as String?,
      changedByRole: json['changed_by_role'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaint_id': complaintId,
      'changed_by': changedBy,
      'old_status': oldStatus?.name,
      'new_status': newStatus?.name,
      'action': action,
      'remark': remark,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
