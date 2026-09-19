import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student.dart';
import '../models/profile.dart';
import '../models/location.dart';
import '../core/errors/app_error.dart';

class StudentRepository {
  final SupabaseClient _client;

  StudentRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  /// Get student record with joined hostel/block/floor/room data
  Future<StudentRecord?> getStudentRecord() async {
    try {
      final response = await _client
          .from('students')
          .select('''
            *,
            profiles!students_profile_id_fkey(
              id, full_name, email, phone, role, avatar_url, is_active, created_at, updated_at
            ),
            hostels!students_hostel_id_fkey(name, code),
            blocks!students_block_id_fkey(name, code),
            floors!students_floor_id_fkey(name, floor_number),
            rooms!students_room_id_fkey(room_number, capacity)
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
      final block = Block.fromJson({
        ...response['blocks'] as Map<String, dynamic>,
        'id': response['block_id'],
        'hostel_id': response['hostel_id'],
        'total_floors': 0,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      final floor = Floor.fromJson({
        ...response['floors'] as Map<String, dynamic>,
        'id': response['floor_id'],
        'block_id': response['block_id'],
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      final room = Room.fromJson({
        ...response['rooms'] as Map<String, dynamic>,
        'id': response['room_id'],
        'floor_id': response['floor_id'],
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      final student = Student.fromJson(response);

      return StudentRecord(
        student: student,
        profile: profile,
        hostel: hostel,
        block: block,
        floor: floor,
        room: room,
      );
    } catch (e) {
      throw const DatabaseError(message: 'Failed to load student information');
    }
  }
}

/// Combined student record with all related data
class StudentRecord {
  final Student student;
  final Profile profile;
  final Hostel hostel;
  final Block block;
  final Floor floor;
  final Room room;

  const StudentRecord({
    required this.student,
    required this.profile,
    required this.hostel,
    required this.block,
    required this.floor,
    required this.room,
  });

  String get displayName => profile.fullName;
  String get studentIdentifier => student.studentId;
  String get hostelDisplay => hostel.name;
  String get blockDisplay => block.name;
  String get floorDisplay => floor.name ?? 'Floor ${floor.floorNumber}';
  String get roomDisplay => 'Room ${room.roomNumber}';
  String get locationDisplay => '$hostelDisplay, $blockDisplay, $floorDisplay, $roomDisplay';
}
