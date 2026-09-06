import 'disease_report_dto.dart';

/// Public DTO representing an active or historical disease outbreak cluster.
class OutbreakModel {
  final String id;
  final String diseaseName;
  final String severity;
  final String status;
  final String riskScore;
  final double centerLatitude;
  final double centerLongitude;
  final double radiusKm;
  final int affectedReportsCount;
  final int evaluationWindowHours;
  final DateTime? lastCaseReportedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int compositeRiskScore;
  final RiskBreakdownModel? riskBreakdown;

  const OutbreakModel({
    required this.id,
    required this.diseaseName,
    required this.severity,
    required this.status,
    required this.riskScore,
    required this.centerLatitude,
    required this.centerLongitude,
    required this.radiusKm,
    required this.affectedReportsCount,
    required this.evaluationWindowHours,
    this.lastCaseReportedAt,
    this.createdAt,
    this.updatedAt,
    this.compositeRiskScore = 50,
    this.riskBreakdown,
  });

  factory OutbreakModel.fromJson(Map<String, dynamic> json) {
    return OutbreakModel(
      id: json['id']?.toString() ?? '',
      diseaseName: json['diseaseName']?.toString() ?? 'Outbreak Cluster',
      severity: json['severity']?.toString() ?? 'WARNING',
      status: json['status']?.toString() ?? 'ACTIVE',
      riskScore: json['riskScore']?.toString() ?? 'MEDIUM',
      centerLatitude: (json['centerLatitude'] as num?)?.toDouble() ?? 0.0,
      centerLongitude: (json['centerLongitude'] as num?)?.toDouble() ?? 0.0,
      radiusKm: (json['radiusKm'] as num?)?.toDouble() ?? 5.0,
      affectedReportsCount: (json['affectedReportsCount'] as num?)?.toInt() ?? 0,
      evaluationWindowHours: (json['evaluationWindowHours'] as num?)?.toInt() ?? 24,
      lastCaseReportedAt: json['lastCaseReportedAt'] != null
          ? DateTime.tryParse(json['lastCaseReportedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      compositeRiskScore: (json['compositeRiskScore'] as num?)?.toInt() ?? 50,
      riskBreakdown: json['riskBreakdown'] is Map<String, dynamic>
          ? RiskBreakdownModel.fromJson(json['riskBreakdown'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'diseaseName': diseaseName,
        'severity': severity,
        'status': status,
        'riskScore': riskScore,
        'centerLatitude': centerLatitude,
        'centerLongitude': centerLongitude,
        'radiusKm': radiusKm,
        'affectedReportsCount': affectedReportsCount,
        'evaluationWindowHours': evaluationWindowHours,
        if (lastCaseReportedAt != null)
          'lastCaseReportedAt': lastCaseReportedAt!.toIso8601String(),
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
        'compositeRiskScore': compositeRiskScore,
        if (riskBreakdown != null) 'riskBreakdown': riskBreakdown!.toJson(),
      };
}

/// Multi-signal epidemiological breakdown for explainable AI risk intelligence.
class RiskBreakdownModel {
  final double clusterScore;
  final double weatherScore;
  final double historyScore;
  final double vaccinationGapScore;
  final double? weatherTemperature;
  final double? weatherHumidity;
  final double? weatherPrecipitation;
  final double? vaccinationCoveragePct;
  final String riskExplanation;
  final String recommendedAction;

  const RiskBreakdownModel({
    required this.clusterScore,
    required this.weatherScore,
    required this.historyScore,
    required this.vaccinationGapScore,
    this.weatherTemperature,
    this.weatherHumidity,
    this.weatherPrecipitation,
    this.vaccinationCoveragePct,
    required this.riskExplanation,
    required this.recommendedAction,
  });

  factory RiskBreakdownModel.fromJson(Map<String, dynamic> json) {
    return RiskBreakdownModel(
      clusterScore: (json['clusterScore'] as num?)?.toDouble() ?? 0.0,
      weatherScore: (json['weatherScore'] as num?)?.toDouble() ?? 0.0,
      historyScore: (json['historyScore'] as num?)?.toDouble() ?? 0.0,
      vaccinationGapScore: (json['vaccinationGapScore'] as num?)?.toDouble() ?? 0.0,
      weatherTemperature: (json['weatherTemperature'] as num?)?.toDouble(),
      weatherHumidity: (json['weatherHumidity'] as num?)?.toDouble(),
      weatherPrecipitation: (json['weatherPrecipitation'] as num?)?.toDouble(),
      vaccinationCoveragePct: (json['vaccinationCoveragePct'] as num?)?.toDouble(),
      riskExplanation: json['riskExplanation']?.toString() ?? '',
      recommendedAction: json['recommendedAction']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'clusterScore': clusterScore,
        'weatherScore': weatherScore,
        'historyScore': historyScore,
        'vaccinationGapScore': vaccinationGapScore,
        if (weatherTemperature != null) 'weatherTemperature': weatherTemperature,
        if (weatherHumidity != null) 'weatherHumidity': weatherHumidity,
        if (weatherPrecipitation != null) 'weatherPrecipitation': weatherPrecipitation,
        if (vaccinationCoveragePct != null) 'vaccinationCoveragePct': vaccinationCoveragePct,
        'riskExplanation': riskExplanation,
        'recommendedAction': recommendedAction,
      };
}

/// Epidemiological statistics summary for surveillance dashboard & maps.
class OutbreakStatisticsModel {
  final int totalOutbreaks;
  final int activeOutbreaks;
  final int criticalOutbreaks;
  final int highRiskOutbreaks;
  final int totalAnimalsAffected;

  const OutbreakStatisticsModel({
    required this.totalOutbreaks,
    required this.activeOutbreaks,
    required this.criticalOutbreaks,
    required this.highRiskOutbreaks,
    required this.totalAnimalsAffected,
  });

  factory OutbreakStatisticsModel.fromJson(Map<String, dynamic> json) {
    return OutbreakStatisticsModel(
      totalOutbreaks: (json['totalOutbreaks'] as num?)?.toInt() ?? 0,
      activeOutbreaks: (json['activeOutbreaks'] as num?)?.toInt() ?? 0,
      criticalOutbreaks: (json['criticalOutbreaks'] as num?)?.toInt() ?? 0,
      highRiskOutbreaks: (json['highRiskOutbreaks'] as num?)?.toInt() ?? 0,
      totalAnimalsAffected: (json['totalAnimalsAffected'] as num?)?.toInt() ?? 0,
    );
  }
}

/// Nearby disease report with calculated distance from reference coordinate.
class NearbyReportModel {
  final DiseaseReportModel report;
  final double distanceKm;

  const NearbyReportModel({
    required this.report,
    required this.distanceKm,
  });

  factory NearbyReportModel.fromJson(Map<String, dynamic> json) {
    final reportJson = json['report'] is Map<String, dynamic>
        ? json['report'] as Map<String, dynamic>
        : json;
    return NearbyReportModel(
      report: DiseaseReportModel.fromJson(reportJson),
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
