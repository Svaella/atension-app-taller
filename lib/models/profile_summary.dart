enum RiskLevel { low, moderate, high, obesity }

extension RiskLevelX on RiskLevel {
  static RiskLevel fromString(String value) {
    switch (value.toLowerCase()) {
      case 'moderate':
      case 'medio':
        return RiskLevel.moderate;
      case 'high':
      case 'alto':
        return RiskLevel.high;
      case 'obesity':
      case 'obesidad':
        return RiskLevel.obesity;
      default:
        return RiskLevel.low;
    }
  }
}

class RiskFactor {
  final String id;
  final String title;
  final String description;
  final List<String> recommendations;
  final RiskLevel level;
  final String iconKey;

  RiskFactor({
    required this.id,
    required this.title,
    required this.description,
    required this.recommendations,
    required this.level,
    required this.iconKey,
  });

  factory RiskFactor.fromJson(Map<String, dynamic> json) {
    return RiskFactor(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      recommendations: (json['recommendations'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      level: RiskLevelX.fromString(json['level'] ?? 'low'),
      iconKey: json['icon_key'] ?? '',
    );
  }
}

class ProfileSummary {
  final int age;
  final String gender;
  final double bmi;
  final String bmiCategory;
  final List<RiskFactor> risks;
  final int daysUntilNext;

  ProfileSummary({
    required this.age,
    required this.gender,
    required this.bmi,
    required this.bmiCategory,
    required this.risks,
    required this.daysUntilNext,
  });

  factory ProfileSummary.fromJson(Map<String, dynamic> json) {
    return ProfileSummary(
      age: json['age'] ?? 0,
      gender: json['gender'] ?? '',
      bmi: (json['bmi'] ?? 0).toDouble(),
      bmiCategory: json['bmi_category'] ?? '',
      risks: (json['risk_factors'] as List<dynamic>? ?? [])
          .map((e) => RiskFactor.fromJson(e as Map<String, dynamic>))
          .toList(),
      daysUntilNext: json['days_until_next'] ?? 30,
    );
  }
}