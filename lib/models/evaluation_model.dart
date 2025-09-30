class Evaluation {
  final String? id;
  final String userId;
  final double peso;
  final double altura;
  final String controlaConsumoSal;
  final String consumoAlcohol;
  final String habitoTabaquismo;
  final int diasEstres;
  final String actividadFisica;
  final String colesterolAlto;
  final String diabetes;
  final String cigarrilloElectronico;
  final DateTime fechaEvaluacion;

  Evaluation({
    this.id,
    required this.userId,
    required this.peso,
    required this.altura,
    required this.controlaConsumoSal,
    required this.consumoAlcohol,
    required this.habitoTabaquismo,
    required this.diasEstres,
    required this.actividadFisica,
    required this.colesterolAlto,
    required this.diabetes,
    required this.cigarrilloElectronico,
    required this.fechaEvaluacion,
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString() ?? '',
      peso: (json['peso'] ?? 0).toDouble(),
      altura: (json['altura'] ?? 0).toDouble(),
      controlaConsumoSal: json['controla_consumo_sal'] ?? '',
      consumoAlcohol: json['consumo_alcohol'] ?? '',
      habitoTabaquismo: json['habito_tabaquismo'] ?? '',
      diasEstres: json['dias_estres'] ?? 0,
      actividadFisica: json['actividad_fisica'] ?? '',
      colesterolAlto: json['colesterol_alto'] ?? '',
      diabetes: json['diabetes'] ?? '',
      cigarrilloElectronico: json['cigarrillo_electronico'] ?? '',
      fechaEvaluacion: DateTime.parse(json['fecha_evaluacion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'peso': peso,
      'altura': altura,
      'controla_consumo_sal': controlaConsumoSal,
      'consumo_alcohol': consumoAlcohol,
      'habito_tabaquismo': habitoTabaquismo,
      'dias_estres': diasEstres,
      'actividad_fisica': actividadFisica,
      'colesterol_alto': colesterolAlto,
      'diabetes': diabetes,
      'cigarrillo_electronico': cigarrilloElectronico,
      'fecha_evaluacion': fechaEvaluacion.toIso8601String(),
    };
  }

  double get imc {
    if (altura <= 0) return 0;
    final alturaMetros = altura / 100;
    return peso / (alturaMetros * alturaMetros);
  }

  String get imcCategoria {
    final imcValue = imc;
    if (imcValue < 18.5) return 'Bajo peso';
    if (imcValue < 25) return 'Peso normal';
    if (imcValue < 30) return 'Sobrepeso';
    return 'Obesidad';
  }
}