import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication service for handling user authentication with Supabase
/// Provides signup, signin, signout, session management, and caching
class AuthService {
  static AuthService? _instance;
  static AuthService get instance {
    _instance ??= AuthService._internal();
    return _instance!;
  }

  AuthService._internal();

  final SupabaseClient _client = Supabase.instance.client;

  // Session cache keys
  static const String _sessionTokenKey = 'user_session_token';
  static const String _userIdKey = 'cached_user_id';
  static const String _userEmailKey = 'cached_user_email';
  static const String _userNameKey = 'cached_user_name';

  /// Get current authenticated user
  User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get auth state changes stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Initialize session from cache on app start
  Future<bool> initializeFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionToken = prefs.getString(_sessionTokenKey);

      if (sessionToken != null && currentUser != null) {
        // Validate cached session
        final userId = prefs.getString(_userIdKey);
        if (userId == currentUser!.id) {
          return true; // Valid cached session
        }
      }

      return false;
    } catch (error) {
      return false;
    }
  }

  /// Cache user session data
  Future<void> _cacheUserSession() async {
    try {
      if (currentUser == null) return;

      final prefs = await SharedPreferences.getInstance();
      final session = _client.auth.currentSession;

      if (session != null) {
        await prefs.setString(_sessionTokenKey, session.accessToken);
        await prefs.setString(_userIdKey, currentUser!.id);
        await prefs.setString(_userEmailKey, currentUser!.email ?? '');

        // Get user profile for full name
        final profile = await getUserProfile();
        if (profile != null && profile['full_name'] != null) {
          await prefs.setString(_userNameKey, profile['full_name']);
        }
      }
    } catch (error) {
      // Silently fail cache operation
    }
  }

  /// Clear cached session data
  Future<void> _clearCachedSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionTokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_userEmailKey);
      await prefs.remove(_userNameKey);
    } catch (error) {
      // Silently fail cache clear
    }
  }

  /// Get cached user info
  Future<Map<String, String?>> getCachedUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'userId': prefs.getString(_userIdKey),
        'email': prefs.getString(_userEmailKey),
        'name': prefs.getString(_userNameKey),
      };
    } catch (error) {
      return {};
    }
  }

  /// Sign up new user with email and password
  /// Returns AuthResponse with user and session data
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );

      if (response.user == null) {
        throw AuthException('Sign up failed - no user returned');
      }

      // Cache session after successful signup
      await _cacheUserSession();

      return response;
    } on AuthException {
      rethrow;
    } catch (error) {
      throw AuthException('Sign up failed: $error');
    }
  }

  /// Sign in existing user with email and password
  /// Returns AuthResponse with user and session data
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthException('Sign in failed - no user returned');
      }

      // Cache session after successful login
      await _cacheUserSession();

      return response;
    } on AuthException {
      rethrow;
    } catch (error) {
      throw AuthException('Sign in failed: $error');
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      // Clear cached session on signout
      await _clearCachedSession();
    } catch (error) {
      throw AuthException('Sign out failed: $error');
    }
  }

  /// Get user profile data from user_profiles table
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (currentUser == null) return null;

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch user profile: $error');
    }
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      if (currentUser == null) {
        throw AuthException('No authenticated user');
      }

      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      if (updates.isEmpty) return;

      await _client
          .from('user_profiles')
          .update(updates)
          .eq('id', currentUser!.id);

      // Update cached session with new data
      await _cacheUserSession();
    } catch (error) {
      throw Exception('Failed to update profile: $error');
    }
  }

  /// Reset password for email
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException {
      rethrow;
    } catch (error) {
      throw AuthException('Password reset failed: $error');
    }
  }

  /// Update user password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException {
      rethrow;
    } catch (error) {
      throw AuthException('Password update failed: $error');
    }
  }
}
