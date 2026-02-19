import '../models/turf.dart';
import '../models/booking.dart';
import '../services/api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Turf data service — fetches from Django backend API.
/// No hardcoded turfs. No demo data. Backend is the source of truth.
class TurfDataService extends ChangeNotifier {
  static final TurfDataService _instance = TurfDataService._internal();
  factory TurfDataService() => _instance;

  TurfDataService._internal() {
    print("🚀🚀🚀 TurfDataService CREATED — calling API now");
    _loadTurfsFromApi();
  }

  final ApiService _api = ApiService();

  // ============================================================
  // USER LOCATION — stored for API calls
  // ============================================================
  double? _userLat;
  double? _userLon;

  double? get userLat => _userLat;
  double? get userLon => _userLon;
  bool get hasLocation => _userLat != null && _userLon != null;

  // ============================================================
  // TURF DATA — from API
  // ============================================================
  List<Turf> _turfs = [];
  bool _isLoading = false;
  String? _error;

  List<Turf> get turfs => List.unmodifiable(_turfs);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ============================================================
  // OWNER TURFS — separate from public listing
  // ============================================================
  List<Turf> _myTurfs = [];
  bool _isLoadingMyTurfs = false;

  List<Turf> get myTurfs => List.unmodifiable(_myTurfs);
  bool get isLoadingMyTurfs => _isLoadingMyTurfs;

  /// Load turfs WITH user location → backend returns real distance
  Future<void> loadTurfsWithLocation(double lat, double lon) async {
    _userLat = lat;
    _userLon = lon;
    print("📍 Location set: lat=$lat, lon=$lon");
    await _loadTurfsFromApi();
  }

  /// Load turfs WITHOUT location → distance will be 0.0 (show as --)
  Future<void> loadTurfsWithoutLocation() async {
    _userLat = null;
    _userLon = null;
    await _loadTurfsFromApi();
  }

  /// Fetch turfs from backend API — uses AUTH when token available
  Future<void> _loadTurfsFromApi() async {
    print("🔥🔥🔥 _loadTurfsFromApi CALLED");
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Build query params — include location if available
      Map<String, String>? queryParams;
      if (_userLat != null && _userLon != null) {
        queryParams = {
          'latitude': _userLat.toString(),
          'longitude': _userLon.toString(),
          'radius': '50', // 50 km default radius
        };
        print("📍 Sending location to API: lat=$_userLat, lon=$_userLon");
      }

      // Use authenticated client when logged in — backend includes owner turfs
      dynamic response;
      final hasAuth = await ApiService.hasToken();
      if (hasAuth) {
        print("🔐 Using AUTH client for turf listing");
        response = await _api.getAuth(
          '/api/turfs/turfs/',
          queryParams: queryParams,
        );
      } else {
        response = await _api.get(
          '/api/turfs/turfs/',
          queryParams: queryParams,
        );
      }
      print('🔥🔥🔥 TURF API RESPONSE TYPE: ${response.runtimeType}');

      _turfs = _parseTurfList(response);

      print('🔥🔥🔥 LOADED ${_turfs.length} TURFS FROM API');
      _error = null;
    } catch (e) {
      print('🚨🚨🚨 ERROR LOADING TURFS: $e');
      _error = e.toString();
      _turfs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load ONLY owner's turfs — all statuses, no radius filter
  /// Uses: GET /api/turfs/turfs/?my_turfs=true with JWT auth
  Future<void> loadMyTurfs() async {
    print("🏠 loadMyTurfs CALLED");
    _isLoadingMyTurfs = true;
    notifyListeners();

    try {
      final response = await _api.getAuth(
        '/api/turfs/turfs/',
        queryParams: {'my_turfs': 'true'},
      );
      print("🏠 MY TURFS RESPONSE: ${response.runtimeType}");
      _myTurfs = _parseTurfList(response);
      print("🏠 LOADED ${_myTurfs.length} OWNER TURFS");
    } catch (e) {
      print("🚨 ERROR loading my turfs: $e");
      _myTurfs = [];
    } finally {
      _isLoadingMyTurfs = false;
      notifyListeners();
    }
  }

  /// Parse turf list from API response (handles both paginated and list)
  List<Turf> _parseTurfList(dynamic response) {
    List<dynamic> turfList;
    if (response is Map && response.containsKey('results')) {
      turfList = response['results'] as List;
    } else if (response is List) {
      turfList = response;
    } else {
      turfList = [];
    }
    return turfList.map((json) {
      try {
        return Turf.fromJson(json as Map<String, dynamic>);
      } catch (e) {
        print('🚨🚨🚨 ERROR PARSING TURF JSON: $e\nJSON: $json');
        rethrow;
      }
    }).toList();
  }

  /// Refresh turfs from API (pull-to-refresh)
  Future<void> refreshTurfs() async {
    await _loadTurfsFromApi();
  }

  /// Required by SlotManagementScreen — returns owner turfs if loaded, else all
  Future<List<Turf>> getAllTurfs() async {
    // Prefer owner turfs for management screens
    if (_myTurfs.isNotEmpty) return List.unmodifiable(_myTurfs);
    if (_turfs.isEmpty) {
      await _loadTurfsFromApi();
    }
    return List.unmodifiable(_turfs);
  }

  /// Add turf locally (for partner flow — still saved to prefs until API wired)
  void addTurf(Turf turf) {
    _turfs.insert(0, turf);
    notifyListeners();
  }

  // ============================================================
  // SLOT STORAGE (local — will move to API later)
  // Key: "turfName_YYYY-MM-DD" -> List of slot maps
  // ============================================================
  final Map<String, List<Map<String, dynamic>>> _customSlots = {};

  String _slotKey(String turfName, DateTime date) =>
      "${turfName}_${date.year}-${date.month}-${date.day}";

  /// SAVE single slot (USED BY SlotManagementScreen)
  Future<void> saveSlotData(
    String turfName,
    DateTime date,
    String slotTime,
    Map<String, dynamic> data,
  ) async {
    final key = _slotKey(turfName, date);

    if (!_customSlots.containsKey(key)) {
      _customSlots[key] = [];
    }

    final index = _customSlots[key]!.indexWhere((s) => s['time'] == slotTime);

    if (index != -1) {
      _customSlots[key]![index] = data;
    } else {
      _customSlots[key]!.add(data);
    }

    await _persistCustomSlots();
    notifyListeners();
  }

  /// SAVE full day slots
  Future<void> saveSlots(
    String turfName,
    DateTime date,
    List<Map<String, dynamic>> slots,
  ) async {
    _customSlots[_slotKey(turfName, date)] = slots;
    await _persistCustomSlots();
    notifyListeners();
  }

  /// GET saved slots
  List<Map<String, dynamic>>? getSavedSlots(String turfName, DateTime date) {
    return _customSlots[_slotKey(turfName, date)];
  }

  Future<void> _persistCustomSlots() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_slots_data', jsonEncode(_customSlots));
  }

  Future<void> _loadCustomSlots() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('custom_slots_data');

    if (data != null) {
      try {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        decoded.forEach((key, value) {
          _customSlots[key] = List<Map<String, dynamic>>.from(
            (value as List).map((i) => Map<String, dynamic>.from(i)),
          );
        });
      } catch (e) {
        debugPrint("Error loading custom slots: $e");
      }
    }
  }

  // ============================================================
  // BOOKINGS (local — will move to API later)
  // ============================================================
  final List<Booking> _bookings = [];

  List<Booking> get bookings => List.unmodifiable(_bookings);

  void addBooking(Booking booking) {
    _bookings.insert(0, booking);
    notifyListeners();
  }
}
