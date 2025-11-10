import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../utils/colors.dart';
import '../services/onboarding_service.dart';
import '../widgets/user_menu_button.dart';

class RiskGuideScreen extends StatelessWidget {
  final String riskLevel; // 'alto' | 'medio' | 'bajo' (o variantes)
  const RiskGuideScreen({super.key, required this.riskLevel});

  String _norm(String v) => v
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .trim();

  @override
  Widget build(BuildContext context) {
    final r = _norm(riskLevel);
    late String title, message;
    late Color color;

    if (r.contains('alto') || r.contains('high')) {
      title = 'Peligro';
      message = 'Según tus datos, tu riesgo es ALTO. Consulta con un profesional y refuerza hábitos saludables.';
      color = Colors.red;
    } else if (r.contains('medio') || r.contains('moderado') || r.contains('medium')) {
      title = 'Cuidado';
      message = 'Según tus datos, tu riesgo es MODERADO. Refuerza hábitos y monitorea tu presión.';
      color = Colors.amber[700]!;
    } else {
      title = 'Tranquilo';
      message = 'Según tus datos, tu riesgo es BAJO. Mantén hábitos saludables y controles de rutina.';
      color = Colors.green[600]!;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('aTensión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [UserMenuButton()],
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.3)),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  await context.read<OnboardingService>().markEvaluationDone();
                  if (context.mounted) context.go('/home');
                },
                child: const Text('Entendido'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}