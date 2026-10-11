import 'package:flutter/material.dart';

import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';

class EvolutionChartCard extends StatelessWidget {
  final int evolutionPoints;
  final List<double> dataPoints;

  const EvolutionChartCard({
    super.key,
    required this.evolutionPoints,
    this.dataPoints = const [20, 25, 30, 42, 48, 55, 60, 68],
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = evolutionPoints < 0;
    final badgeText = '${isNegative ? "" : "+"}$evolutionPoints pts';
    final badgeColor = isNegative
        ? AppColors.criticalRed
        : AppColors.normalGreen;
    final badgeBg = isNegative
        ? AppColors.criticalRedLight
        : AppColors.normalGreenLight;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Évolution · 30 jours',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeText,
                  style: AppTextStyles.badge.copyWith(
                    color: badgeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Subtle horizontal bars on the left
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 1.5,
                    color: AppColors.borderLight,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 36,
                    height: 1.5,
                    color: AppColors.borderLight,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 24,
                    height: 1.5,
                    color: AppColors.borderLight,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Chart area
          SizedBox(
            height: 90,
            width: double.infinity,
            child: CustomPaint(
              painter: _ChartCurvePainter(
                points: dataPoints,
                lineColor: isNegative
                    ? AppColors.criticalRed.withValues(alpha: 0.3)
                    : AppColors.normalGreen.withValues(alpha: 0.3),
                gradientColor: isNegative
                    ? AppColors.criticalRed
                    : AppColors.normalGreen,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // X-axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '-30j',
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
              ),
              Text(
                '-15j',
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
              ),
              Text(
                'Auj.',
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartCurvePainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;
  final Color gradientColor;

  _ChartCurvePainter({
    required this.points,
    required this.lineColor,
    required this.gradientColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (points.length - 1);
    final minVal = points.reduce((a, b) => a < b ? a : b);
    final maxVal = points.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    double normalizeY(double val) {
      // Invert because canvas Y is top-down
      final normalized = (val - minVal) / range;
      return size.height - (normalized * (size.height - 20) + 10);
    }

    final startX = 0.0;
    final startY = normalizeY(points.first);
    path.moveTo(startX, startY);
    fillPath.moveTo(startX, size.height);
    fillPath.lineTo(startX, startY);

    for (int i = 0; i < points.length - 1; i++) {
      final p0X = i * stepX;
      final p0Y = normalizeY(points[i]);
      final p1X = (i + 1) * stepX;
      final p1Y = normalizeY(points[i + 1]);

      final controlX = (p0X + p1X) / 2;
      path.cubicTo(controlX, p0Y, controlX, p1Y, p1X, p1Y);
      fillPath.cubicTo(controlX, p0Y, controlX, p1Y, p1X, p1Y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Draw gradient under curve
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        gradientColor.withValues(alpha: 0.18),
        gradientColor.withValues(alpha: 0.01),
      ],
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw subtle line
    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _ChartCurvePainter oldDelegate) => true;
}
