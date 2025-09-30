import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../models/evaluation_result_model.dart';

class EvaluationCard extends StatelessWidget {
  final String date;
  final RiskLevel riskLevel;
  final VoidCallback? onTap;

  const EvaluationCard({
    super.key,
    required this.date,
    required this.riskLevel,
    this.onTap,
  });

  Color _getRiskColor(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.bajo:
        return AppColors.riskLow;
      case RiskLevel.medio:
        return AppColors.riskMedium;
      case RiskLevel.alto:
        return AppColors.riskHigh;
    }
  }

  String _getRiskText(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.bajo:
        return 'Bajo';
      case RiskLevel.medio:
        return 'Moderado';
      case RiskLevel.alto:
        return 'Alto';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardBackground : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: isDark 
                // ignore: deprecated_member_use
                ? Colors.black.withOpacity(0.3)
                // ignore: deprecated_member_use
                : Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Indicador de color de riesgo
            Container(
              width: 12,
              height: 60,
              decoration: BoxDecoration(
                color: _getRiskColor(riskLevel),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Información de la evaluación
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    date,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Riesgo: ${_getRiskText(riskLevel)}',
                    style: TextStyle(
                      color: _getRiskColor(riskLevel),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Ícono de flecha
            Icon(
              Icons.arrow_forward_ios,
              color: isDark ? Colors.grey[500] : Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}