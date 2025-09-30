import 'package:flutter/material.dart';
import '../models/evaluation_model.dart';
import '../models/evaluation_result_model.dart';
import '../models/field_feedback_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class EvaluationService extends ChangeNotifier {
  List<Evaluation> _evaluations = [];
  EvaluationResult? _latestResult;
  bool _isLoading = false;

  List<Evaluation> get evaluations => _evaluations;
  EvaluationResult? get latestResult => _latestResult;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<EvaluationResult> createEvaluation(Evaluation evaluation) async {
    _setLoading(true);
    try {
      // MODO SIMULADO (sin backend): generar resultado local y guardar en memoria
      // TODO: Reemplazar por llamada API cuando esté disponible y mover esta simulación a fallback catch.
      final simulated = _simulateResult(evaluation);
      _latestResult = simulated;

      // Simulamos un ID de evaluación incremental simple
      final simulatedEval = Evaluation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: evaluation.userId,
        peso: evaluation.peso,
        altura: evaluation.altura,
        controlaConsumoSal: evaluation.controlaConsumoSal,
        consumoAlcohol: evaluation.consumoAlcohol,
        habitoTabaquismo: evaluation.habitoTabaquismo,
        diasEstres: evaluation.diasEstres,
        actividadFisica: evaluation.actividadFisica,
        colesterolAlto: evaluation.colesterolAlto,
        diabetes: evaluation.diabetes,
        cigarrilloElectronico: evaluation.cigarrilloElectronico,
        fechaEvaluacion: evaluation.fechaEvaluacion,
      );
      _evaluations.insert(0, simulatedEval);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 400)); // pequeña pausa para UX
      return simulated;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> getEvaluationHistory(String userId) async {
    _setLoading(true);
    
    try {
      final response = await _apiService.get(
        '${Constants.historyEndpoint}/$userId',
      );

      _evaluations = (response['evaluations'] as List)
          .map((json) => Evaluation.fromJson(json))
          .toList();
      
      notifyListeners();
    } catch (e) {
      debugPrint('Get evaluation history error: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<EvaluationResult> getEvaluationResult(String evaluationId) async {
    try {
      final response = await _apiService.get(
        '${Constants.evaluationEndpoint}/$evaluationId/result',
      );

      return EvaluationResult.fromJson(response);
    } catch (e) {
      debugPrint('Get evaluation result error: $e');
      rethrow;
    }
  }

  void clearLatestResult() {
    _latestResult = null;
    notifyListeners();
  }

  void clearEvaluations() {
    _evaluations.clear();
    _latestResult = null;
    notifyListeners();
  }

  // ==== MODO DEMO: resultado fijo sin cálculo ====
  void setDummyResult({double? pesoKg, double? alturaCm}) {
    // Cálculo dinámico de IMC si tenemos datos; si no, usar valor fijo demo
    double? imc;
    if (pesoKg != null && alturaCm != null && alturaCm > 0) {
      final alturaM = alturaCm / 100.0;
      imc = double.parse((pesoKg / (alturaM * alturaM)).toStringAsFixed(1));
    }

    String imcClasificacion(double v) {
      if (v < 18.5) return 'Bajo peso';
      if (v < 25) return 'Normal';
      if (v < 30) return 'Sobrepeso';
      return 'Obesidad';
    }

    final imcValor = imc ?? 28.3;
    final imcCategoria = imcClasificacion(imcValor);

    final feedback = <FieldFeedback>[
      FieldFeedback(
        fieldKey: 'imc',
        title: 'IMC',
        valueDisplay: '$imcValor ($imcCategoria)',
        message: imcCategoria == 'Normal'
            ? 'Mantén hábitos saludables para conservar un peso adecuado.'
            : 'Reducir 5-7% del peso corporal ayuda a disminuir el riesgo.',
        status: imcCategoria == 'Normal'
            ? FeedbackStatus.good
            : (imcCategoria == 'Sobrepeso' ? FeedbackStatus.warning : FeedbackStatus.bad),
      ),
      FieldFeedback(
        fieldKey: 'sal',
        title: 'Consumo de sal',
        valueDisplay: 'Moderado/Alto',
        message: 'Intenta no superar 5 g de sal al día (≈1 cucharadita).',
        status: FeedbackStatus.bad,
      ),
      FieldFeedback(
        fieldKey: 'actividad',
        title: 'Actividad física',
        valueDisplay: 'Insuficiente',
        message: 'Objetivo: ≥150 min/sem de intensidad moderada.',
        status: FeedbackStatus.bad,
      ),
      FieldFeedback(
        fieldKey: 'alcohol',
        title: 'Alcohol',
        valueDisplay: 'Ocasional',
        message: 'Mantener consumo bajo o cero mejora presión arterial.',
        status: FeedbackStatus.warning,
      ),
      FieldFeedback(
        fieldKey: 'tabaco',
        title: 'Tabaquismo',
        valueDisplay: 'Ex fumador',
        message: 'Excelente: mantenerse libre de tabaco reduce riesgo.',
        status: FeedbackStatus.good,
      ),
      FieldFeedback(
        fieldKey: 'estres',
        title: 'Estrés',
        valueDisplay: 'Alto (≥15 días)',
        message: 'Practica técnicas de respiración y pausas activas.',
        status: FeedbackStatus.warning,
      ),
      FieldFeedback(
        fieldKey: 'colesterol',
        title: 'Colesterol',
        valueDisplay: 'Desconocido',
        message: 'Realiza un control de perfil lipídico anual.',
        status: FeedbackStatus.warning,
      ),
      FieldFeedback(
        fieldKey: 'diabetes',
        title: 'Diabetes',
        valueDisplay: 'No',
        message: 'Mantén hábitos saludables para prevenirla.',
        status: FeedbackStatus.good,
      ),
      FieldFeedback(
        fieldKey: 'vapeo',
        title: 'Cigarrillo electrónico',
        valueDisplay: 'No usa',
        message: 'Muy bien: evita nicotina y sustancias irritantes.',
        status: FeedbackStatus.good,
      ),
    ];

    _latestResult = EvaluationResult(
      evaluationId: 'demo',
      nivelRiesgo: RiskLevel.medio,
      puntajeRiesgo: 0.45,
      presionSistolica: '125 mmHg',
      presionDiastolica: '84 mmHg',
      descripcion: 'Ejemplo demostrativo: riesgo moderado (datos simulados).',
      recomendaciones: [
        'Reducir ligeramente el consumo de sal',
        'Aumentar minutos de actividad física',
        'Controlar niveles de estrés',
        'Monitorizar presión 1 vez por semana',
      ],
      fechaResultado: DateTime.now(),
      fieldFeedback: feedback,
    );
    notifyListeners();
  }

  // Método para simular resultados localmente si no tienes backend aún
  EvaluationResult _simulateResult(Evaluation evaluation) {
    // Algoritmo básico de simulación - debes reemplazar con tu lógica real
    double riskScore = 0.0;
    
    // Factores de riesgo basados en IMC
    final imc = evaluation.imc;
    if (imc >= 30) {
      riskScore += 0.3;
    // ignore: curly_braces_in_flow_control_structures
    } else if (imc >= 25) riskScore += 0.15;
    
    // Edad (calculada desde la fecha de nacimiento del usuario)
    // Nota: necesitarías acceso a los datos del usuario aquí
    
    // Otros factores
    if (evaluation.diabetes == 'Si') riskScore += 0.25;
    if (evaluation.colesterolAlto == 'Si') riskScore += 0.2;
    if (evaluation.habitoTabaquismo == 'Fumador actual') riskScore += 0.2;
    if (evaluation.diasEstres > 15) riskScore += 0.1;
    if (evaluation.actividadFisica == 'No') riskScore += 0.1;
    if (evaluation.consumoAlcohol == 'Si') riskScore += 0.05;
    
    riskScore = riskScore.clamp(0.0, 1.0);
    
    RiskLevel riskLevel;
    String presionSistolica;
    String presionDiastolica;
    
    if (riskScore < 0.3) {
      riskLevel = RiskLevel.bajo;
      presionSistolica = '< 120 mmHg';
      presionDiastolica = '< 80 mmHg';
    } else if (riskScore < 0.6) {
      riskLevel = RiskLevel.medio;
      presionSistolica = '120-139 mmHg';
      presionDiastolica = '80-89 mmHg';
    } else {
      riskLevel = RiskLevel.alto;
      presionSistolica = '> 140 mmHg';
      presionDiastolica = '> 90 mmHg';
    }

    return EvaluationResult(
      evaluationId: evaluation.id ?? '',
      nivelRiesgo: riskLevel,
      puntajeRiesgo: riskScore,
      presionSistolica: presionSistolica,
      presionDiastolica: presionDiastolica,
      descripcion: _getDescriptionForRiskLevel(riskLevel),
      recomendaciones: _getRecommendationsForRiskLevel(riskLevel),
      fechaResultado: DateTime.now(),
    );
  }

  String _getDescriptionForRiskLevel(RiskLevel level) {
    switch (level) {
      case RiskLevel.bajo:
        return 'Su riesgo de desarrollar hipertensión arterial es bajo. '
               'Mantenga sus hábitos saludables.';
      case RiskLevel.medio:
        return 'Su riesgo de desarrollar hipertensión arterial es moderado. '
               'Considere hacer algunos cambios en su estilo de vida.';
      case RiskLevel.alto:
        return 'Su riesgo de desarrollar hipertensión arterial es alto. '
               'Se recomienda consultar con un profesional de la salud.';
    }
  }

  List<String> _getRecommendationsForRiskLevel(RiskLevel level) {
    switch (level) {
      case RiskLevel.bajo:
        return [
          'Mantener una dieta equilibrada',
          'Realizar ejercicio regularmente',
          'Controlar el estrés',
          'Mantener un peso saludable',
        ];
      case RiskLevel.medio:
        return [
          'Reducir el consumo de sal',
          'Aumentar la actividad física',
          'Controlar el peso corporal',
          'Limitar el consumo de alcohol',
          'Manejar el estrés adecuadamente',
        ];
      case RiskLevel.alto:
        return [
          'Consultar con un médico',
          'Seguir una dieta DASH',
          'Realizar ejercicio bajo supervisión médica',
          'Dejar de fumar completamente',
          'Monitorear la presión arterial regularmente',
          'Tomar medicamentos según prescripción médica',
        ];
    }
  }
}