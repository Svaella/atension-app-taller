import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../models/evaluation_result_model.dart';

class RiskGauge extends StatefulWidget {
  final RiskLevel riskLevel;
  final double riskPercentage;
  final double size;

  const RiskGauge({
    super.key,
    required this.riskLevel,
    required this.riskPercentage,
    this.size = 200,
  });

  @override
  State<RiskGauge> createState() => _RiskGaugeState();
}

class _RiskGaugeState extends State<RiskGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _animation = Tween<double>(
      begin: 0,
      end: widget.riskPercentage / 100,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size * 0.6, // Reducir altura ya que es un semicírculo
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: GaugePainter(
              progress: _animation.value,
              riskLevel: widget.riskLevel,
              getRiskColor: _getRiskColor,
            ),
          );
        },
      ),
    );
  }
}

class GaugePainter extends CustomPainter {
  final double progress;
  final RiskLevel riskLevel;
  final Color Function(RiskLevel) getRiskColor;

  GaugePainter({
    required this.progress,
    required this.riskLevel,
    required this.getRiskColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    const strokeWidth = 20.0;

    // Dibujar el fondo del gauge
    final backgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Redefinimos el gauge a un semicírculo frontal (180°) de -180° a 0° (izquierda a derecha)
    const startAngle = -math.pi; // -180°
    const sweep = math.pi; // 180° total
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      backgroundPaint,
    );

    // Dibujar las secciones de colores
  const sectionAngle = sweep / 3; // tres secciones iguales en semicírculo

    // Sección verde (bajo riesgo)
    final greenPaint = Paint()
      ..color = AppColors.riskLow
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sectionAngle,
      false,
      greenPaint,
    );

    // Sección amarilla (riesgo medio)
    final yellowPaint = Paint()
      ..color = AppColors.riskMedium
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + sectionAngle,
      sectionAngle,
      false,
      yellowPaint,
    );

    // Sección roja (alto riesgo)
    final redPaint = Paint()
      ..color = AppColors.riskHigh
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + sectionAngle * 2,
      sectionAngle,
      false,
      redPaint,
    );

    // Dibujar la aguja
  final needleLength = radius - 20;
  // Aguja recorre el semicírculo de -pi a 0 según progreso
  final needleAngle = startAngle + (sweep * progress);
    
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );

    final needlePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(center, needleEnd, needlePaint);

    // Dibujar el círculo central
    final centerPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 8, centerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}