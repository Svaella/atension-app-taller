class EvaluationDraft {
  final double peso;
  final double altura;
  final String controlaConsumoSal;
  final String consumoAlcohol;
  final String? habitoTabaquismo; // Ahora opcional para permitir paso por paso
  final int? diasEstres; // todavía no capturado en paso 1
  final String? actividadFisica;
  final String? colesterolAlto;
  final String? diabetes;
  final String? cigarrilloElectronico;

  EvaluationDraft({
    required this.peso,
    required this.altura,
    required this.controlaConsumoSal,
    required this.consumoAlcohol,
    this.habitoTabaquismo,
    this.diasEstres,
    this.actividadFisica,
    this.colesterolAlto,
    this.diabetes,
    this.cigarrilloElectronico,
  });

  EvaluationDraft copyWith({
    String? habitoTabaquismo,
    int? diasEstres,
    String? actividadFisica,
    String? colesterolAlto,
    String? diabetes,
    String? cigarrilloElectronico,
  }) {
    return EvaluationDraft(
      peso: peso,
      altura: altura,
      controlaConsumoSal: controlaConsumoSal,
      consumoAlcohol: consumoAlcohol,
      habitoTabaquismo: habitoTabaquismo ?? this.habitoTabaquismo,
      diasEstres: diasEstres ?? this.diasEstres,
      actividadFisica: actividadFisica ?? this.actividadFisica,
      colesterolAlto: colesterolAlto ?? this.colesterolAlto,
      diabetes: diabetes ?? this.diabetes,
      cigarrilloElectronico: cigarrilloElectronico ?? this.cigarrilloElectronico,
    );
  }
}
