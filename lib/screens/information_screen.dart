import 'package:flutter/material.dart';
import '../utils/colors.dart';

class InformationScreen extends StatelessWidget {
  final bool embedded; // true: se muestra dentro de Home
  const InformationScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    // Contenido real de la pantalla (sin AppBar ni la franja “Información”)
    final content = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título principal centrado
            Text(
              'Hipertensión Arterial',
              style: TextStyle(
                color: Theme.of(context).textTheme.displayMedium?.color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 20),
            
            // Descripción centrada
            Text(
              'La Hipertensión Arterial (HTA) es una enfermedad silenciosa que ataca sigilosamente, donde se considera que alguien tiene presión alta cuando:',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 30),
            
            // Ilustración mejorada
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryRed,
                    Color(0xFF8B0000), // Rojo más oscuro
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: AppColors.primaryRed.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.medical_services,
                size: 80,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Cambiar crossAxisAlignment para el resto del contenido
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                  // Tarjetas informativas
                  _buildInfoCard(
                    'Presión Sistólica',
                    '> 140 mmHg',
                    'La presión sistólica es la fuerza que ejerce la sangre contra las paredes de las arterias cuando el corazón late.',
                    AppColors.primaryRed,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoCard(
                    'Presión Diastólica', 
                    '> 90 mmHg',
                    'La presión diastólica es la fuerza que ejerce la sangre contra las paredes de las arterias cuando el corazón descansa entre latidos.',
                    AppColors.primaryRed,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Información adicional
                  Text(
                    'Factores de Riesgo',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildRiskFactorsList(context),
                  
                  const SizedBox(height: 30),
                  
                  Text(
                    'Recomendaciones Generales',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildRecommendationsList(context),
                  
                  const SizedBox(height: 30),
                  
                  // Disclaimer
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? AppColors.cardBackground : Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warningOrange),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.warning,
                              color: AppColors.warningOrange,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Importante',
                              style: TextStyle(
                                color: AppColors.warningOrange,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Esta información es solo educativa y no sustituye la consulta médica profesional. Si tienes dudas sobre tu salud cardiovascular, consulta con un médico.',
                          style: TextStyle(
                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.grey[800],
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    if (embedded) {
      // Dentro de Home: NO AppBar y NO cabecera “Información”
      return SafeArea(child: content);
    }

    // Navegación directa: conservar AppBar y cabecera si la usabas
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'aTensión',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Cabecera grande “Información” SOLO cuando no está embebido
            Container(
              width: double.infinity,
              color: AppColors.primaryRed,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: const Text(
                'Información',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(child: content),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, String description, Color color) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título y medida en la misma fila
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // Descripción ocupando toda la tarjeta
        Text(
          description,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
  }

  Widget _buildRiskFactorsList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
  final riskFactors = [
    'Edad avanzada (mayor de 40 años)',
    'Antecedentes familiares',
    'Sobrepeso y obesidad',
    'Vida sedentaria',
    'Consumo excesivo de sal',
    'Consumo excesivo de alcohol',
    'Tabaquismo',
    'Estrés crónico',
    'Diabetes',
    'Colesterol alto',
  ];

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? AppColors.cardBackground : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: isDark 
        ? null 
        : Border.all(color: Colors.grey[300]!, width: 1),
      boxShadow: isDark 
        ? null 
        : [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
    ),
    child: Column(
      children: riskFactors.map((factor) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.circle,
              size: 8,
              color: AppColors.primaryRed,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                factor,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.grey[800],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    ),
  );
  }

  Widget _buildRecommendationsList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
  final recommendations = [
    'Mantener un peso saludable',
    'Realizar ejercicio regularmente (30 min diarios)',
    'Seguir una dieta baja en sal',
    'Limitar el consumo de alcohol',
    'No fumar',
    'Controlar el estrés',
    'Dormir adecuadamente',
    'Realizarse chequeos médicos regulares',
    'Monitorear la presión arterial',
    'Tomar medicamentos según prescripción',
  ];

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? AppColors.cardBackground : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: isDark 
        ? null 
        : Border.all(color: Colors.grey[300]!, width: 1),
      boxShadow: isDark 
        ? null 
        : [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
    ),
    child: Column(
      children: recommendations.map((recommendation) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.check,
              size: 16,
              color: AppColors.successGreen,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                recommendation,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.grey[800],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    ),
  );
  }

}