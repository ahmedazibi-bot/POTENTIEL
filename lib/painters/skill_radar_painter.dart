import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../widgets/ui.dart';

class SkillRadarPainter extends CustomPainter {
  SkillRadarPainter(this.values);
  final List<double> values;

  @override
  void paint(Canvas canvas, Size size) {
    const count = 5;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * .34;
    const start = -math.pi / 2;
    Offset point(int index, double scale) {
      final angle = start + 2 * math.pi * index / count;
      return center +
          Offset(math.cos(angle) * radius * scale,
              math.sin(angle) * radius * scale);
    }

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.line;
    for (final scale in [.25, .5, .75, 1.0]) {
      final path = Path()..moveTo(point(0, scale).dx, point(0, scale).dy);
      for (var i = 1; i < count; i++) {
        final p = point(i, scale);
        path.lineTo(p.dx, p.dy);
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }
    for (var i = 0; i < count; i++) {
      canvas.drawLine(center, point(i, 1), gridPaint);
    }
    final data = Path();
    for (var i = 0; i < count; i++) {
      final p = point(i, (values[i] / 100).clamp(.035, 1));
      if (i == 0) {
        data.moveTo(p.dx, p.dy);
      } else {
        data.lineTo(p.dx, p.dy);
      }
    }
    data.close();
    canvas.drawPath(
        data,
        Paint()
          ..color = AppColors.gold.withValues(alpha: .2)
          ..style = PaintingStyle.fill);
    canvas.drawPath(
        data,
        Paint()
          ..color = AppColors.gold
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5);
    for (var i = 0; i < count; i++) {
      final p = point(i, (values[i] / 100).clamp(.035, 1));
      canvas.drawCircle(p, 4, Paint()..color = AppColors.goldLight);
      final labelPoint = point(i, 1.27);
      final text = TextPainter(
        text: TextSpan(
            text: const ['QRN', 'FND', 'SEC', 'INC', 'GYM'][i],
            style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: .6)),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(
          canvas,
          Offset(
              labelPoint.dx - text.width / 2, labelPoint.dy - text.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant SkillRadarPainter oldDelegate) =>
      oldDelegate.values != values;
}
