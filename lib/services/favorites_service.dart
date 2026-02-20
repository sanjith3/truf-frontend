import '../services/api_service.dart';
import '../models/turf.dart';

class FavoritesService {
  final ApiService _api = ApiService();

  /// Toggle favorite status for a turf. Returns the new is_favorite state.
  Future<bool> toggleFavorite(int turfId) async {
    final response = await _api.postAuth(
      '/api/users/user-profile/favorites/toggle/',
      body: {'turf_id': turfId},
    );
    return response['is_favorite'] ?? false;
  }

  /// Get all favorited turfs for the current user.
  Future<List<Turf>> getFavorites() async {
    final response = await _api.getAuth('/api/users/user-profile/favorites/');
    if (response['results'] != null) {
      return (response['results'] as List)
          .map((json) => Turf.fromJson(json))
          .toList();
    }
    return [];
  }

  /// Bulk check which turf IDs are favorited. Returns map of turfId → bool.
  Future<Map<int, bool>> checkFavorites(List<int> turfIds) async {
    if (turfIds.isEmpty) return {};
    final response = await _api.postAuth(
      '/api/users/user-profile/favorites/check/',
      body: {'turf_ids': turfIds},
    );
    final Map<String, dynamic> favMap = response['favorites'] ?? {};
    return favMap.map((key, value) => MapEntry(int.parse(key), value as bool));
  }
}
