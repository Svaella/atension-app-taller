import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../utils/colors.dart';
import '../widgets/evaluation_card.dart';
import '../widgets/top_navigation_menu.dart';
import '../services/evaluation_service.dart';
import '../services/auth_service.dart';
import '../models/evaluation_result_model.dart';
import '../widgets/user_menu_button.dart';
import '../utils/risk_utils.dart';

class HistoryScreen extends StatelessWidget {
  final bool embedded;
  const HistoryScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    // Construye el contenido del historial
    final content = SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Aquí puedes agregar el contenido que ya tenías en el body de Scaffold
            Expanded(
              child: Consumer<EvaluationService>(
                builder: (context, evaluationService, child) {
                  if (evaluationService.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
                      ),
                    );
                  }

                  if (evaluationService.evaluations.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 80,
                            color: AppColors.textSecondary,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'No tienes evaluaciones aún',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Realiza tu primera evaluación para ver tu historial',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: evaluationService.evaluations.length,
                          itemBuilder: (context, index) {
                            final evaluation = evaluationService.evaluations[index];
                            
                            // ✅ CORREGIDO: Usar riskLevel REAL del backend
                            final riskLevel = evaluation.riskLevelEnum;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: EvaluationCard(
                                date: DateFormat('dd/MM/yyyy').format(evaluation.fechaEvaluacion),
                                riskLevel: riskLevel,
                                onTap: () {
                                  _showEvaluationDetail(context, evaluation, riskLevel);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (embedded) return content;

    return Scaffold(
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
          preferredSize: Size.fromHeight(56),
          child: TopNavigationMenu(activeTab: 'historial'),
        ),
      ),
      body: content,
    );
  }

  void _showEvaluationDetail(BuildContext context, evaluation, RiskLevel riskLevel) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardBackground : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.textSecondary : Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Evaluación del ${DateFormat('dd/MM/yyyy').format(evaluation.fechaEvaluacion)}',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
                  ),
                ],
              ),
            ),
            
            // Contenido
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Estado de riesgo
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: getRiskColor(riskLevel),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Riesgo: ${_getRiskLevelText(riskLevel)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Datos de la evaluación
                    _buildDetailSection(
                      context,
                      'Datos Físicos',
                      [
                        'Peso: ${evaluation.peso} kg',
                        'Altura: ${evaluation.altura} cm',
                        'IMC: ${evaluation.imc.toStringAsFixed(1)}',
                      ],
                    ),
                    
                    _buildDetailSection(
                      context,
                      'Hábitos',
                      [
                        'Controla sal: ${evaluation.controlaConsumoSal}',
                        'Consume alcohol: ${evaluation.consumoAlcohol}',
                        'Tabaquismo: ${evaluation.habitoTabaquismo}',
                        'Actividad física: ${evaluation.actividadFisica}',
                        'Cigarrillo electrónico: ${evaluation.cigarrilloElectronico}',
                      ],
                    ),
                    
                    _buildDetailSection(
                      context,
                      'Condiciones Médicas',
                      [
                        'Colesterol alto: ${evaluation.colesterolAlto}',
                        'Diabetes: ${evaluation.diabetes}',
                        'Días de estrés: ${evaluation.diasEstres}',
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(BuildContext context, String title, List<String> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                item,
                style: TextStyle(
                  color: isDark ? AppColors.textSecondary : Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _getRiskLevelText(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.bajo:
        return 'Bajo';
      case RiskLevel.medio:
        return 'Moderado';
      case RiskLevel.alto:
        return 'Alto';
    }
  }
}