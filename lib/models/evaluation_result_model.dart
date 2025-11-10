import 'field_feedback_model.dart';

enum RiskLevel { bajo, medio, alto }

class EvaluationResult {
  final String? id;
  final String evaluationId;
  final RiskLevel nivelRiesgo;
  final double puntajeRiesgo;
  final String presionSistolica;
  final String presionDiastolica;
  final String descripcion;
  final List<String> recomendaciones;
  final DateTime fechaResultado;
  final List<FieldFeedback>? fieldFeedback; // lista de FieldFeedback (runtime), no serializada completa todavía

  EvaluationResult({
    this.id,
    required this.evaluationId,
    required this.nivelRiesgo,
    required this.puntajeRiesgo,
    required this.presionSistolica,
    required this.presionDiastolica,
    required this.descripcion,
    required this.recomendaciones,
    required this.fechaResultado,
    this.fieldFeedback,
  });

  factory EvaluationResult.fromJson(Map<String, dynamic> json) {
    return EvaluationResult(
      id: json['id']?.toString(),
      evaluationId: json['evaluation_id']?.toString() ?? '',
      nivelRiesgo: _parseRiskLevel(json['nivel_riesgo']),
      puntajeRiesgo: (json['puntaje_riesgo'] ?? 0).toDouble(),
      presionSistolica: json['presion_sistolica'] ?? '',
      presionDiastolica: json['presion_diastolica'] ?? '',
      descripcion: json['descripcion'] ?? '',
      recomendaciones: List<String>.from(json['recomendaciones'] ?? []),
      fechaResultado: DateTime.parse(json['fecha_resultado']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'evaluation_id': evaluationId,
      'nivel_riesgo': nivelRiesgo.name,
      'puntaje_riesgo': puntajeRiesgo,
      'presion_sistolica': presionSistolica,
      'presion_diastolica': presionDiastolica,
      'descripcion': descripcion,
      'recomendaciones': recomendaciones,
      'fecha_resultado': fechaResultado.toIso8601String(),
      // fieldFeedback omitido para simplificar; se podría mapear si backend lo soporta
    };
  }

  static RiskLevel _parseRiskLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'bajo':
        return RiskLevel.bajo;
      case 'medio':
        return RiskLevel.medio;
      case 'alto':
        return RiskLevel.alto;
      default:
        return RiskLevel.bajo;
    }
  }

  String get nivelRiesgoText {
    switch (nivelRiesgo) {
      case RiskLevel.bajo:
        return 'Bajo';
      case RiskLevel.medio:
        return 'Medio';
      case RiskLevel.alto:
        return 'Alto';
    }
  }

  String get riskLevelDisplay {
    switch (nivelRiesgo) {
      case RiskLevel.bajo:
        return 'BAJO';
      case RiskLevel.medio:
        return 'MODERADO';
      case RiskLevel.alto:
        return 'ALTO';
    }
  }

  double get riskPercentage {
    // Convertir el puntaje de riesgo a porcentaje para el gauge
    return (puntajeRiesgo * 100).clamp(0, 100);
  }
}