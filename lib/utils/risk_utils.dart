import 'package:flutter/material.dart';
import '../models/evaluation_result_model.dart'; // para RiskLevel

// Acepta RiskLevel (enum) o String
Color getRiskColor(dynamic risk) {
  if (risk is RiskLevel) {
    switch (risk) {
      case RiskLevel.alto:
        return Colors.red;
      case RiskLevel.medio:
        return Colors.amber;
      case RiskLevel.bajo:
        return Colors.green;
    }
  }

  // Texto (ES/EN, con/ sin acentos)
  final v = (risk?.toString() ?? '')
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .trim();

  if (v.contains('alto') || v.contains('high')) return Colors.red;
  if (v.contains('medio') || v.contains('moderado') || v.contains('medium')) return Colors.amber;
  if (v.contains('bajo') || v.contains('low')) return Colors.green;
  return Colors.grey;
}