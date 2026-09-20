import 'profile.dart';
import 'location.dart';

class Warden {
  final String id;
  final String profileId;
  final String hostelId;
  final List<String> blockIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Warden({
    required this.id,
    required this.profileId,
    required this.hostelId,
    this.blockIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory Warden.fromJson(Map<String, dynamic> json) {
    return Warden(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      hostelId: json['hostel_id'] as String,
      blockIds: json['block_ids'] != null
          ? List<String>.from(json['block_ids'] as List)
          : const [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'hostel_id': hostelId,
      'block_ids': blockIds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class WardenRecord {
  final Warden warden;
  final Profile profile;
  final Hostel hostel;

  const WardenRecord({
    required this.warden,
    required this.profile,
    required this.hostel,
  });

  String get displayName => profile.fullName;
  String get hostelDisplay => hostel.name;
}
