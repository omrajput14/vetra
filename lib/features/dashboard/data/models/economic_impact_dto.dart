class EconomicImpactModel {
  final double? modeledSavings;
  final String? formattedValue;
  final String unit;
  final String label;
  final bool isModeled;
  final bool hasSufficientData;
  final int eligibleAnimalsCount;
  final String statusMessage;
  final String methodology;
  final String methodologyVersion;
  final String scope;

  const EconomicImpactModel({
    this.modeledSavings,
    this.formattedValue,
    this.unit = 'INR',
    this.label = 'Modeled estimate',
    this.isModeled = true,
    this.hasSufficientData = false,
    this.eligibleAnimalsCount = 0,
    this.statusMessage = 'Estimated savings unavailable',
    this.methodology = '',
    this.methodologyVersion = 'v1.0-deterministic',
    this.scope = 'FARMER',
  });

  factory EconomicImpactModel.fromJson(Map<String, dynamic> json) {
    double? savings;
    if (json['modeledSavings'] != null) {
      savings = (json['modeledSavings'] is num)
          ? (json['modeledSavings'] as num).toDouble()
          : double.tryParse(json['modeledSavings'].toString());
    }

    return EconomicImpactModel(
      modeledSavings: savings,
      formattedValue: json['formattedValue']?.toString(),
      unit: json['unit']?.toString() ?? 'INR',
      label: json['label']?.toString() ?? 'Modeled estimate',
      isModeled: json['isModeled'] is bool ? json['isModeled'] as bool : true,
      hasSufficientData: json['hasSufficientData'] is bool
          ? json['hasSufficientData'] as bool
          : (savings != null && savings > 0),
      eligibleAnimalsCount: json['eligibleAnimalsCount'] != null
          ? (json['eligibleAnimalsCount'] as num).toInt()
          : 0,
      statusMessage: json['statusMessage']?.toString() ?? 'Estimated savings unavailable',
      methodology: json['methodology']?.toString() ?? '',
      methodologyVersion: json['methodologyVersion']?.toString() ?? 'v1.0-deterministic',
      scope: json['scope']?.toString() ?? 'FARMER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modeledSavings': modeledSavings,
      'formattedValue': formattedValue,
      'unit': unit,
      'label': label,
      'isModeled': isModeled,
      'hasSufficientData': hasSufficientData,
      'eligibleAnimalsCount': eligibleAnimalsCount,
      'statusMessage': statusMessage,
      'methodology': methodology,
      'methodologyVersion': methodologyVersion,
      'scope': scope,
    };
  }
}
