import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hostelcare/models/profile.dart';
import 'package:hostelcare/providers/auth_provider.dart';

void main() {
  group('Profile Model', () {
    test('fromJson creates Profile correctly', () {
      final json = {
        'id': 'test-id',
        'full_name': 'John Doe',
        'email': 'john@example.com',
        'phone': '1234567890',
        'role': 'student',
        'avatar_url': null,
        'is_active': true,
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-01T00:00:00.000Z',
      };

      final profile = Profile.fromJson(json);

      expect(profile.id, 'test-id');
      expect(profile.fullName, 'John Doe');
      expect(profile.email, 'john@example.com');
      expect(profile.role, UserRole.student);
      expect(profile.isActive, true);
    });

    test('fromJson handles missing optional fields', () {
      final json = {
        'id': 'test-id',
        'full_name': 'John Doe',
        'role': 'warden',
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-01T00:00:00.000Z',
      };

      final profile = Profile.fromJson(json);

      expect(profile.email, null);
      expect(profile.phone, null);
      expect(profile.avatarUrl, null);
      expect(profile.isActive, true);
    });

    test('fromJson throws ArgumentError for invalid role', () {
      final json = {
        'id': 'test-id',
        'full_name': 'John Doe',
        'role': 'invalid_role',
        'created_at': '2026-01-01T00:00:00.000Z',
        'updated_at': '2026-01-01T00:00:00.000Z',
      };

      expect(() => Profile.fromJson(json), throwsArgumentError);
    });

    test('toJson converts Profile to JSON correctly', () {
      final profile = Profile(
        id: 'test-id',
        fullName: 'John Doe',
        email: 'john@example.com',
        phone: '1234567890',
        role: UserRole.student,
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final json = profile.toJson();

      expect(json['id'], 'test-id');
      expect(json['full_name'], 'John Doe');
      expect(json['email'], 'john@example.com');
      expect(json['phone'], '1234567890');
      expect(json['role'], 'student');
      expect(json['is_active'], true);
    });

    test('copyWith creates new instance with updated values', () {
      final profile = Profile(
        id: 'test-id',
        fullName: 'John Doe',
        email: 'john@example.com',
        role: UserRole.student,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = profile.copyWith(fullName: 'Jane Doe');

      expect(updated.fullName, 'Jane Doe');
      expect(updated.id, profile.id);
      expect(updated.email, profile.email);
      expect(updated.role, profile.role);
    });

    test('copyWith preserves unchanged values', () {
      final now = DateTime.now();
      final profile = Profile(
        id: 'test-id',
        fullName: 'John Doe',
        email: 'john@example.com',
        phone: '1234567890',
        role: UserRole.staff,
        avatarUrl: 'https://example.com/avatar.jpg',
        isActive: false,
        createdAt: now,
        updatedAt: now,
      );

      final updated = profile.copyWith(fullName: 'Jane Doe');

      expect(updated.id, profile.id);
      expect(updated.email, profile.email);
      expect(updated.phone, profile.phone);
      expect(updated.role, profile.role);
      expect(updated.avatarUrl, profile.avatarUrl);
      expect(updated.isActive, profile.isActive);
      expect(updated.createdAt, profile.createdAt);
    });
  });

  group('UserRoleExtension', () {
    test('label returns correct labels', () {
      expect(UserRole.student.label, 'Student');
      expect(UserRole.warden.label, 'Warden');
      expect(UserRole.staff.label, 'Staff');
      expect(UserRole.admin.label, 'Admin');
    });

    test('routePrefix returns correct routes', () {
      expect(UserRole.student.routePrefix, '/student');
      expect(UserRole.warden.routePrefix, '/warden');
      expect(UserRole.staff.routePrefix, '/staff');
      expect(UserRole.admin.routePrefix, '/admin');
    });

    test('icon returns correct icons', () {
      expect(UserRole.student.icon, Icons.school_outlined);
      expect(UserRole.warden.icon, Icons.admin_panel_settings_outlined);
      expect(UserRole.staff.icon, Icons.build_outlined);
      expect(UserRole.admin.icon, Icons.settings_outlined);
    });

    test('fromString parses roles correctly', () {
      expect(UserRoleExtension.fromString('student'), UserRole.student);
      expect(UserRoleExtension.fromString('warden'), UserRole.warden);
      expect(UserRoleExtension.fromString('staff'), UserRole.staff);
      expect(UserRoleExtension.fromString('admin'), UserRole.admin);
    });

    test('fromString returns null for invalid role', () {
      expect(UserRoleExtension.fromString('invalid'), null);
      expect(UserRoleExtension.fromString(''), null);
    });
  });

  group('AuthState', () {
    test('default state is initial', () {
      const state = AuthState();
      expect(state.status, AuthStatus.initial);
      expect(state.profile, null);
      expect(state.error, null);
      expect(state.isLoading, false);
    });

    test('isAuthenticated returns true when authenticated', () {
      const state = AuthState(status: AuthStatus.authenticated);
      expect(state.isAuthenticated, true);
      expect(state.isUnauthenticated, false);
      expect(state.isAuthenticating, false);
    });

    test('isUnauthenticated returns true when unauthenticated', () {
      const state = AuthState(status: AuthStatus.unauthenticated);
      expect(state.isUnauthenticated, true);
      expect(state.isAuthenticated, false);
    });

    test('isAuthenticating returns true when authenticating', () {
      const state = AuthState(status: AuthStatus.authenticating);
      expect(state.isAuthenticating, true);
      expect(state.isAuthenticated, false);
    });

    test('copyWith creates new state with updated status', () {
      const state = AuthState(status: AuthStatus.initial);
      final updated = state.copyWith(status: AuthStatus.authenticating);

      expect(updated.status, AuthStatus.authenticating);
      expect(updated.isLoading, false);
    });

    test('copyWith creates new state with updated profile', () {
      final profile = Profile(
        id: 'test-id',
        fullName: 'John Doe',
        role: UserRole.student,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      const state = AuthState(status: AuthStatus.authenticated);
      final updated = state.copyWith(profile: profile);

      expect(updated.profile, profile);
      expect(updated.status, AuthStatus.authenticated);
    });

    test('copyWith creates new state with updated error', () {
      const state = AuthState();
      final updated = state.copyWith(
        status: AuthStatus.error,
        error: 'Login failed',
      );

      expect(updated.error, 'Login failed');
      expect(updated.status, AuthStatus.error);
    });

    test('copyWith preserves values when not provided', () {
      final profile = Profile(
        id: 'test-id',
        fullName: 'John Doe',
        role: UserRole.warden,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final state = AuthState(
        status: AuthStatus.authenticated,
        profile: profile,
        isLoading: true,
      );

      final updated = state.copyWith(error: 'New error');

      expect(updated.status, AuthStatus.authenticated);
      expect(updated.profile, profile);
      expect(updated.isLoading, true);
      expect(updated.error, 'New error');
    });

    test('copyWith with null error clears error', () {
      const state = AuthState(error: 'Old error');
      final updated = state.copyWith();

      expect(updated.error, null);
    });
  });

  group('AuthStatus', () {
    test('has all required values', () {
      expect(AuthStatus.values.length, 5);
      expect(AuthStatus.values, contains(AuthStatus.initial));
      expect(AuthStatus.values, contains(AuthStatus.authenticated));
      expect(AuthStatus.values, contains(AuthStatus.unauthenticated));
      expect(AuthStatus.values, contains(AuthStatus.authenticating));
      expect(AuthStatus.values, contains(AuthStatus.error));
    });
  });
}
