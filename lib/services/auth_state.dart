import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

/// Global auth state — single source of truth for user role.
///
/// USAGE:
///   await AuthState.instance.loadProfile();  // call after login/session restore
///   AuthState.instance.isOwner               // true if turf_owner with turf_owner object
///   AuthState.instance.role                  // "turf_owner", "user", etc.
///
/// RULES:
///   - loadProfile() must be awaited BEFORE navigating to home screen
///   - On logout, call clear()
///   - Never check SharedPreferences 'isPartner' directly — use this instead
class AuthState {
  // ─── SINGLETON ───
  static final AuthState _instance = AuthState._internal();
  static AuthState get instance => _instance;
  AuthState._internal();

  final ApiService _api = ApiService();

  // ─── STATE ───
  String _role = 'user';
  bool _isOwner = false;
  Map<String, dynamic>? _turfOwner;
  Map<String, dynamic>? _userProfile;
  bool _isLoaded = false;

  // ─── GETTERS ───
  String get role => _role;
  bool get isOwner => _isOwner;
  Map<String, dynamic>? get turfOwner => _turfOwner;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoaded => _isLoaded;

  /// Load user profile from backend.
  /// MUST be called after login and after session restore.
  /// Handles 401 (expired JWT) gracefully.
  Future<void> loadProfile() async {
    print('🔐 AuthState.loadProfile() CALLED');

    try {
      final response = await _api.getAuth('/api/users/user-profile/me/');

      if (response != null && response['success'] == true) {
        final user = response['user'];
        _userProfile = user;
        _role = user['role']?.toString() ?? 'user';
        _turfOwner = user['turf_owner'];
        _isOwner = _role == 'turf_owner' && _turfOwner != null;
        _isLoaded = true;

        print(
          '🔐 AuthState: role=$_role, isOwner=$_isOwner, '
          'turfOwner=${_turfOwner != null ? "present" : "null"}',
        );

        // Sync to SharedPreferences for offline/fast reads
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userRole', _role);
        await prefs.setBool('isPartner', _isOwner);

        // Sync first_booking_completed flag
        if (user['first_booking_completed'] != null) {
          await prefs.setBool(
            'first_booking_completed',
            user['first_booking_completed'] == true,
          );
        }

        // Also update user info if available
        if (user['first_name'] != null) {
          await prefs.setString(
            'userName',
            user['first_name'] ?? user['username'] ?? 'User',
          );
        }
        if (user['email'] != null) {
          await prefs.setString('userEmail', user['email']);
        }
      }
    } on AuthExpiredException {
      print('🔐 AuthState: JWT expired — clearing state');
      await clear();
      rethrow; // Let caller handle navigation to login
    } catch (e) {
      print('🔐 AuthState: loadProfile error: $e');
      // On network error, try to restore from SharedPreferences
      await _restoreFromPrefs();
    }
  }

  /// Restore role from SharedPreferences (offline fallback).
  Future<void> _restoreFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _role = prefs.getString('userRole') ?? 'user';
    _isOwner = prefs.getBool('isPartner') ?? false;
    _isLoaded = true;
    print('🔐 AuthState: restored from prefs — role=$_role, isOwner=$_isOwner');
  }

  /// Clear all auth state. Call on logout.
  Future<void> clear() async {
    _role = 'user';
    _isOwner = false;
    _turfOwner = null;
    _userProfile = null;
    _isLoaded = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isPartner');
    await prefs.remove('userRole');
    print('🔐 AuthState: cleared');
  }
}
