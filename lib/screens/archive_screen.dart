import 'package:flutter/material.dart';

import '../services/app_store.dart';
import '../widgets/ui.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final weeks = store.weekKeys.reversed.toList();
    final scores = weeks.map((week) => store.overall(week)).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      children: [
        const Text('ARCHIVE & ANALYTICS',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: .5)),
        const SizedBox(height: 4),
        const Text('Compare weekly ratings and keep your progress in view.',
            style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 18),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading('Overall rating history'),
              const SizedBox(height: 10),
              SizedBox(
                  height: 190,
                  child: CustomPaint(
                      size: Size.infinite, painter: _ArchiveChart(scores))),
              if (weeks.isEmpty)
                const Text('Your weekly cards will appear here.',
                    style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 8),
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.circle, color: AppColors.gold, size: 9),
                SizedBox(width: 6),
                Text('Overall score · /100',
                    style: TextStyle(color: AppColors.muted, fontSize: 11))
              ]),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const SectionHeading('Weekly FIFA cards'),
        const SizedBox(height: 10),
        for (final week in weeks.reversed)
          Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _WeekCard(week: week, store: store)),
      ],
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.week, required this.store});
  final String week;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final score = store.overall(week);
    final metrics = store.metrics(week);
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 62,
            decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(13),
                border:
                    Border.all(color: AppColors.gold.withValues(alpha: .5))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$score',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 23,
                        color: Colors.white)),
                const Text('OVR',
                    style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 9,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(week, style: const TextStyle(fontWeight: FontWeight.w800)),
                Text(ratingTitle(score),
                    style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 11,
                        letterSpacing: .6)),
                const SizedBox(height: 7),
                Text(
                    metrics.entries
                        .map((e) => '${e.key} ${e.value}')
                        .join('   ·   '),
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 10)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.muted),
        ],
      ),
    );
  }
}

class _ArchiveChart extends CustomPainter {
  const _ArchiveChart(this.values);
  final List<int> values;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 28.0;
    const right = 10.0;
    const top = 12.0;
    const bottom = 23.0;
    final chart =
        Rect.fromLTRB(left, top, size.width - right, size.height - bottom);
    final grid = Paint()
      ..color = AppColors.line
      ..strokeWidth = 1;
    for (var i = 0; i <= 4; i++) {
      final y = chart.bottom - chart.height * i / 4;
      canvas.drawLine(Offset(chart.left, y), Offset(chart.right, y), grid);
      final label = TextPainter(
          text: TextSpan(
              text: '${i * 25}',
              style: const TextStyle(color: AppColors.muted, fontSize: 9)),
          textDirection: TextDirection.ltr)
        ..layout();
      label.paint(canvas, Offset(0, y - label.height / 2));
    }
    if (values.isEmpty) return;
    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? chart.center.dx
          : chart.left + chart.width * i / (values.length - 1);
      points.add(Offset(
          x, chart.bottom - chart.height * values[i].clamp(0, 100) / 100));
    }
    if (points.length > 1) {
      final line = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        line.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(
          line,
          Paint()
            ..color = AppColors.gold
            ..strokeWidth = 2.5
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round);
    }
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], 4, Paint()..color = AppColors.goldLight);
      final label = TextPainter(
          text: TextSpan(
              text: '${values[i]}',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold)),
          textDirection: TextDirection.ltr)
        ..layout();
      label.paint(
          canvas, Offset(points[i].dx - label.width / 2, points[i].dy - 16));
    }
  }

  @override
  bool shouldRepaint(covariant _ArchiveChart oldDelegate) =>
      oldDelegate.values != values;
}
