import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/profile_summary.dart';
import '../../services/profile_service.dart';

Color _riskColor(RiskLevel level) {
  switch (level) {
    case RiskLevel.high:
      return const Color(0xFFD13434); // rojo
    case RiskLevel.obesity:
      return const Color(0xFFE67E22); // naranja
    case RiskLevel.moderate:
      return const Color(0xFFE6B800); // amarillo
    case RiskLevel.low:
    return const Color(0xFF1CC062); // verde
  }
}

IconData _riskIcon(RiskFactor risk) {
  switch (risk.iconKey) {
    case 'smoking':
      return Icons.smoking_rooms;
    case 'sedentary':
      return Icons.directions_walk;
    case 'bmi':
      return Icons.monitor_weight;
    case 'alcohol':
      return Icons.local_bar;
    case 'cholesterol':
      return Icons.favorite;
    case 'diabetes':
      return Icons.bloodtype;
    case 'salt':
      return Icons.grain;
    case 'stress':
      return Icons.psychology;
    case 'vaping':
      return Icons.cloud;
    default:
      return Icons.health_and_safety;
  }
}

class TusDatosScreen extends StatelessWidget {
  const TusDatosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('📱 TusDatosScreen.build');
    final profile = context.watch<ProfileService>();
    debugPrint('📊 ProfileService: isLoading=${profile.isLoading}, summary=${profile.summary}');

    if (profile.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final summary = profile.summary;
    if (summary == null) {
      return const Center(
        child: Text('Sin evaluación disponible', style: TextStyle(color: Colors.white70)),
      );
    }

    // Filtrar solo riesgos en rojo (high, obesity) o amarillo (moderate)
    final risksToShow = summary.risks.where((risk) {
      return risk.level == RiskLevel.high ||
          risk.level == RiskLevel.obesity ||
          risk.level == RiskLevel.moderate;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeaderCard(summary: summary),
          const SizedBox(height: 24),
          _NextEvaluation(days: summary.daysUntilNext),
          const SizedBox(height: 24),
          const Text(
            'Riesgos encontrados',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          if (risksToShow.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1CC062),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.black87, size: 28),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'No se encontraron riesgos',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ),
                ],
              ),
            )
          else
            ...risksToShow.map((risk) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _RiskCard(risk: risk),
                )),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final ProfileSummary summary;
  const _HeaderCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFBFC0C2),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(
              summary.age >= 60 ? Icons.person_outline : Icons.person,
              color: Colors.black87,
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edad: ${summary.age} años',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18)),
                const SizedBox(height: 4),
                Text('Sexo: ${summary.gender}',
                    style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'IMC ${summary.bmi.toStringAsFixed(1)} · ${summary.bmiCategory}',
                    style: const TextStyle(
                        color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RiskCard extends StatelessWidget {
  final RiskFactor risk;
  const _RiskCard({required this.risk});

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(risk.level);
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => _RiskDetailDialog(risk: risk, color: color),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            // ignore: deprecated_member_use
            BoxShadow(color: color.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Icon(_riskIcon(risk), color: Colors.black87, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                risk.title,
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w800, fontSize: 18),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

class _RiskDetailDialog extends StatelessWidget {
  final RiskFactor risk;
  final Color color;
  const _RiskDetailDialog({required this.risk, required this.color});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFEEEEEE),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      title: Row(
        children: [
          Icon(_riskIcon(risk), color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              risk.title,
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(risk.description,
                style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.4)),
            const SizedBox(height: 16),
            const Text('Recomendaciones:',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w800, fontSize: 14)),
            const SizedBox(height: 8),
            ...risk.recommendations.map(
              (rec) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Colors.black, fontSize: 14)),
                    Expanded(
                      child: Text(rec,
                          style: const TextStyle(fontSize: 14, color: Colors.black87)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Entendido'),
          ),
        ),
      ],
    );
  }
}

class _NextEvaluation extends StatelessWidget {
  final int days;
  const _NextEvaluation({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Días para la siguiente evaluación: $days',
              style: const TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}