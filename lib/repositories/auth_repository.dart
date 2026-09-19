import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../core/errors/app_error.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  /// Get current authenticated user
  User? get currentUser => _client.auth.currentUser;

  /// Get current session
  Session? get currentSession => _client.auth.currentSession;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw _mapAuthError(e);
    } catch (e) {
      throw const UnknownError();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw const UnknownError();
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _mapAuthError(e);
    } catch (e) {
      throw const UnknownError();
    }
  }

  /// Update password (after reset)
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw _mapAuthError(e);
    } catch (e) {
      throw const UnknownError();
    }
  }

  /// Get user profile from database
  Future<Profile?> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return Profile.fromJson(response);
    } catch (e) {
      throw const DatabaseError();
    }
  }

  /// Map Supabase auth errors to AppError
  AppError _mapAuthError(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid email or password')) {
      return const AuthError(message: 'Invalid email or password');
    }

    if (message.contains('email not confirmed')) {
      return const AuthError(message: 'Please verify your email address');
    }

    if (message.contains('user not found')) {
      return const AuthError(message: 'Invalid email or password');
    }

    if (message.contains('password')) {
      return const AuthError(message: 'Invalid email or password');
    }

    if (message.contains('too many requests')) {
      return const AuthError(message: 'Too many attempts. Please try again later');
    }

    return AuthError(message: e.message);
  }
}
