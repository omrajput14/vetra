class DiseaseMetadataModel {
  final String diseaseName;
  final String severity;
  final bool zoonotic;
  final bool reportable;
  final String mortality;
  final double defaultRadiusKm;
  final int minimumCases;
  final int evaluationWindowHours;

  const DiseaseMetadataModel({
    required this.diseaseName,
    required this.severity,
    required this.zoonotic,
    required this.reportable,
    required this.mortality,
    required this.defaultRadiusKm,
    required this.minimumCases,
    required this.evaluationWindowHours,
  });

  factory DiseaseMetadataModel.fromJson(Map<String, dynamic> json) {
    return DiseaseMetadataModel(
      diseaseName: json['diseaseName']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'MEDIUM',
      zoonotic: json['zoonotic'] is bool ? json['zoonotic'] as bool : false,
      reportable: json['reportable'] is bool ? json['reportable'] as bool : false,
      mortality: json['mortality']?.toString() ?? 'LOW',
      defaultRadiusKm: json['defaultRadiusKm'] != null
          ? (json['defaultRadiusKm'] as num).toDouble()
          : 25.0,
      minimumCases: json['minimumCases'] != null
          ? (json['minimumCases'] as num).toInt()
          : 3,
      evaluationWindowHours: json['evaluationWindowHours'] != null
          ? (json['evaluationWindowHours'] as num).toInt()
          : 48,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diseaseName': diseaseName,
      'severity': severity,
      'zoonotic': zoonotic,
      'reportable': reportable,
      'mortality': mortality,
      'defaultRadiusKm': defaultRadiusKm,
      'minimumCases': minimumCases,
      'evaluationWindowHours': evaluationWindowHours,
    };
  }
}
