import 'package:flutter/material.dart';
import '../models/evaluation_model.dart';
import '../models/evaluation_result_model.dart';
import '../models/field_feedback_model.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class EvaluationService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Evaluation> _evaluations = [];
  EvaluationResult? _latestResult;
  bool _isLoading = false;

  List<Evaluation> get evaluations => _evaluations;
  EvaluationResult? get latestResult => _latestResult;
  bool get isLoading => _isLoading;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Future<EvaluationResult> createEvaluation(Evaluation evaluation) async {
  _setLoading(true);
  try {
    debugPrint('📤 Enviando evaluación al backend...');
    debugPrint('📦 Datos originales:');
    debugPrint('   peso: ${evaluation.peso}');
    debugPrint('   altura: ${evaluation.altura}');
    debugPrint('   habitoTabaquismo: ${evaluation.habitoTabaquismo}');
    debugPrint('   cigarrilloElectronico: ${evaluation.cigarrilloElectronico}');
    debugPrint('   diabetes: ${evaluation.diabetes}');
    
    // Convertir habitoTabaquismo String → Enum del backend
    String smokingHabitValue;
    if (evaluation.habitoTabaquismo == 'Fumador actual') {
      smokingHabitValue = 'Fumo a diario';
    } else if (evaluation.habitoTabaquismo == 'Fumador Ocasional') {
      smokingHabitValue = 'Fumo ocasionalmente';
    } else if (evaluation.habitoTabaquismo == 'Ex Fumador') {
      smokingHabitValue = 'Exfumador';
    } else {
      smokingHabitValue = 'No Fumo';
    }
    
    // Convertir cigarrilloElectronico String → Enum del backend
    String eCigaretteValue;
    if (evaluation.cigarrilloElectronico == 'Todos los días') {
      eCigaretteValue = 'Diariamente';
    } else if (evaluation.cigarrilloElectronico == 'Algunos días') {
      eCigaretteValue = 'Ocasionalmente';
    } else if (evaluation.cigarrilloElectronico == 'Rara vez') {
      eCigaretteValue = 'Rara vez';
    } else {
      eCigaretteValue = 'Nunca he usado';
    }
    
    // Convertir diabetes String → Enum del backend
    String diabetesValue;
    if (evaluation.diabetes == 'Si') {
      diabetesValue = 'Si';
    } else if (evaluation.diabetes == 'Prediabetes') {
      diabetesValue = 'Prediabetes';
    } else {
      diabetesValue = 'No';
    }
    
    debugPrint('📦 Valores mapeados:');
    debugPrint('   smokingHabitValue: $smokingHabitValue');
    debugPrint('   eCigaretteValue: $eCigaretteValue');
    debugPrint('   diabetesValue: $diabetesValue');
    
    // Preparar payload con nombres CORRECTOS del backend
    final payload = {
      'weight_kg': evaluation.peso,
      'height_cm': evaluation.altura,
      'reduces_salt_intake': evaluation.controlaConsumoSal == 'Si',
      'alcohol_in_last_30_days': evaluation.consumoAlcohol == 'Si',
      'smoking_habit': smokingHabitValue,              // ✅ STRING, NO BOOL
      'e_cigarette_use': eCigaretteValue,              // ✅ STRING, NO BOOL
      'stress_days_last_month': evaluation.diasEstres,
      'daily_physical_activity': evaluation.actividadFisica == 'Si',
      'has_high_cholesterol': evaluation.colesterolAlto == 'Si',
      'diabetes_diagnosis': diabetesValue,             // ✅ STRING, NO BOOL
    };
    
    debugPrint('📦 Payload completo:');
    payload.forEach((key, value) {
      debugPrint('   $key: $value (${value.runtimeType})');
    });
    
    debugPrint('📤 Enviando a: ${Constants.evaluationEndpoint}');
    
    // Enviar al backend
    final response = await _apiService.post(
      Constants.evaluationEndpoint,
      payload,
    );

    debugPrint('✅ Respuesta del backend: $response');

    // Generar feedbacks
    final feedbacks = _generateFieldFeedback(
      evaluation,
      smokingHabitValue != 'No Fumo',
      evaluation.actividadFisica == 'Si',
      evaluation.colesterolAlto == 'Si',
      evaluation.diabetes == 'Si',
      eCigaretteValue != 'Nunca he usado',
      evaluation.consumoAlcohol == 'Si',
      evaluation.controlaConsumoSal == 'Si',
    );

    // Crear resultado desde respuesta del backend
    final result = EvaluationResult(
      evaluationId: response['id']?.toString() ?? '',
      nivelRiesgo: _parseRiskLevel(response['risk_level']),
      puntajeRiesgo: (response['probability'] as num?)?.toDouble() ?? 0.0,
      presionSistolica: '${120 + ((response['probability'] as num? ?? 0) * 40).round()} mmHg',
      presionDiastolica: '${80 + ((response['probability'] as num? ?? 0) * 20).round()} mmHg',
      descripcion: _getDescriptionForRiskLevel(_parseRiskLevel(response['risk_level'])),
      recomendaciones: _getRecommendationsForRiskLevel(_parseRiskLevel(response['risk_level'])),
      fechaResultado: DateTime.now(),
      fieldFeedback: feedbacks,
    );

    _latestResult = result;
    
    // ✅ Recargar historial después de crear evaluación
    await getEvaluationHistory();
    
    _setLoading(false);
    return result;

  } on ApiException catch (e) {
    debugPrint('❌ Error del backend: ${e.message}');
    _setLoading(false);
    
    // Fallback a simulación
    final simulated = _simulateResultWithFeedback(evaluation);
    _latestResult = simulated;
    
    // Añadir evaluación simulada al historial local
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
      fechaEvaluacion: DateTime.now(),
      riskLevel: _getRiskLevelString(simulated.nivelRiesgo),
      probability: simulated.puntajeRiesgo,
    );
    _evaluations.insert(0, simulatedEval);
    notifyListeners();
    
    return simulated;
    
  } catch (e, stackTrace) {
    debugPrint('💥 Error inesperado: $e');
    debugPrint('📍 StackTrace: $stackTrace');
    _setLoading(false);
    return _simulateResultWithFeedback(evaluation);
  }
}

// Método auxiliar para convertir RiskLevel a String
String _getRiskLevelString(RiskLevel level) {
  switch (level) {
    case RiskLevel.bajo:
      return 'Bajo';
    case RiskLevel.medio:
      return 'Medio';
    case RiskLevel.alto:
      return 'Alto';
  }
}

  Future<void> getEvaluationHistory() async {
    _setLoading(true);

    try {
      debugPrint('📥 Cargando historial de evaluaciones...');
      
      final response = await _apiService.get(Constants.historyEndpoint);
      debugPrint('📋 Historial recibido: $response');

      if (response is! List) {
        debugPrint('⚠️ La respuesta NO es una lista');
        _evaluations = [];
        notifyListeners();
        return;
      }

      debugPrint('📋 Evaluaciones recibidas: ${(response as List).length}');

      _evaluations = (response as List).map((item) {
        debugPrint('📦 Mapeando: $item');
        
        return Evaluation(
          id: item['id']?.toString(),
          userId: item['user_id']?.toString() ?? '',
          peso: (item['weight_kg'] as num?)?.toDouble() ?? 0.0,
          altura: (item['height_cm'] as num?)?.toDouble() ?? 0.0,
          controlaConsumoSal: item['reduces_salt_intake'] == true ? 'Si' : 'No',
          consumoAlcohol: item['alcohol_in_last_30_days'] == true ? 'Si' : 'No',
          habitoTabaquismo: _mapSmokingHabitFromBackend(item['smoking_habit']),
          diasEstres: (item['stress_days_last_month'] as num?)?.toInt() ?? 0,
          actividadFisica: item['daily_physical_activity'] == true ? 'Si' : 'No',
          colesterolAlto: item['has_high_cholesterol'] == true ? 'Si' : 'No',
          diabetes: _mapDiabetesFromBackend(item['diabetes_diagnosis']),
          cigarrilloElectronico: _mapECigaretteFromBackend(item['e_cigarette_use']),
          fechaEvaluacion: DateTime.parse(item['created_at']),
          riskLevel: item['risk_level']?.toString(),                    // ✅ AÑADIR
          probability: (item['probability'] as num?)?.toDouble(),       // ✅ AÑADIR
        );
      }).toList();

      debugPrint('✅ Evaluaciones mapeadas: ${_evaluations.length}');
      notifyListeners();
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      _evaluations = [];
      notifyListeners();
    } finally {
      _setLoading(false);
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

  // Parsear nivel de riesgo desde backend
  RiskLevel _parseRiskLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'bajo':
      case 'low':
        return RiskLevel.bajo;
      case 'medio':
      case 'moderado':
      case 'medium':
        return RiskLevel.medio;
      case 'alto':
      case 'high':
        return RiskLevel.alto;
      default:
        return RiskLevel.bajo;
    }
  }

  // Simulación local si falla backend
  EvaluationResult _simulateResult(Evaluation evaluation) {
    double riskScore = 0.0;

    // IMC
    final imc = evaluation.imc;
    if (imc >= 30) {
      riskScore += 0.3;
    } else if (imc >= 25) {
      riskScore += 0.15;
    }

    // Otros factores (CORREGIDOS: ahora son booleanos)
    final diabetesVal = evaluation.diabetes == 'Si';
    final colesterolAltoVal = evaluation.colesterolAlto == 'Si';
    final habitoTabaquismoVal = evaluation.habitoTabaquismo == 'Fumador actual' || 
                                 evaluation.habitoTabaquismo == 'Fumador Ocasional';
    final actividadFisicaVal = evaluation.actividadFisica == 'Si';
    final consumoAlcoholVal = evaluation.consumoAlcohol == 'Si';

    if (diabetesVal) riskScore += 0.25;
    if (colesterolAltoVal) riskScore += 0.2;
    if (habitoTabaquismoVal) riskScore += 0.2;
    if (evaluation.diasEstres > 15) riskScore += 0.1;
    if (!actividadFisicaVal) riskScore += 0.1;
    if (consumoAlcoholVal) riskScore += 0.05;

    riskScore = riskScore.clamp(0.0, 1.0);

    RiskLevel riskLevel;
    if (riskScore < 0.3) {
      riskLevel = RiskLevel.bajo;
    } else if (riskScore < 0.6) {
      riskLevel = RiskLevel.medio;
    } else {
      riskLevel = RiskLevel.alto;
    }

    return EvaluationResult(
      evaluationId: evaluation.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      nivelRiesgo: riskLevel,
      puntajeRiesgo: riskScore,
      presionSistolica: '${120 + (riskScore * 40).round()} mmHg',
      presionDiastolica: '${80 + (riskScore * 20).round()} mmHg',
      descripcion: _getDescriptionForRiskLevel(riskLevel),
      recomendaciones: _getRecommendationsForRiskLevel(riskLevel),
      fechaResultado: DateTime.now(),
    );
  }

  // Generar feedbacks para cada campo
  List<FieldFeedback> _generateFieldFeedback(
    Evaluation evaluation,
    bool habitoTabaquismo,
    bool actividadFisica,
    bool colesterolAlto,
    bool diabetes,
    bool cigarrilloElectronico,
    bool consumoAlcohol,
    bool controlaConsumoSal,
  ) {
    final feedbacks = <FieldFeedback>[];

    // IMC
    final imc = evaluation.imc;
    if (imc < 18.5) {
      feedbacks.add(FieldFeedback(
        fieldKey: 'imc',
        title: 'IMC',
        valueDisplay: '${imc.toStringAsFixed(1)} (Bajo peso)',
        message: 'Tu IMC es bajo. Considera consultar un nutricionista.',
        status: FeedbackStatus.warning,
      ));
    } else if (imc >= 18.5 && imc < 25) {
      feedbacks.add(FieldFeedback(
        fieldKey: 'imc',
        title: 'IMC',
        valueDisplay: '${imc.toStringAsFixed(1)} (Normal)',
        message: '¡Excelente! Tu IMC está en rango saludable.',
        status: FeedbackStatus.good,
      ));
    } else if (imc >= 25 && imc < 30) {
      feedbacks.add(FieldFeedback(
        fieldKey: 'imc',
        title: 'IMC',
        valueDisplay: '${imc.toStringAsFixed(1)} (Sobrepeso)',
        message: 'Reducir 5-7% del peso corporal ayuda a disminuir el riesgo.',
        status: FeedbackStatus.warning,
      ));
    } else {
      feedbacks.add(FieldFeedback(
        fieldKey: 'imc',
        title: 'IMC',
        valueDisplay: '${imc.toStringAsFixed(1)} (Obesidad)',
        message: 'Es importante consultar con un profesional de la salud.',
        status: FeedbackStatus.bad,
      ));
    }

    // Tabaquismo
    if (habitoTabaquismo) {
      feedbacks.add(FieldFeedback(
        fieldKey: 'tabaquismo',
        title: 'Tabaquismo',
        valueDisplay: 'Fumador',
        message: 'Fumar aumenta significativamente el riesgo de hipertensión.',
        status: FeedbackStatus.bad,
      ));
    }

    // Actividad Física
    if (!actividadFisica) {
      feedbacks.add(FieldFeedback(
        fieldKey: 'actividad_fisica',
        title: 'Actividad Física',
        valueDisplay: 'Sedentario',
        message: 'La falta de ejercicio incrementa el riesgo cardiovascular.',
        status: FeedbackStatus.warning,
      ));
    } else {
      feedbacks.add(FieldFeedback(
        fieldKey: 'actividad_fisica',
        title: 'Actividad Física',
        valueDisplay: 'Activo',
        message: '¡Bien! Mantén la actividad física regular.',
        status: FeedbackStatus.good,
      ));
    }

    // Colesterol
    if (colesterolAlto) {
      feedbacks.add(FieldFeedback(
        fieldKey: 'colesterol',
        title: 'Colesterol',
        valueDisplay: 'Alto',
        message: 'El colesterol alto es un factor de riesgo importante.',
        status: FeedbackStatus.bad,
      ));
    }

    // Diabetes
    if (diabetes) {
      feedbacks.add(FieldFeedback(
        fieldKey: 'diabetes',
        title: 'Diabetes',
        valueDisplay: 'Presente',
        message: 'La diabetes aumenta el riesgo de hipertensión.',
        status: FeedbackStatus.bad,
      ));
    }

    // Alcohol
    if (consumoAlcohol) {
      feedbacks.add(FieldFeedback(
        fieldKey: 'alcohol',
        title: 'Consumo de Alcohol',
        valueDisplay: 'Consumidor',
        message: 'Limitar el consumo de alcohol ayuda a controlar la presión.',
        status: FeedbackStatus.warning,
      ));
    }

    // Sal
    if (!controlaConsumoSal) {
      feedbacks.add(FieldFeedback(
        fieldKey: 'sal',
        title: 'Control de Sal',
        valueDisplay: 'No controlado',
        message: 'Reducir el consumo de sal es clave para prevenir HTA.',
        status: FeedbackStatus.warning,
      ));
    }

    // Estrés
    if (evaluation.diasEstres > 15) {
      feedbacks.add(FieldFeedback(
        fieldKey: 'estres',
        title: 'Estrés',
        valueDisplay: '${evaluation.diasEstres} días/mes',
        message: 'El estrés crónico puede elevar la presión arterial.',
        status: FeedbackStatus.warning,
      ));
    }

    return feedbacks;
  }

  // Simulación con feedbacks
  EvaluationResult _simulateResultWithFeedback(Evaluation evaluation) {
    final habitoTabaquismoVal = evaluation.habitoTabaquismo == 'Fumador actual' || 
                                 evaluation.habitoTabaquismo == 'Fumador Ocasional';
    final actividadFisicaVal = evaluation.actividadFisica == 'Si';
    final colesterolAltoVal = evaluation.colesterolAlto == 'Si';
    final diabetesVal = evaluation.diabetes == 'Si';
    final cigarrilloElectronicoVal = evaluation.cigarrilloElectronico == 'Todos los días' || 
                                      evaluation.cigarrilloElectronico == 'Algunos días';
    final consumoAlcoholVal = evaluation.consumoAlcohol == 'Si';
    final controlaConsumoSalVal = evaluation.controlaConsumoSal == 'Si';

    final feedbacks = _generateFieldFeedback(
      evaluation,
      habitoTabaquismoVal,
      actividadFisicaVal,
      colesterolAltoVal,
      diabetesVal,
      cigarrilloElectronicoVal,
      consumoAlcoholVal,
      controlaConsumoSalVal,
    );

    final baseResult = _simulateResult(evaluation);
    
    return EvaluationResult(
      evaluationId: baseResult.evaluationId,
      nivelRiesgo: baseResult.nivelRiesgo,
      puntajeRiesgo: baseResult.puntajeRiesgo,
      presionSistolica: baseResult.presionSistolica,
      presionDiastolica: baseResult.presionDiastolica,
      descripcion: baseResult.descripcion,
      recomendaciones: baseResult.recomendaciones,
      fechaResultado: baseResult.fechaResultado,
      fieldFeedback: feedbacks,  // ← AÑADIDO
    );
  }

  String _getDescriptionForRiskLevel(RiskLevel level) {
    switch (level) {
      case RiskLevel.bajo:
        return 'Su riesgo de desarrollar hipertensión arterial es bajo. Mantenga sus hábitos saludables.';
      case RiskLevel.medio:
        return 'Su riesgo de desarrollar hipertensión arterial es moderado. Considere hacer algunos cambios en su estilo de vida.';
      case RiskLevel.alto:
        return 'Su riesgo de desarrollar hipertensión arterial es alto. Se recomienda consultar con un profesional de la salud.';
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

  String _mapSmokingHabitFromBackend(String? value) {
    if (value == null) return 'No Fumo';

    switch (value.toLowerCase()) {
      case 'fumo a diario':
        return 'Fumador actual';
      case 'fumo ocasionalmente':
        return 'Fumador Ocasional';
      case 'exfumador':
        return 'Ex Fumador';
      default:
        return 'No Fumo';
    }
  }

  String _mapDiabetesFromBackend(String? value) {
    if (value == null) return 'No';

    switch (value.toLowerCase()) {
      case 'si':
        return 'Si';
      case 'prediabetes':
        return 'Prediabetes';
      default:
        return 'No';
    }
  }

  String _mapECigaretteFromBackend(String? value) {
    if (value == null) return 'Nunca he usado';

    switch (value.toLowerCase()) {
      case 'diariamente':
        return 'Todos los días';
      case 'ocasionalmente':
        return 'Algunos días';
      case 'rara vez':
        return 'Rara vez';
      default:
        return 'Nunca he usado';
    }
  }
}