enum AIAdvisorSessionStatus {
  questioning,
  readyForAssessment,
  assessmentGenerated,
  insufficientInformation,
  urgentVeterinaryReview,
  failed;

  static AIAdvisorSessionStatus fromString(String? value) {
    if (value == null) return AIAdvisorSessionStatus.questioning;
    switch (value.toUpperCase().trim()) {
      case 'QUESTIONING':
        return AIAdvisorSessionStatus.questioning;
      case 'READY_FOR_ASSESSMENT':
        return AIAdvisorSessionStatus.readyForAssessment;
      case 'ASSESSMENT_GENERATED':
        return AIAdvisorSessionStatus.assessmentGenerated;
      case 'INSUFFICIENT_INFORMATION':
        return AIAdvisorSessionStatus.insufficientInformation;
      case 'URGENT_VETERINARY_REVIEW':
        return AIAdvisorSessionStatus.urgentVeterinaryReview;
      case 'FAILED':
        return AIAdvisorSessionStatus.failed;
      default:
        return AIAdvisorSessionStatus.questioning;
    }
  }

  String toDisplayString() {
    switch (this) {
      case AIAdvisorSessionStatus.questioning:
        return 'Collecting Information';
      case AIAdvisorSessionStatus.readyForAssessment:
        return 'Ready for Assessment';
      case AIAdvisorSessionStatus.assessmentGenerated:
        return 'Preliminary Assessment Complete';
      case AIAdvisorSessionStatus.insufficientInformation:
        return 'Insufficient Information';
      case AIAdvisorSessionStatus.urgentVeterinaryReview:
        return 'Urgent Veterinary Review Required';
      case AIAdvisorSessionStatus.failed:
        return 'Assessment Interrupted';
    }
  }
}

enum AIAdvisorRiskLevel {
  critical,
  severe,
  moderate,
  mild,
  unknown;

  static AIAdvisorRiskLevel fromString(String? value) {
    if (value == null) return AIAdvisorRiskLevel.unknown;
    switch (value.toUpperCase().trim()) {
      case 'CRITICAL':
        return AIAdvisorRiskLevel.critical;
      case 'SEVERE':
        return AIAdvisorRiskLevel.severe;
      case 'MODERATE':
        return AIAdvisorRiskLevel.moderate;
      case 'MILD':
        return AIAdvisorRiskLevel.mild;
      default:
        return AIAdvisorRiskLevel.unknown;
    }
  }

  String toDisplayString() {
    switch (this) {
      case AIAdvisorRiskLevel.critical:
        return 'CRITICAL';
      case AIAdvisorRiskLevel.severe:
        return 'SEVERE';
      case AIAdvisorRiskLevel.moderate:
        return 'MODERATE';
      case AIAdvisorRiskLevel.mild:
        return 'MILD';
      case AIAdvisorRiskLevel.unknown:
        return 'UNKNOWN';
    }
  }
}

class PossibleConditionModel {
  final String condition;
  final double confidence;
  final String reasoning;

  const PossibleConditionModel({
    required this.condition,
    required this.confidence,
    required this.reasoning,
  });

  factory PossibleConditionModel.fromJson(Map<String, dynamic> json) {
    return PossibleConditionModel(
      condition: json['condition'] as String? ?? 'Preliminary Condition (Suspected)',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.70,
      reasoning: json['reasoning'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'condition': condition,
        'confidence': confidence,
        'reasoning': reasoning,
      };
}

class AIAdvisorAssessmentModel {
  final List<PossibleConditionModel> possibleConditions;
  final List<String> userReportedSymptoms;
  final List<String> keyObservations;
  final AIAdvisorRiskLevel riskLevel;
  final bool requiresVeterinarianReview;
  final String recommendedNextStep;
  final String disclaimer;

  const AIAdvisorAssessmentModel({
    required this.possibleConditions,
    this.userReportedSymptoms = const [],
    required this.keyObservations,
    required this.riskLevel,
    required this.requiresVeterinarianReview,
    required this.recommendedNextStep,
    required this.disclaimer,
  });

  factory AIAdvisorAssessmentModel.fromJson(Map<String, dynamic> json) {
    final conditionsList = (json['possibleConditions'] as List<dynamic>?)
            ?.map((e) => PossibleConditionModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final userSymptomsList = (json['userReportedSymptoms'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final observationsList = (json['keyObservations'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return AIAdvisorAssessmentModel(
      possibleConditions: conditionsList,
      userReportedSymptoms: userSymptomsList,
      keyObservations: observationsList,
      riskLevel: AIAdvisorRiskLevel.fromString(json['riskLevel'] as String?),
      requiresVeterinarianReview: json['requiresVeterinarianReview'] as bool? ?? true,
      recommendedNextStep: json['recommendedNextStep'] as String? ??
          'Arrange an on-site clinical consultation with a licensed veterinarian.',
      disclaimer: json['disclaimer'] as String? ??
          'This is an AI-assisted preliminary assessment and is not a confirmed veterinary diagnosis.',
    );
  }

  Map<String, dynamic> toJson() => {
        'possibleConditions': possibleConditions.map((e) => e.toJson()).toList(),
        'userReportedSymptoms': userReportedSymptoms,
        'keyObservations': keyObservations,
        'riskLevel': riskLevel.name.toUpperCase(),
        'requiresVeterinarianReview': requiresVeterinarianReview,
        'recommendedNextStep': recommendedNextStep,
        'disclaimer': disclaimer,
      };
}

class AIAdvisorMessageModel {
  final String id;
  final String senderType; // 'USER' or 'ADVISOR'
  final String content;
  final int turnNumber;
  final List<String> followUpQuestions;
  final AIAdvisorAssessmentModel? assessment;
  final DateTime createdAt;

  const AIAdvisorMessageModel({
    required this.id,
    required this.senderType,
    required this.content,
    required this.turnNumber,
    required this.followUpQuestions,
    this.assessment,
    required this.createdAt,
  });

  bool get isUser => senderType.toUpperCase() == 'USER';

  factory AIAdvisorMessageModel.fromJson(Map<String, dynamic> json) {
    final questionsList = (json['followUpQuestions'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    AIAdvisorAssessmentModel? assessmentModel;
    if (json['assessment'] != null && json['assessment'] is Map<String, dynamic>) {
      assessmentModel =
          AIAdvisorAssessmentModel.fromJson(json['assessment'] as Map<String, dynamic>);
    }

    return AIAdvisorMessageModel(
      id: json['id'] as String? ?? '',
      senderType: json['senderType'] as String? ?? 'ADVISOR',
      content: json['content'] as String? ?? '',
      turnNumber: json['turnNumber'] as int? ?? 0,
      followUpQuestions: questionsList,
      assessment: assessmentModel,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderType': senderType,
        'content': content,
        'turnNumber': turnNumber,
        'followUpQuestions': followUpQuestions,
        'assessment': assessment?.toJson(),
        'createdAt': createdAt.toIso8601String(),
      };
}

class AIAdvisorSessionModel {
  final String id;
  final String animalId;
  final String animalName;
  final String species;
  final String? breed;
  final String userId;
  final AIAdvisorSessionStatus status;
  final AIAdvisorRiskLevel riskLevel;
  final bool requiresVetReview;
  final int turnCount;
  final AIAdvisorAssessmentModel? assessment;
  final List<AIAdvisorMessageModel> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AIAdvisorSessionModel({
    required this.id,
    required this.animalId,
    required this.animalName,
    required this.species,
    this.breed,
    required this.userId,
    required this.status,
    required this.riskLevel,
    required this.requiresVetReview,
    required this.turnCount,
    this.assessment,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AIAdvisorSessionModel.fromJson(Map<String, dynamic> json) {
    final messagesList = (json['messages'] as List<dynamic>?)
            ?.map((e) => AIAdvisorMessageModel.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    AIAdvisorAssessmentModel? assessmentModel;
    if (json['assessment'] != null && json['assessment'] is Map<String, dynamic>) {
      assessmentModel =
          AIAdvisorAssessmentModel.fromJson(json['assessment'] as Map<String, dynamic>);
    }

    return AIAdvisorSessionModel(
      id: json['id'] as String? ?? '',
      animalId: json['animalId'] as String? ?? '',
      animalName: json['animalName'] as String? ?? 'Animal',
      species: json['species'] as String? ?? 'Unknown',
      breed: json['breed'] as String?,
      userId: json['userId'] as String? ?? '',
      status: AIAdvisorSessionStatus.fromString(json['status'] as String?),
      riskLevel: AIAdvisorRiskLevel.fromString(json['riskLevel'] as String?),
      requiresVetReview: json['requiresVetReview'] as bool? ?? true,
      turnCount: json['turnCount'] as int? ?? 0,
      assessment: assessmentModel,
      messages: messagesList,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'animalId': animalId,
        'animalName': animalName,
        'species': species,
        'breed': breed,
        'userId': userId,
        'status': status.name.toUpperCase(),
        'riskLevel': riskLevel.name.toUpperCase(),
        'requiresVetReview': requiresVetReview,
        'turnCount': turnCount,
        'assessment': assessment?.toJson(),
        'messages': messages.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
