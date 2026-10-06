import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF090D12);
  static const surface = Color(0xFF111922);
  static const elevated = Color(0xFF17212B);
  static const gold = Color(0xFFE9B949);
  static const goldLight = Color(0xFFFFD978);
  static const muted = Color(0xFF91A0AE);
  static const green = Color(0xFF55D6A0);
  static const line = Color(0xFF283541);
}

class AppCard extends StatelessWidget {
  const AppCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.line.withValues(alpha: .75)),
          boxShadow: const [
            BoxShadow(
                color: Color(0x24000000), blurRadius: 18, offset: Offset(0, 8))
          ],
        ),
        child: child,
      );
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
              child: Text(title.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 12,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w800,
                      color: AppColors.muted))),
          if (trailing != null) trailing!,
        ],
      );
}

class TaskRow extends StatelessWidget {
  const TaskRow(
      {super.key,
      required this.title,
      required this.done,
      required this.onChanged,
      this.subtitle,
      this.enabled = true});
  final String title;
  final String? subtitle;
  final bool done;
  final bool enabled;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) => Opacity(
        opacity: enabled ? 1 : .48,
        child: CheckboxListTile(
          value: done,
          onChanged: enabled ? onChanged : null,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          activeColor: AppColors.gold,
          checkColor: AppColors.background,
          title: Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: done ? TextDecoration.lineThrough : null,
                  color: done ? AppColors.muted : Colors.white)),
          subtitle: subtitle == null
              ? null
              : Text(subtitle!,
                  style: const TextStyle(color: AppColors.muted, fontSize: 12)),
          dense: true,
        ),
      );
}

class ProgressLine extends StatelessWidget {
  const ProgressLine(
      {super.key,
      required this.value,
      this.height = 7,
      this.color = AppColors.gold});
  final double value;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            minHeight: height,
            backgroundColor: AppColors.elevated,
            color: color),
      );
}

String ratingTitle(int score) {
  if (score >= 90) return 'GOATED';
  if (score >= 80) return 'OVERPOWERED';
  if (score >= 65) return 'ELITE';
  if (score >= 45) return 'RISING';
  return 'IN TRAINING';
}

String weekdayName(int weekday) => const [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ][weekday];
