import '../services/api_service.dart';

/// Service for owner analytics endpoints.
/// All methods use authenticated GET requests and return parsed JSON maps.
class AnalyticsService {
  final ApiService _api = ApiService();

  /// Dashboard summary: today's overview, revenue summary, booking analytics summary.
  Future<Map<String, dynamic>> getDashboardSummary() async {
    final res = await _api.getAuth('/api/bookings/bookings/owner_dashboard/');
    return res as Map<String, dynamic>;
  }

  /// Detailed revenue report with weekly trend and daily breakdown.
  /// [period]: today, week, month, quarter, year
  Future<Map<String, dynamic>> getRevenueReport({
    int? turfId,
    String period = 'week',
  }) async {
    String url = '/api/bookings/bookings/owner_revenue/?period=$period';
    if (turfId != null) url += '&turf_id=$turfId';
    final res = await _api.getAuth(url);
    return res as Map<String, dynamic>;
  }

  /// Detailed booking analytics with daily trend and breakdown.
  /// [period]: today, week, month, quarter, year
  Future<Map<String, dynamic>> getBookingAnalytics({
    int? turfId,
    String period = 'month',
  }) async {
    String url =
        '/api/bookings/bookings/owner_bookings_analytics/?period=$period';
    if (turfId != null) url += '&turf_id=$turfId';
    final res = await _api.getAuth(url);
    return res as Map<String, dynamic>;
  }
}
