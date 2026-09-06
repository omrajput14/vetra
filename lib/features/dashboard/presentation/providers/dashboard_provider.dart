import 'package:flutter/foundation.dart';
import '../../data/api/dashboard_api_service.dart';
import '../../data/models/dashboard_dto.dart';
import '../../data/models/economic_impact_dto.dart';

class DashboardNotifier extends ChangeNotifier {
  final DashboardApiService _apiService = DashboardApiService();

  DashboardModel? _dashboard;
  EconomicImpactModel? _economicImpact;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardModel? get dashboard => _dashboard;
  EconomicImpactModel? get economicImpact => _economicImpact;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.getDashboardMetrics(),
        _fetchEconomicImpactSafe(),
      ]);
      final dashResp = results[0];
      if (dashResp != null && dashResp['data'] != null) {
        _dashboard = DashboardModel.fromJson(dashResp['data']);
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> _fetchEconomicImpactSafe() async {
    try {
      final res = await _apiService.getEconomicImpact();
      if (res['data'] != null && res['data'] is Map<String, dynamic>) {
        _economicImpact = EconomicImpactModel.fromJson(res['data'] as Map<String, dynamic>);
      }
      return res;
    } catch (_) {
      // Keep cached or default unavailable state
      return null;
    }
  }
}

final dashboardNotifier = DashboardNotifier();
