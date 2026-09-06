import 'package:flutter/foundation.dart';
import '../../../../core/services/location_service.dart';
import '../../data/models/disease_report_dto.dart';
import '../../data/models/outbreak_dto.dart';
import '../../data/repositories/disease_repository_impl.dart';
import '../../domain/repositories/disease_repository.dart';

class OutbreakNotifier extends ChangeNotifier {
  DiseaseRepository _repository;

  OutbreakNotifier({DiseaseRepository? repository})
      : _repository = repository ?? DiseaseRepositoryImpl();

  void setRepository(DiseaseRepository repository) {
    _repository = repository;
  }

  List<OutbreakModel> _outbreaks = [];
  List<NearbyReportModel> _nearbyReports = [];
  OutbreakStatisticsModel? _statistics;
  bool _isLoading = false;
  String? _errorMessage;

  String _selectedDiseaseFilter = 'All Diseases';
  String _selectedRiskFilter = 'All Risks';
  String _selectedStatusFilter = 'All Statuses';

  OutbreakModel? _selectedCluster;
  List<DiseaseReportModel> _clusterReports = [];
  bool _isLoadingClusterReports = false;
  UserLocationResult? _userLocation;

  List<OutbreakModel> get outbreaks => _outbreaks;
  List<NearbyReportModel> get nearbyReports => _nearbyReports;
  OutbreakStatisticsModel? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get selectedDiseaseFilter => _selectedDiseaseFilter;
  String get selectedRiskFilter => _selectedRiskFilter;
  String get selectedStatusFilter => _selectedStatusFilter;

  OutbreakModel? get selectedCluster => _selectedCluster;
  List<DiseaseReportModel> get clusterReports => _clusterReports;
  bool get isLoadingClusterReports => _isLoadingClusterReports;
  UserLocationResult? get userLocation => _userLocation;

  List<OutbreakModel> get filteredOutbreaks {
    return _outbreaks.filter((o) {
      if (_selectedDiseaseFilter != 'All Diseases' &&
          _selectedDiseaseFilter != 'सर्व रोग' &&
          _selectedDiseaseFilter != 'सभी रोग') {
        final query = _selectedDiseaseFilter.toLowerCase();
        if (!o.diseaseName.toLowerCase().contains(query) &&
            !query.contains(o.diseaseName.toLowerCase())) {
          return false;
        }
      }

      if (_selectedRiskFilter != 'All Risks' &&
          _selectedRiskFilter != 'सर्व स्तर' &&
          _selectedRiskFilter != 'सभी स्तर') {
        if (o.riskScore.toUpperCase() != _selectedRiskFilter.toUpperCase()) {
          return false;
        }
      }

      if (_selectedStatusFilter != 'All Statuses' &&
          _selectedStatusFilter != 'सर्व स्थिती' &&
          _selectedStatusFilter != 'सभी स्थिति') {
        if (o.status.toUpperCase() != _selectedStatusFilter.toUpperCase()) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<String> get availableDiseases {
    final diseases = <String>{'All Diseases'};
    for (final o in _outbreaks) {
      diseases.add(o.diseaseName);
    }
    return diseases.toList();
  }

  void setDiseaseFilter(String filter) {
    _selectedDiseaseFilter = filter;
    notifyListeners();
  }

  void setRiskFilter(String filter) {
    _selectedRiskFilter = filter;
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _selectedStatusFilter = filter;
    notifyListeners();
  }

  void setUserLocation(UserLocationResult location) {
    _userLocation = location;
    notifyListeners();
  }

  void selectCluster(OutbreakModel? cluster) {
    _selectedCluster = cluster;
    _clusterReports = [];
    notifyListeners();

    if (cluster != null) {
      loadClusterReports(cluster.id);
    }
  }

  Future<UserLocationResult?> fetchUserLocation() async {
    try {
      final loc = await LocationService.instance.getCurrentLocation();
      if (loc != null) {
        _userLocation = loc;
        notifyListeners();
      }
      return loc;
    } catch (e) {
      debugPrint('[OutbreakNotifier] Location error: $e');
      return null;
    }
  }

  Future<void> loadOutbreaks({bool refresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.listOutbreaks(),
        _repository.getOutbreakStatistics().catchError((_) => const OutbreakStatisticsModel(
              totalOutbreaks: 0,
              activeOutbreaks: 0,
              criticalOutbreaks: 0,
              highRiskOutbreaks: 0,
              totalAnimalsAffected: 0,
            )),
      ]);

      _outbreaks = results[0] as List<OutbreakModel>;
      _statistics = results[1] as OutbreakStatisticsModel;

      // If user location is available or can be fetched, also fetch nearby case reports
      if (_userLocation != null) {
        try {
          _nearbyReports = await _repository.searchNearbyReports(
            latitude: _userLocation!.latitude,
            longitude: _userLocation!.longitude,
            radiusKm: 50.0,
          );
        } catch (_) {}
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _outbreaks = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadClusterReports(String outbreakId) async {
    _isLoadingClusterReports = true;
    notifyListeners();

    try {
      _clusterReports = await _repository.getReportsForOutbreak(outbreakId);
    } catch (e) {
      debugPrint('[OutbreakNotifier] Cluster reports error: $e');
      _clusterReports = [];
    } finally {
      _isLoadingClusterReports = false;
      notifyListeners();
    }
  }
}

extension _ListFilter<E> on List<E> {
  Iterable<E> filter(bool Function(E element) test) => where(test);
}

final outbreakNotifier = OutbreakNotifier();
