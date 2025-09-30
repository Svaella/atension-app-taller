import 'package:flutter/material.dart';
import '../utils/colors.dart';

enum FeedbackStatus { good, warning, bad }

class FieldFeedback {
  final String fieldKey;         // identificador (imc, sal, alcohol, etc.)
  final String title;            // Título mostrado
  final String valueDisplay;     // Valor ingresado / calculado
  final String message;          // Mensaje/recomendación
  final FeedbackStatus status;   // Estado

  FieldFeedback({
    required this.fieldKey,
    required this.title,
    required this.valueDisplay,
    required this.message,
    required this.status,
  });

  Color get color {
    switch (status) {
      case FeedbackStatus.good:
        return AppColors.successGreen;
      case FeedbackStatus.warning:
        return AppColors.warningOrange;
      case FeedbackStatus.bad:
        return AppColors.errorRed;
    }
  }
}