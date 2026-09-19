import 'package:flutter_test/flutter_test.dart';
import 'package:hostelcare/core/constants/complaint_status.dart';
import 'package:hostelcare/core/constants/complaint_priority.dart';
import 'package:hostelcare/models/complaint.dart';
import 'package:hostelcare/models/complaint_category.dart';
import 'package:hostelcare/models/complaint_history.dart';

void main() {
  group('Complaint Model', () {
    test('fromJson creates Complaint correctly', () {
      final json = {
        'id': 'test-id',
        'complaint_number': 'HC-2026-000001',
        'student_id': 'student-id',
        'category_id': 'category-id',
        'assigned_warden_id': null,
        'assigned_staff_id': null,
        'hostel_id': 'hostel-id',
        'block_id': 'block-id',
        'floor_id': 'floor-id',
        'room_id': 'room-id',
        'title': 'Test Complaint',
        'description': 'Test description',
        'priority': 'medium',
        'status': 'pending',
        'created_at': '2026-09-19T10:00:00Z',
        'updated_at': '2026-09-19T10:00:00Z',
        'accepted_at': null,
        'assigned_at': null,
        'started_at': null,
        'resolved_at': null,
        'verified_at': null,
        'closed_at': null,
        'reopened_at': null,
        'sla_deadline': null,
        'resolution_remark': null,
        'resolution_image_path': null,
        'category_name': 'Plumbing',
        'student_name': 'John Doe',
        'student_identifier': 'STU001',
        'hostel_name': 'Hostel A',
        'block_name': 'Block B',
        'floor_name': 'Floor 1',
        'room_number': '101',
        'warden_name': 'Warden Smith',
        'staff_name': null,
      };

      final complaint = Complaint.fromJson(json);

      expect(complaint.id, 'test-id');
      expect(complaint.complaintNumber, 'HC-2026-000001');
      expect(complaint.title, 'Test Complaint');
      expect(complaint.description, 'Test description');
      expect(complaint.priority, ComplaintPriority.medium);
      expect(complaint.status, ComplaintStatus.pending);
      expect(complaint.categoryName, 'Plumbing');
      expect(complaint.studentName, 'John Doe');
      expect(complaint.studentIdentifier, 'STU001');
      expect(complaint.hostelName, 'Hostel A');
      expect(complaint.blockName, 'Block B');
      expect(complaint.floorName, 'Floor 1');
      expect(complaint.roomNumber, '101');
      expect(complaint.wardenName, 'Warden Smith');
      expect(complaint.staffName, isNull);
    });

    test('toJson converts Complaint to JSON correctly', () {
      final complaint = Complaint(
        id: 'test-id',
        complaintNumber: 'HC-2026-000001',
        studentId: 'student-id',
        categoryId: 'category-id',
        hostelId: 'hostel-id',
        blockId: 'block-id',
        floorId: 'floor-id',
        roomId: 'room-id',
        title: 'Test Complaint',
        description: 'Test description',
        priority: ComplaintPriority.medium,
        status: ComplaintStatus.pending,
        createdAt: DateTime(2026, 9, 19, 10, 0, 0),
        updatedAt: DateTime(2026, 9, 19, 10, 0, 0),
      );

      final json = complaint.toJson();

      expect(json['id'], 'test-id');
      expect(json['complaint_number'], 'HC-2026-000001');
      expect(json['title'], 'Test Complaint');
      expect(json['priority'], 'medium');
      expect(json['status'], 'pending');
    });

    test('locationDisplay returns formatted location', () {
      final complaint = Complaint(
        id: 'test-id',
        complaintNumber: 'HC-2026-000001',
        studentId: 'student-id',
        categoryId: 'category-id',
        hostelId: 'hostel-id',
        blockId: 'block-id',
        floorId: 'floor-id',
        roomId: 'room-id',
        title: 'Test',
        priority: ComplaintPriority.medium,
        status: ComplaintStatus.pending,
        createdAt: DateTime(2026, 9, 19),
        updatedAt: DateTime(2026, 9, 19),
        hostelName: 'Hostel A',
        blockName: 'Block B',
        floorName: 'Floor 1',
        roomNumber: '101',
      );

      expect(complaint.locationDisplay, 'Hostel A, Block B, Floor 1, Room 101');
    });

    test('locationDisplay returns empty string when no location data', () {
      final complaint = Complaint(
        id: 'test-id',
        complaintNumber: 'HC-2026-000001',
        studentId: 'student-id',
        categoryId: 'category-id',
        hostelId: 'hostel-id',
        blockId: 'block-id',
        floorId: 'floor-id',
        roomId: 'room-id',
        title: 'Test',
        priority: ComplaintPriority.medium,
        status: ComplaintStatus.pending,
        createdAt: DateTime(2026, 9, 19),
        updatedAt: DateTime(2026, 9, 19),
      );

      expect(complaint.locationDisplay, '');
    });
  });

  group('ComplaintCategory Model', () {
    test('fromJson creates ComplaintCategory correctly', () {
      final json = {
        'id': 'cat-id',
        'name': 'Plumbing',
        'description': 'Plumbing issues',
        'sla_hours': 48,
        'default_priority': 'high',
        'responsible_department': 'Maintenance',
        'is_active': true,
        'created_at': '2026-09-19T10:00:00Z',
        'updated_at': '2026-09-19T10:00:00Z',
      };

      final category = ComplaintCategory.fromJson(json);

      expect(category.id, 'cat-id');
      expect(category.name, 'Plumbing');
      expect(category.description, 'Plumbing issues');
      expect(category.slaHours, 48);
      expect(category.defaultPriority, 'high');
      expect(category.responsibleDepartment, 'Maintenance');
      expect(category.isActive, true);
    });

    test('handles null optional fields', () {
      final json = {
        'id': 'cat-id',
        'name': 'Other',
        'description': null,
        'sla_hours': 72,
        'default_priority': 'medium',
        'responsible_department': null,
        'is_active': true,
        'created_at': '2026-09-19T10:00:00Z',
        'updated_at': '2026-09-19T10:00:00Z',
      };

      final category = ComplaintCategory.fromJson(json);

      expect(category.description, isNull);
      expect(category.responsibleDepartment, isNull);
    });
  });

  group('ComplaintHistory Model', () {
    test('fromJson creates ComplaintHistory correctly', () {
      final json = {
        'id': 'history-id',
        'complaint_id': 'complaint-id',
        'changed_by': 'user-id',
        'old_status': 'pending',
        'new_status': 'accepted',
        'action': 'Status changed',
        'remark': 'Complaint accepted by warden',
        'created_at': '2026-09-19T10:00:00Z',
        'changed_by_name': 'Warden Smith',
        'changed_by_role': 'warden',
      };

      final history = ComplaintHistory.fromJson(json);

      expect(history.id, 'history-id');
      expect(history.complaintId, 'complaint-id');
      expect(history.changedBy, 'user-id');
      expect(history.oldStatus, ComplaintStatus.pending);
      expect(history.newStatus, ComplaintStatus.accepted);
      expect(history.action, 'Status changed');
      expect(history.remark, 'Complaint accepted by warden');
      expect(history.changedByName, 'Warden Smith');
      expect(history.changedByRole, 'warden');
    });

    test('handles null statuses', () {
      final json = {
        'id': 'history-id',
        'complaint_id': 'complaint-id',
        'changed_by': 'user-id',
        'old_status': null,
        'new_status': null,
        'action': 'Comment added',
        'remark': null,
        'created_at': '2026-09-19T10:00:00Z',
        'changed_by_name': null,
        'changed_by_role': null,
      };

      final history = ComplaintHistory.fromJson(json);

      expect(history.oldStatus, isNull);
      expect(history.newStatus, isNull);
      expect(history.changedByName, isNull);
      expect(history.changedByRole, isNull);
    });
  });

  group('ComplaintStatus Extension', () {
    test('label returns correct labels', () {
      expect(ComplaintStatus.pending.label, 'PENDING');
      expect(ComplaintStatus.accepted.label, 'ACCEPTED');
      expect(ComplaintStatus.assigned.label, 'ASSIGNED');
      expect(ComplaintStatus.inProgress.label, 'IN PROGRESS');
      expect(ComplaintStatus.resolved.label, 'RESOLVED');
      expect(ComplaintStatus.verified.label, 'VERIFIED');
      expect(ComplaintStatus.closed.label, 'CLOSED');
      expect(ComplaintStatus.rejected.label, 'REJECTED');
      expect(ComplaintStatus.cancelled.label, 'CANCELLED');
      expect(ComplaintStatus.reopened.label, 'REOPENED');
      expect(ComplaintStatus.onHold.label, 'ON HOLD');
    });

    test('isTerminal returns true for terminal states', () {
      expect(ComplaintStatus.closed.isTerminal, true);
      expect(ComplaintStatus.cancelled.isTerminal, true);
      expect(ComplaintStatus.rejected.isTerminal, true);
      expect(ComplaintStatus.pending.isTerminal, false);
      expect(ComplaintStatus.resolved.isTerminal, false);
    });

    test('canBeCancelled returns true for cancellable states', () {
      expect(ComplaintStatus.pending.canBeCancelled, true);
      expect(ComplaintStatus.accepted.canBeCancelled, true);
      expect(ComplaintStatus.assigned.canBeCancelled, false);
      expect(ComplaintStatus.inProgress.canBeCancelled, false);
    });
  });

  group('ComplaintPriority Extension', () {
    test('label returns correct labels', () {
      expect(ComplaintPriority.low.label, 'LOW');
      expect(ComplaintPriority.medium.label, 'MEDIUM');
      expect(ComplaintPriority.high.label, 'HIGH');
      expect(ComplaintPriority.urgent.label, 'URGENT');
    });

    test('sortOrder returns correct order', () {
      expect(ComplaintPriority.urgent.sortOrder, 0);
      expect(ComplaintPriority.high.sortOrder, 1);
      expect(ComplaintPriority.medium.sortOrder, 2);
      expect(ComplaintPriority.low.sortOrder, 3);
    });
  });

  group('Parse Functions', () {
    test('parseComplaintStatus parses valid status', () {
      expect(parseComplaintStatus('pending'), ComplaintStatus.pending);
      expect(parseComplaintStatus('accepted'), ComplaintStatus.accepted);
      expect(parseComplaintStatus('inProgress'), ComplaintStatus.inProgress);
    });

    test('parseComplaintStatus returns pending for invalid status', () {
      expect(parseComplaintStatus('invalid'), ComplaintStatus.pending);
    });

    test('parseComplaintPriority parses valid priority', () {
      expect(parseComplaintPriority('low'), ComplaintPriority.low);
      expect(parseComplaintPriority('medium'), ComplaintPriority.medium);
      expect(parseComplaintPriority('high'), ComplaintPriority.high);
      expect(parseComplaintPriority('urgent'), ComplaintPriority.urgent);
    });

    test('parseComplaintPriority returns medium for invalid priority', () {
      expect(parseComplaintPriority('invalid'), ComplaintPriority.medium);
    });

    test('complaintPriorityFromIndex returns correct priority', () {
      expect(complaintPriorityFromIndex(0), ComplaintPriority.low);
      expect(complaintPriorityFromIndex(1), ComplaintPriority.medium);
      expect(complaintPriorityFromIndex(2), ComplaintPriority.high);
      expect(complaintPriorityFromIndex(3), ComplaintPriority.urgent);
    });

    test('complaintPriorityFromIndex returns medium for invalid index', () {
      expect(complaintPriorityFromIndex(-1), ComplaintPriority.medium);
      expect(complaintPriorityFromIndex(10), ComplaintPriority.medium);
    });
  });
}
