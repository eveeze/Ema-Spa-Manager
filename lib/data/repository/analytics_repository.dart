// lib/data/repository/analytics_repository.dart
import 'package:emababyspa/data/models/analytics.dart';
import 'package:emababyspa/data/providers/analytics_provider.dart';

class AnalyticsRepository {
  final AnalyticsProvider _analyticsProvider;

  AnalyticsRepository({required AnalyticsProvider analyticsProvider})
    : _analyticsProvider = analyticsProvider;

  /// Get dashboard overview data (real-time KPIs).
  Future<AnalyticsOverview> getAnalyticsOverview() async {
    try {
      final Map<String, dynamic> data =
          await _analyticsProvider.getAnalyticsOverview();
      return AnalyticsOverview.fromJson(data);
    } catch (e) {
      // Anda bisa menambahkan logging atau penanganan error yang lebih spesifik di sini
      rethrow;
    }
  }

  /// Get detailed insights data (stats, charts, top performers).
  /// The [days] parameter specifies the time range.
  Future<AnalyticsDetails> getAnalyticsDetails({int? days}) async {
    try {
      final Map<String, dynamic> data = await _analyticsProvider
          .getAnalyticsDetails(days: days);
      return AnalyticsDetails.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
