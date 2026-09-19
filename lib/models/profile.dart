import 'package:flutter/material.dart';

enum UserRole { student, warden, staff, admin }

extension UserRoleExtension on UserRole {
  String get label {
    return switch (this) {
      UserRole.student => 'Student',
      UserRole.warden => 'Warden',
      UserRole.staff => 'Staff',
      UserRole.admin => 'Admin',
    };
  }

  String get routePrefix {
    return switch (this) {
      UserRole.student => '/student',
      UserRole.warden => '/warden',
      UserRole.staff => '/staff',
      UserRole.admin => '/admin',
    };
  }

  IconData get icon {
    return switch (this) {
      UserRole.student => Icons.school_outlined,
      UserRole.warden => Icons.admin_panel_settings_outlined,
      UserRole.staff => Icons.build_outlined,
      UserRole.admin => Icons.settings_outlined,
    };
  }

  static UserRole? fromString(String value) {
    try {
      return UserRole.values.firstWhere(
        (role) => role.name == value,
      );
    } catch (_) {
      return null;
    }
  }
}

class Profile {
  final String id;
  final String fullName;
  final String? email;
  final String? phone;
  final UserRole role;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    required this.fullName,
    this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    final role = UserRoleExtension.fromString(json['role'] as String);
    if (role == null) {
      throw ArgumentError('Invalid role: ${json['role']}');
    }

    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      role: role,
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'role': role.name,
      'avatar_url': avatarUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Profile copyWith({
    String? fullName,
    String? phone,
    String? avatarUrl,
    bool? isActive,
  }) {
    return Profile(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      role: role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
