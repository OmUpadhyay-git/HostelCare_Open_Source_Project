import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../repositories/auth_repository.dart';

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Current Supabase user provider
final currentUserProvider = Provider<User?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.currentUser;
});

/// Auth state enum
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  authenticating,
  error,
}

/// Auth state
class AuthState {
  final AuthStatus status;
  final Profile? profile;
  final String? error;
  final bool isLoading;

  const AuthState({
    this.status = AuthStatus.initial,
    this.profile,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    Profile? profile,
    String? error,
    bool? isLoading,
  }) {
    return AuthState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isAuthenticating => status == AuthStatus.authenticating;
}

/// Auth state notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<dynamic>? _authSubscription;

  AuthNotifier(this._authRepository) : super(const AuthState()) {
    _init();
  }

  /// Initialize - check for existing session and subscribe to auth changes
  Future<void> _init() async {
    final user = _authRepository.currentUser;
    if (user != null) {
      await _loadProfile(user.id);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }

    // Subscribe to auth state changes for session refresh/sign-out
    _authSubscription = _authRepository.authStateChanges.listen((authState) {
      final event = authState.event;
      final session = authState.session;

      switch (event) {
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.tokenRefreshed:
          if (session?.user != null) {
            _loadProfile(session!.user.id);
          }
          break;
        case AuthChangeEvent.signedOut:
          state = const AuthState(status: AuthStatus.unauthenticated);
          break;
        default:
          break;
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      isLoading: true,
      error: null,
    );

    try {
      final response = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _loadProfile(response.user!.id);
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          error: 'Authentication failed',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString().replaceAll('Exception: ', ''),
        isLoading: false,
      );
    }
  }

  /// Sign out
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.signOut();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString().replaceAll('Exception: ', ''),
        isLoading: false,
      );
    }
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authRepository.resetPassword(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
        isLoading: false,
      );
      rethrow;
    }
  }

  /// Load user profile
  Future<void> _loadProfile(String userId) async {
    try {
      final profile = await _authRepository.getProfile(userId);

      if (profile == null) {
        state = state.copyWith(
          status: AuthStatus.error,
          error: 'Profile not found. Please contact administrator.',
          isLoading: false,
        );
        return;
      }

      if (!profile.isActive) {
        state = state.copyWith(
          status: AuthStatus.error,
          error: 'Your account is currently inactive. Please contact the hostel administrator.',
          isLoading: false,
        );
        await _authRepository.signOut();
        return;
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        profile: profile,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Failed to load profile. Please try again.',
        isLoading: false,
      );
    }
  }

}

/// Auth state provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepository);
});

/// Profile provider (convenience access)
final profileProvider = Provider<Profile?>((ref) {
  return ref.watch(authProvider).profile;
});

/// User role provider (convenience access)
final userRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(profileProvider)?.role;
});
