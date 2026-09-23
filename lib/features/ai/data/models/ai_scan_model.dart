import 'dart:convert';

class AIScanModel {
  final String id;
  final String animalId;
  final String? animalName;
  final String imageUrl;
  final String? aiProvider;
  final String? aiModel;
  final String? diagnosis;
  final double? confidenceScore;
  final String severity;
  final List<String> observations;
  final String recommendedNextStep;
  final bool requiresVeterinarianReview;
  final String disclaimer;
  final String status;
  final String? notes;
  final String? createdAt;

  AIScanModel({
    required this.id,
    required this.animalId,
    this.animalName,
    required this.imageUrl,
    this.aiProvider,
    this.aiModel,
    this.diagnosis,
    this.confidenceScore,
    this.severity = 'UNKNOWN',
    this.observations = const [],
    this.recommendedNextStep =
        'Schedule a clinical evaluation with a licensed veterinarian for on-site diagnosis.',
    this.requiresVeterinarianReview = true,
    this.disclaimer =
        'This is an AI-assisted preliminary assessment and is not a confirmed veterinary diagnosis.',
    required this.status,
    this.notes,
    this.createdAt,
  });

  /// The server stored the scan but produced no diagnosis: AI inference failed
  /// (status FAILED) or never ran (status PENDING). Not a result to show.
  bool get isAnalysisFailure =>
      status != 'PENDING_UPLOAD' &&
      (status == 'FAILED' || diagnosis == null || diagnosis!.trim().isEmpty);

  factory AIScanModel.fromJson(Map<String, dynamic> json) {
    String severity = json['severity']?.toString() ?? 'UNKNOWN';
    List<String> observations = [];
    if (json['observations'] is List) {
      observations = (json['observations'] as List)
          .map((e) => e.toString())
          .toList();
    }
    String recommendedNextStep = json['recommendedNextStep']?.toString() ??
        'Schedule a clinical evaluation with a licensed veterinarian for on-site diagnosis.';
    bool requiresVeterinarianReview = json['requiresVeterinarianReview'] is bool
        ? json['requiresVeterinarianReview'] as bool
        : true;
    String disclaimer = json['disclaimer']?.toString() ??
        'This is an AI-assisted preliminary assessment and is not a confirmed veterinary diagnosis.';

    // Fallback: Check if notes contains structured JSON
    final notesRaw = json['notes']?.toString();
    if (notesRaw != null && notesRaw.trim().startsWith('{')) {
      try {
        final Map<String, dynamic> notesMap =
            jsonDecode(notesRaw) as Map<String, dynamic>;
        if (json['severity'] == null && notesMap['severity'] != null) {
          severity = notesMap['severity'].toString();
        }
        if (observations.isEmpty && notesMap['observations'] is List) {
          observations = (notesMap['observations'] as List)
              .map((e) => e.toString())
              .toList();
        }
        if (json['recommendedNextStep'] == null &&
            notesMap['recommendedNextStep'] != null) {
          recommendedNextStep = notesMap['recommendedNextStep'].toString();
        }
        if (json['requiresVeterinarianReview'] == null &&
            notesMap['requiresVeterinarianReview'] != null) {
          requiresVeterinarianReview =
              notesMap['requiresVeterinarianReview'] as bool;
        }
        if (json['disclaimer'] == null && notesMap['disclaimer'] != null) {
          disclaimer = notesMap['disclaimer'].toString();
        }
      } catch (_) {
        // preserve defaults if notes is not JSON
      }
    }

    return AIScanModel(
      id: json['id']?.toString() ?? '',
      animalId: json['animalId']?.toString() ?? '',
      animalName: json['animalName']?.toString(),
      imageUrl: json['imageUrl']?.toString() ?? '',
      aiProvider: json['aiProvider']?.toString(),
      aiModel: json['aiModel']?.toString(),
      diagnosis: json['diagnosis']?.toString(),
      confidenceScore: json['confidenceScore'] != null
          ? (json['confidenceScore'] is num
              ? (json['confidenceScore'] as num).toDouble()
              : double.tryParse(json['confidenceScore'].toString()))
          : null,
      severity: severity.toUpperCase(),
      observations: observations,
      recommendedNextStep: recommendedNextStep,
      requiresVeterinarianReview: requiresVeterinarianReview,
      disclaimer: disclaimer,
      status: json['status']?.toString() ?? 'PENDING',
      notes: notesRaw,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animalId': animalId,
      'animalName': animalName,
      'imageUrl': imageUrl,
      'aiProvider': aiProvider,
      'aiModel': aiModel,
      'diagnosis': diagnosis,
      'confidenceScore': confidenceScore,
      'severity': severity,
      'observations': observations,
      'recommendedNextStep': recommendedNextStep,
      'requiresVeterinarianReview': requiresVeterinarianReview,
      'disclaimer': disclaimer,
      'status': status,
      'notes': notes,
      'createdAt': createdAt,
    };
  }
}
