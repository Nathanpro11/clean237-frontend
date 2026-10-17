import 'package:flutter/material.dart';

import '../../features/administration_reporting/models/zone_model.dart';
import '../styles/app_colors.dart';
import '../styles/app_text_styles.dart';

class ZoneRiskLevel {
  final ZoneStatus status;
  final Color color;
  final Color backgroundColor;

  const ZoneRiskLevel({
    required this.status,
    required this.color,
    required this.backgroundColor,
  });

  static ZoneRiskLevel fromScore(int score) {
    if (score >= 80) {
      return const ZoneRiskLevel(
        status: ZoneStatus.critical,
        color: AppColors.criticalRed,
        backgroundColor: AppColors.criticalRedLight,
      );
    } else if (score >= 40) {
      return const ZoneRiskLevel(
        status: ZoneStatus.warning,
        color: AppColors.warningOrange,
        backgroundColor: AppColors.warningOrangeLight,
      );
    } else {
      return const ZoneRiskLevel(
        status: ZoneStatus.normal,
        color: AppColors.normalGreen,
        backgroundColor: AppColors.normalGreenLight,
      );
    }
  }

  static ZoneStatus statusFor(int score) => fromScore(score).status;
  static Color colorFor(int score) => fromScore(score).color;
  static Color bgColorFor(int score) => fromScore(score).backgroundColor;
}

class ZoneScoreGauge extends StatelessWidget {
  final int score;
  final double size;
  final double strokeWidth;
  final Color? colorOverride;

  const ZoneScoreGauge({
    super.key,
    required this.score,
    this.size = 54,
    this.strokeWidth = 4.5,
    this.colorOverride,
  });

  Color _getColor() => colorOverride ?? ZoneRiskLevel.colorFor(score);

  @override
  Widget build(BuildContext context) {
    final ringColor = _getColor();
    final isGiant = size > 90;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _CircularGaugePainter(
              color: ringColor,
              strokeWidth: strokeWidth,
            ),
          ),
          Text(
            '$score',
            style: isGiant
                ? AppTextStyles.scoreGiant.copyWith(
                    color: AppColors.textPrimary,
                  )
                : AppTextStyles.metricNumber.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: size * 0.38,
                    fontWeight: FontWeight.w800,
                  ),
          ),
        ],
      ),
    );
  }
}

class _CircularGaugePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _CircularGaugePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _CircularGaugePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
