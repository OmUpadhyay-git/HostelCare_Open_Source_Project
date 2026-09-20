import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/warden.dart';
import '../models/complaint.dart';
import '../models/complaint_history.dart';
import '../models/complaint_image.dart';
import '../models/staff.dart';
import '../models/profile.dart';
import '../models/location.dart';
import '../core/errors/app_error.dart';

class WardenRepository {
  final SupabaseClient _client;

  WardenRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Get warden record with joined hostel data
  Future<WardenRecord?> getWardenRecord() async {
    try {
      final response = await _client
          .from('wardens')
          .select('''
            *,
            profiles!wardens_profile_id_fkey(
              id, full_name, email, phone, role, avatar_url, is_active, created_at, updated_at
            ),
            hostels!wardens_hostel_id_fkey(name, code)
          ''')
          .eq('profile_id', _userId!)
          .maybeSingle();

      if (response == null) return null;

      final profile = Profile.fromJson(response['profiles'] as Map<String, dynamic>);
      final hostel = Hostel.fromJson({
        ...response['hostels'] as Map<String, dynamic>,
        'id': response['hostel_id'],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      final warden = Warden.fromJson(response);

      return WardenRecord(
        warden: warden,
        profile: profile,
        hostel: hostel,
      );
    } catch (e) {
      throw const DatabaseError(message: 'Failed to load warden information');
    }
  }

  /// Get complaint counts by status for the warden's hostel
  /// RLS automatically scopes to the warden's hostel
  Future<Map<String, int>> getComplaintCounts() async {
    try {
      final response = await _client
          .from('complaints')
          .select('status')
          .order('created_at', ascending: false);

      final counts = <String, int>{};
      for (final row in response) {
        final status = row['status'] as String;
        counts[status] = (counts[status] ?? 0) + 1;
      }
      return counts;
    } catch (e) {
      throw const DatabaseError(message: 'Failed to load complaint counts');
    }
  }

  /// Get complaints for the warden's hostel with filtering and pagination
  /// RLS automatically filters to the warden's authorized hostel
  Future<List<Complaint>> getComplaints({
    int limit = 20,
    int offset = 0,
    String? status,
    String? categoryId,
    String? priority,
    String? search,
  }) async {
    try {
      var query = _client
          .from('complaints')
          .select('''
            *,
            complaint_categories!complaints_category_id_fkey(name),
            students!complaints_student_id_fkey(
              student_id,
              profiles!students_profile_id_fkey(full_name)
            ),
            wardens!complaints_assigned_warden_id_fkey(
              profiles!wardens_profile_id_fkey(full_name)
            ),
            staff!complaints_assigned_staff_id_fkey(
              profiles!staff_profile_id_fkey(full_name)
            )
          ''');

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }
      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }
      if (priority != null && priority.isNotEmpty) {
        query = query.eq('priority', priority);
      }
      if (search != null && search.isNotEmpty) {
        query = query.or('title.ilike.%$search%,complaint_number.ilike.%$search%');
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((json) {
        return Complaint.fromJson({
          ...json,
          'category_name': json['complaint_categories']?['name'],
          'student_identifier': json['students']?['student_id'],
          'student_name': json['students']?['profiles']?['full_name'],
          'warden_name': json['wardens']?['profiles']?['full_name'],
          'staff_name': json['staff']?['profiles']?['full_name'],
        });
      }).toList();
    } catch (e) {
      throw const DatabaseError(message: 'Failed to load complaints');
    }
  }

  /// Get a single complaint by ID with full details
  Future<Complaint?> getComplaintById(String complaintId) async {
    try {
      final response = await _client
          .from('complaints')
          .select('''
            *,
            complaint_categories!complaints_category_id_fkey(name, sla_hours),
            students!complaints_student_id_fkey(
              student_id,
              profiles!students_profile_id_fkey(full_name, email, phone),
              hostels!students_hostel_id_fkey(name),
              blocks!students_block_id_fkey(name),
              floors!students_floor_id_fkey(name, floor_number),
              rooms!students_room_id_fkey(room_number)
            ),
            wardens!complaints_assigned_warden_id_fkey(
              profiles!wardens_profile_id_fkey(full_name)
            ),
            staff!complaints_assigned_staff_id_fkey(
              profiles!staff_profile_id_fkey(full_name)
            )
          ''')
          .eq('id', complaintId)
          .maybeSingle();

      if (response == null) return null;

      return Complaint.fromJson({
        ...response,
        'category_name': response['complaint_categories']?['name'],
        'student_identifier': response['students']?['student_id'],
        'student_name': response['students']?['profiles']?['full_name'],
        'hostel_name': response['students']?['hostels']?['name'],
        'block_name': response['students']?['blocks']?['name'],
        'floor_name': response['students']?['floors']?['name'],
        'room_number': response['students']?['rooms']?['room_number'],
        'warden_name': response['wardens']?['profiles']?['full_name'],
        'staff_name': response['staff']?['profiles']?['full_name'],
      });
    } catch (e) {
      throw const DatabaseError(message: 'Failed to load complaint details');
    }
  }

  /// Get complaint history/timeline
  Future<List<ComplaintHistory>> getComplaintHistory(String complaintId) async {
    try {
      final response = await _client
          .from('complaint_history')
          .select('''
            *,
            profiles!complaint_history_changed_by_fkey(full_name, role)
          ''')
          .eq('complaint_id', complaintId)
          .order('created_at', ascending: true);

      return (response as List).map((json) {
        return ComplaintHistory.fromJson({
          ...json,
          'changed_by_name': json['profiles']?['full_name'],
          'changed_by_role': json['profiles']?['role'],
        });
      }).toList();
    } catch (e) {
      throw const DatabaseError(message: 'Failed to load complaint history');
    }
  }

  /// Get complaint images
  Future<List<ComplaintImage>> getComplaintImages(String complaintId) async {
    try {
      final response = await _client
          .from('complaint_images')
          .select()
          .eq('complaint_id', complaintId)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => ComplaintImage.fromJson(json))
          .toList();
    } catch (e) {
      throw const DatabaseError(message: 'Failed to load complaint images');
    }
  }

  /// Get signed URL for a private storage object
  Future<String> getSignedUrl(String storagePath) async {
    try {
      final response = await _client.storage
          .from('complaint-images')
          .createSignedUrl(storagePath, 3600);

      return response;
    } catch (e) {
      throw const StorageError(message: 'Failed to load image');
    }
  }

  /// Get available staff for the warden's hostel
  Future<List<StaffMember>> getAvailableStaff() async {
    try {
      final response = await _client
          .from('staff')
          .select('''
            *,
            profiles!staff_profile_id_fkey(full_name, email)
          ''')
          .eq('is_active', true)
          .order('created_at', ascending: true);

      return (response as List).map((json) {
        return StaffMember.fromJson({
          ...json,
          'full_name': json['profiles']?['full_name'],
          'email': json['profiles']?['email'],
        });
      }).toList();
    } catch (e) {
      throw const DatabaseError(message: 'Failed to load available staff');
    }
  }

  /// Accept a pending complaint (via RPC)
  Future<void> acceptComplaint(String complaintId) async {
    try {
      final response = await _client.rpc('accept_complaint', params: {
        'p_complaint_id': complaintId,
      });

      if (response != null && response is Map && response['error'] != null) {
        throw DatabaseError(message: response['error']);
      }
    } catch (e) {
      if (e is DatabaseError) rethrow;
      throw const DatabaseError(message: 'Failed to accept complaint');
    }
  }

  /// Reject a pending complaint with reason (via RPC)
  Future<void> rejectComplaint(String complaintId, String reason) async {
    try {
      final response = await _client.rpc('reject_complaint', params: {
        'p_complaint_id': complaintId,
        'p_reason': reason,
      });

      if (response != null && response is Map && response['error'] != null) {
        throw DatabaseError(message: response['error']);
      }
    } catch (e) {
      if (e is DatabaseError) rethrow;
      throw const DatabaseError(message: 'Failed to reject complaint');
    }
  }

  /// Assign staff to an accepted complaint (via RPC)
  Future<void> assignComplaint(String complaintId, String staffId) async {
    try {
      final response = await _client.rpc('assign_complaint', params: {
        'p_complaint_id': complaintId,
        'p_staff_id': staffId,
      });

      if (response != null && response is Map && response['error'] != null) {
        throw DatabaseError(message: response['error']);
      }
    } catch (e) {
      if (e is DatabaseError) rethrow;
      throw const DatabaseError(message: 'Failed to assign staff');
    }
  }
}
