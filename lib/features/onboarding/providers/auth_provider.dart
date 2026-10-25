import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../../../core/storage/hive_service.dart';
import '../../../core/services/supabase_service.dart';
import '../domain/entities/user_profile.dart';
import '../data/repositories/auth_repository_impl.dart';

part 'auth_provider.g.dart';

/// Authentication state model.
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final UserProfile? profile;
  
  // Temporary storage during onboarding flow
  final List<String> selectedRoles;
  final String selectedLanguage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.profile,
    this.selectedRoles = const [],
    this.selectedLanguage = 'English',
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    UserProfile? profile,
    List<String>? selectedRoles,
    String? selectedLanguage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Can be null, copyWith should probably allow clearing it, but we can just use another approach or rely on creating a new state.
      profile: profile ?? this.profile,
      selectedRoles: selectedRoles ?? this.selectedRoles,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
    );
  }

  AuthState clearError() {
    return AuthState(
      isAuthenticated: isAuthenticated,
      isLoading: isLoading,
      error: null,
      profile: profile,
      selectedRoles: selectedRoles,
      selectedLanguage: selectedLanguage,
    );
  }
}

/// Manages authentication lifecycle and user session persistence.
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  late final HiveService _hive;

  @override
  AuthState build() {
    _hive = ref.read(hiveServiceProvider);
    
    // Check initial Hive state for onboarding preferences
    final initialState = AuthState(
      selectedRoles: _hive.roles,
      selectedLanguage: _hive.selectedLanguage ?? 'English',
    );

    // Setup listener for Supabase auth changes
    _setupAuthListener();

    return initialState;
  }

  void _setupAuthListener() {
    final client = ref.read(supabaseServiceProvider).client;
    
    final sub = client.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        // Fetch profile
        await _fetchProfile(session.user.id);
      } else if (event == AuthChangeEvent.signedOut) {
        state = AuthState(
          selectedRoles: state.selectedRoles,
          selectedLanguage: state.selectedLanguage,
        );
      }
    });
    ref.onDispose(sub.cancel);

    // Check initial session
    final session = client.auth.currentSession;
    if (session != null) {
      _fetchProfile(session.user.id);
    }
  }

  Future<void> _fetchProfile(String userId) async {
    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.getProfile(userId);
    
    result.when(
      success: (profile) {
        if (profile != null) {
          state = state.copyWith(
            isAuthenticated: true,
            profile: profile,
          );
        } else {
          // New user: OTP verified but registration not completed yet.
          state = state.copyWith(isAuthenticated: false);
        }
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
      },
    );
  }

  void setLanguage(String lang) {
    state = state.copyWith(selectedLanguage: lang);
  }

  void toggleRole(String role) {
    final roles = List<String>.from(state.selectedRoles);
    roles.contains(role) ? roles.remove(role) : roles.add(role);
    state = state.copyWith(selectedRoles: roles);
  }

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    
    final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';
    
    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.sendOtp(formattedPhone);

    result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
      },
      failure: (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
    );
  }

  /// Verifies the OTP. Returns `true` when the user still has to complete
  /// registration (no profile yet); `false` when verification failed or an
  /// existing profile was loaded (the router then sends the user home).
  Future<bool> verifyOtp(String phone, String otp) async {
    state = state.copyWith(isLoading: true, error: null);

    final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.verifyOtp(formattedPhone, otp);

    if (result.isFailure) {
      state = state.copyWith(isLoading: false, error: result.error.message);
      return false;
    }

    final user = ref.read(supabaseServiceProvider).client.auth.currentUser;
    if (user == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Authentication failed. Please try again.',
      );
      return false;
    }

    // Existing users must skip registration; inserting a second profile
    // would fail with a duplicate key.
    final profileResult = await authRepo.getProfile(user.id);
    return profileResult.when(
      success: (profile) {
        if (profile != null) {
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            profile: profile,
          );
          return false;
        }
        state = state.copyWith(isLoading: false);
        return true;
      },
      failure: (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
    );
  }

  Future<bool> completeLogin({
    required String name,
    required String phone,
    required String pincode,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final client = ref.read(supabaseServiceProvider).client;
    final user = client.auth.currentUser;
    
    if (user == null) {
      state = state.copyWith(
        isLoading: false, 
        error: 'Authentication failed. Please verify OTP first.'
      );
      return false;
    }

    final authRepo = ref.read(authRepositoryProvider);
    final result = await authRepo.createProfile(
      id: user.id,
      name: name,
      phone: phone,
      pincode: pincode,
      roles: state.selectedRoles,
    );

    return result.when(
      success: (profile) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          profile: profile,
        );
        _hive.saveSession(
          name: name,
          phone: phone,
          pincode: pincode,
          roles: state.selectedRoles,
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
    );
  }

  Future<void> logout() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.logout();
    await _hive.clearSession();
    state = const AuthState();
  }
}
