import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bp_entry.dart';
import '../utils/bp_style.dart';

class TrendChart extends StatelessWidget {
  final List<BPEntry> entries;
  const TrendChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Text('Sin datos', style: TextStyle(color: Colors.white70))),
      );
    }

    final data = [...entries]..sort((a, b) => a.takenAt.compareTo(b.takenAt));
    final spotsSys = <FlSpot>[];
    final spotsDia = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      spotsSys.add(FlSpot(i.toDouble(), data[i].systolic.toDouble()));
      spotsDia.add(FlSpot(i.toDouble(), data[i].diastolic.toDouble()));
    }

    const yMin = 40.0;
    const yMax = 200.0;

    String bottomLabel(double x) {
      final i = x.round();
      if (i < 0 || i >= data.length) return '';
      return DateFormat('MM-dd').format(data[i].takenAt);
    }

    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.fromLTRB(16, 18, 12, 12),
      child: LineChart(
        LineChartData(
          minY: yMin,
          maxY: yMax,
          minX: 0,
          maxX: (data.length - 1).toDouble(),
          backgroundColor: Colors.transparent,
          gridData: FlGridData(
            show: true,
            horizontalInterval: 28,
            getDrawingHorizontalLine: (v) => FlLine(
              color: Colors.white.withOpacity(0.12),
              strokeWidth: 1,
            ),
            drawVerticalLine: false,
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 28,
                reservedSize: 30,
                getTitlesWidget: (v, m) => Text(
                  v.toInt().toString(),
                  style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, m) => Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    bottomLabel(v),
                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          // NO usar 'const' aquí; .withOpacity no es const
          rangeAnnotations: RangeAnnotations(horizontalRangeAnnotations: [
            HorizontalRangeAnnotation(y1: 140, y2: yMax, color: const Color(0xFFEF4444).withOpacity(0.10)),
            HorizontalRangeAnnotation(y1: 130, y2: 140, color: const Color(0xFFFB923C).withOpacity(0.12)),
            HorizontalRangeAnnotation(y1: 120, y2: 130, color: const Color(0xFFF59E0B).withOpacity(0.12)),
            HorizontalRangeAnnotation(y1: yMin, y2: 120, color: const Color(0xFF22C55E).withOpacity(0.10)),
          ]),
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 10,
              getTooltipItems: (spots) {
                if (spots.isEmpty) return [];
                final i = spots.first.x.round();
                final e = data[i];
                final vis = bpVisualFromCategory(e.category);
                final when = DateFormat("dd/MM/yyyy • HH:mm", 'es').format(e.takenAt);
                return [
                  LineTooltipItem(
                    '${vis.label}\n$when\n${e.systolic}/${e.diastolic} mmHg',
                    TextStyle(color: vis.color, fontWeight: FontWeight.w800, fontSize: 12),
                  )
                ];
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spotsSys,
              isCurved: true,
              barWidth: 3,
              color: Colors.white,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  final vis = bpVisualFromCategory(data[spot.x.round()].category);
                  return FlDotCirclePainter(
                    radius: 3.6,
                    color: vis.color,
                    strokeColor: Colors.white,
                    strokeWidth: 1.2,
                  );
                },
              ),
            ),
            LineChartBarData(
              spots: spotsDia,
              isCurved: true,
              barWidth: 2,
              color: Colors.white.withOpacity(0.6),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 3.0,
                  color: Colors.white70,
                  strokeColor: Colors.white,
                  strokeWidth: 1.0,
                ),
              ),
            ),
          ],
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
          ),
        ),
      ),
    );
  }
}