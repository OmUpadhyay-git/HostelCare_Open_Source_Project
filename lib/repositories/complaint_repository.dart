import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/complaint.dart';
import '../models/complaint_category.dart';
import '../models/complaint_history.dart';
import '../models/complaint_image.dart';
import '../models/student.dart';
import '../core/errors/app_error.dart';

class ComplaintRepository {
  final SupabaseClient _client;

  ComplaintRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Get current authenticated user's ID
  String? get _userId => _client.auth.currentUser?.id;

  /// Get student record for current user
  Future<Student?> getStudentRecord() async {
    try {
      final response = await _client
          .from('students')
          .select()
          .eq('profile_id', _userId!)
          .maybeSingle();

      if (response == null) return null;
      return Student.fromJson(response);
    } catch (e) {
      throw const DatabaseError(message: 'Failed to load student record');
    }
  }

  /// Get all active complaint categories
  Future<List<ComplaintCategory>> getCategories() async {
    try {
      final response = await _client
          .from('complaint_categories')
          .select()
          .eq('is_active', true)
          .order('name');

      return (response as List)
          .map((json) => ComplaintCategory.fromJson(json))
          .toList();
    } catch (e) {
      throw const DatabaseError(message: 'Failed to load complaint categories');
    }
  }

  /// Create a new complaint
  /// The student_id, hostel_id, block_id, floor_id, room_id come from the
  /// authenticated student's database record — NOT from client input.
  Future<Complaint> createComplaint({
    required String categoryId,
    required String title,
    required String description,
    required String priority,
  }) async {
    try {
      // Get the student record to derive trusted IDs
      final student = await getStudentRecord();
      if (student == null) {
        throw const DatabaseError(
            message: 'Student record not found. Please contact administrator.');
      }

      final response = await _client.from('complaints').insert({
        'student_id': student.id,
        'category_id': categoryId,
        'hostel_id': student.hostelId,
        'block_id': student.blockId,
        'floor_id': student.floorId,
        'room_id': student.roomId,
        'title': title,
        'description': description,
        'priority': priority,
        'status': 'pending',
      }).select('''
            *,
            complaint_categories!complaints_category_id_fkey(name),
            students!complaints_student_id_fkey(student_id, profiles!students_profile_id_fkey(full_name))
          ''').single();

      return Complaint.fromJson({
        ...response,
        'category_name': response['complaint_categories']?['name'],
        'student_identifier': response['students']?['student_id'],
        'student_name': response['students']?['profiles']?['full_name'],
      });
    } catch (e) {
      if (e is DatabaseError) rethrow;
      throw const DatabaseError(message: 'Failed to create complaint');
    }
  }

  /// Get complaints for the current student
  /// Supports pagination and filtering
  Future<List<Complaint>> getMyComplaints({
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
            students!complaints_student_id_fkey(student_id, profiles!students_profile_id_fkey(full_name))
          ''');

      // RLS automatically filters to current student's complaints
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
          .createSignedUrl(storagePath, 3600); // 1 hour expiry

      return response;
    } catch (e) {
      throw const StorageError(message: 'Failed to load image');
    }
  }

  /// Upload complaint image
  Future<ComplaintImage> uploadComplaintImage({
    required String complaintId,
    required String filePath,
    required String imageType,
  }) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${filePath.split('/').last}';
      final storagePath = '$complaintId/$imageType/$fileName';

      await _client.storage.from('complaint-images').upload(
            storagePath,
            filePath,
            fileOptions: const FileOptions(
              upsert: true,
            ),
          );

      final response = await _client.from('complaint_images').insert({
        'complaint_id': complaintId,
        'storage_path': storagePath,
        'uploaded_by': _userId,
        'image_type': imageType,
      }).select().single();

      return ComplaintImage.fromJson(response);
    } catch (e) {
      throw const StorageError(message: 'Failed to upload image');
    }
  }

  /// Verify a resolved complaint (student confirms fix)
  Future<void> verifyComplaint(String complaintId, {required bool verified}) async {
    try {
      // The database function handles status transition validation
      final response = await _client.rpc('verify_complaint', params: {
        'p_complaint_id': complaintId,
        'p_verified': verified,
      });

      if (response != null && response['error'] != null) {
        throw DatabaseError(message: response['error']);
      }
    } catch (e) {
      if (e is DatabaseError) rethrow;
      throw const DatabaseError(message: 'Failed to verify complaint');
    }
  }

  /// Reopen a resolved complaint
  Future<void> reopenComplaint(String complaintId, String reason) async {
    try {
      final response = await _client.rpc('reopen_complaint', params: {
        'p_complaint_id': complaintId,
        'p_reason': reason,
      });

      if (response != null && response['error'] != null) {
        throw DatabaseError(message: response['error']);
      }
    } catch (e) {
      if (e is DatabaseError) rethrow;
      throw const DatabaseError(message: 'Failed to reopen complaint');
    }
  }

  /// Cancel a complaint
  Future<void> cancelComplaint(String complaintId) async {
    try {
      final response = await _client.rpc('cancel_complaint', params: {
        'p_complaint_id': complaintId,
      });

      if (response != null && response['error'] != null) {
        throw DatabaseError(message: response['error']);
      }
    } catch (e) {
      if (e is DatabaseError) rethrow;
      throw const DatabaseError(message: 'Failed to cancel complaint');
    }
  }

  /// Get complaint count by status for the current student
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
}
