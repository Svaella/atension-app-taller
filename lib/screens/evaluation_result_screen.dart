import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../utils/constants.dart';
import '../widgets/custom_button.dart';
import '../widgets/risk_gauge.dart';
import '../widgets/info_card.dart';
import '../services/evaluation_service.dart';
import '../services/auth_service.dart';
import '../models/evaluation_result_model.dart';
import '../widgets/top_navigation_menu.dart';
import '../models/field_feedback_model.dart';
import '../widgets/user_menu_button.dart';

class EvaluationResultScreen extends StatefulWidget {
  const EvaluationResultScreen({super.key});

  @override
  State<EvaluationResultScreen> createState() => _EvaluationResultScreenState();
}

class _EvaluationResultScreenState extends State<EvaluationResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkResult();
    });
  }

  void _checkResult() {
    final evaluationService = Provider.of<EvaluationService>(context, listen: false);
    if (evaluationService.latestResult == null) {
      // Si no hay resultado, redirigir a evaluación
  context.go('/evaluation-form');
    }
  }

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

  IconData _iconForStatus(FeedbackStatus status) {
    switch (status) {
      case FeedbackStatus.good:
        return Icons.check_circle_outline;
      case FeedbackStatus.warning:
        return Icons.error_outline;
      case FeedbackStatus.bad:
        return Icons.warning_amber_outlined;
    }
  }
  // _iconForStatus eliminado porque ya no se muestran tarjetas de feedback individuales.

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'aTensión',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => context.push('/about'),
          ),
          const UserMenuButton(),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(52),
          child: TopNavigationMenu(activeTab: 'evaluacion'),
        ),
      ),
      body: Consumer<EvaluationService>(
        builder: (context, evaluationService, child) {
          final result = evaluationService.latestResult;
          
          if (result == null) {
            return const Center(
              child: Text(
                'No hay resultados disponibles',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Título principal
                  Text(
                    'Resultado',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Título
                  Text(
                    'Su riesgo de tener Hipertensión arterial es',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Gauge de riesgo
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardBackground : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isDark 
                            // ignore: deprecated_member_use
                            ? Colors.black.withOpacity(0.3)
                            // ignore: deprecated_member_use
                            : Colors.black.withOpacity(0.15),
                          blurRadius: isDark ? 8 : 12,
                          offset: const Offset(0, 4),
                        ),
                        if (!isDark)
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Transform.translate(
                          offset: const Offset(0, 20),
                          child: RiskGauge(
                            riskLevel: result.nivelRiesgo,
                            riskPercentage: result.riskPercentage,
                            size: 280,
                          ),
                        ),
                        Transform.translate(
                          offset: const Offset(0, -20),
                          child: Text(
                            result.riskLevelDisplay,
                            style: TextStyle(
                              color: _getRiskColor(result.nivelRiesgo),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Disclaimer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardBackground : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      Constants.disclaimerText,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.grey[800],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Datos del usuario + feedback unificado
                  Consumer2<AuthService, EvaluationService>(
                    builder: (context, authService, evalService, child) {
                      final user = authService.currentUser;
                      if (user == null) return const SizedBox();
                      final fbList = result.fieldFeedback ?? [];
                      // buscamos el feedback de IMC para mostrarlo como tarjeta dedicada
                      final imcFb = fbList.firstWhere(
                        (f) => f.fieldKey == 'imc',
                        orElse: () => FieldFeedback(
                          fieldKey: 'imc',
                          title: 'IMC',
                          valueDisplay: '28.3 (Sobrepeso)',
                          message: 'Reducir 5-7% del peso corporal ayuda a disminuir el riesgo.',
                          status: FeedbackStatus.warning,
                        ),
                      );
                      // resto sin IMC
                      final others = fbList.where((f) => f.fieldKey != 'imc').toList();

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardBackground : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: isDark 
                                // ignore: deprecated_member_use
                                ? Colors.black.withOpacity(0.3)
                                // ignore: deprecated_member_use
                                : Colors.black.withOpacity(0.15),
                              blurRadius: isDark ? 8 : 12,
                              offset: const Offset(0, 4),
                            ),
                            if (!isDark)
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                'Tus Datos',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            InfoCard(
                              title: 'Tu Edad: ${user.edad}',
                              subtitle: 'La HTA empieza a desarrollarse comúnmente en las personas mayores de 40años',
                              backgroundColor: AppColors.successGreen,
                            ),
                            const SizedBox(height: 12),
                            InfoCard(
                              title: 'Tu IMC: ${imcFb.valueDisplay}',
                              subtitle: 'El Índice de Masa Corporal (IMC) se calcula con peso y altura (kg/m²). ${imcFb.message}',
                              backgroundColor: imcFb.color,
                              icon: _iconForStatus(imcFb.status),
                            ),
                            if (others.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              ...others.map((f) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: InfoCard(
                                      title: '${f.title}: ${f.valueDisplay}',
                                      subtitle: f.message,
                                      backgroundColor: f.color,
                                      icon: _iconForStatus(f.status),
                                    ),
                                  )),
                            ]
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40),
                  
                  // Botones de acción
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Ver Historial',
                      onPressed: () => context.go('/history'),
                      backgroundColor: AppColors.primaryRed,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Nueva Evaluación',
                      onPressed: () {
                        evaluationService.clearLatestResult();
                        context.go('/evaluation-form');
                      },
                      backgroundColor: Colors.transparent,
                      borderColor: AppColors.primaryRed,
                      textColor: AppColors.primaryRed,
                    ),
                  ),
                  
                  // (Eliminado) Tabs inferiores duplicadas: se usa TopNavigationMenu superior
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}