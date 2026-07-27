import 'package:flutter/foundation.dart';
import '../../data/api/dashboard_api_service.dart';
import '../../data/models/dashboard_dto.dart';

class DashboardNotifier extends ChangeNotifier {
  final DashboardApiService _apiService = DashboardApiService();

  DashboardModel? _dashboard;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardModel? get dashboard => _dashboard;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getDashboardMetrics();
      _dashboard = DashboardModel.fromJson(response['data']);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

final dashboardNotifier = DashboardNotifier();
