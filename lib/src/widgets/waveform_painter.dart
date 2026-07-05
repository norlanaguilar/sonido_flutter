import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WaveformPainter extends CustomPainter {
  final double progress; // 0.0 – 1.0
  final Color activeColor;
  final Color inactiveColor;
  final int barCount;

  const WaveformPainter({
    required this.progress,
    this.activeColor = AppColors.waveformActive,
    this.inactiveColor = AppColors.waveformInactive,
    this.barCount = 60,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final activePaint = Paint()
      ..color = activeColor
      ..strokeCap = StrokeCap.round;
    final inactivePaint = Paint()
      ..color = inactiveColor
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / (barCount * 2 - 1);
    final progressX = size.width * progress;

    for (int i = 0; i < barCount; i++) {
      final x = i * barWidth * 2 + barWidth / 2;
      // Pseudo-random height using sine harmonics — deterministic per bar
      final t = i / barCount;
      final height = (math.sin(t * math.pi * 8 + 1.2) * 0.35 +
              math.sin(t * math.pi * 3 + 0.5) * 0.4 +
              math.sin(t * math.pi * 15 + 2.1) * 0.15 +
              0.5) *
          size.height.clamp(4.0, size.height);

      final clampedHeight = height.clamp(4.0, size.height);
      final top = (size.height - clampedHeight) / 2;
      final bottom = top + clampedHeight;

      final paint = x <= progressX ? activePaint : inactivePaint;
      paint.strokeWidth = barWidth * 0.7;

      canvas.drawLine(
        Offset(x, top),
        Offset(x, bottom),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class WaveformWidget extends StatelessWidget {
  final double progress;
  final double height;

  const WaveformWidget({
    super.key,
    required this.progress,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: WaveformPainter(progress: progress.clamp(0.0, 1.0)),
        child: const SizedBox.expand(),
      ),
    );
  }
}
