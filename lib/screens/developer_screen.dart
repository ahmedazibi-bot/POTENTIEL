import 'package:flutter/material.dart';

import '../widgets/ui.dart';

class DeveloperProfileScreen extends StatelessWidget {
  const DeveloperProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          const Text('DEVELOPER',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4B3A1D),
                    Color(0xFF1A222A),
                    AppColors.surface
                  ]),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.gold.withValues(alpha: .7)),
            ),
            child: Column(
              children: [
                Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold, width: 2),
                        color: AppColors.elevated),
                    child: const Icon(Icons.code_rounded,
                        size: 54, color: AppColors.gold)),
                const SizedBox(height: 16),
                const Text('AZIBI AHMED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1)),
                const SizedBox(height: 4),
                const Text('أحمد عزيبي',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 9),
                const Text(
                    'Hydraulics Engineering Student (ENSH)\n& Software Developer',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.muted, height: 1.45)),
                const SizedBox(height: 20),
                const Divider(color: AppColors.line),
                const _ProfileLine(
                    icon: Icons.mail_outline_rounded,
                    text: 'ahmedazibi.dev@gmail.com'),
                const _ProfileLine(
                    icon: Icons.code_rounded,
                    text: 'github.com/ahmedazibi-bot'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.offline_bolt_rounded, color: AppColors.green),
                SizedBox(width: 12),
                Expanded(
                    child: Text(
                        'POTENTIEL is designed to work offline. Your checklists, weekly scores, incubator hours, milestones, and history are saved locally on this device.',
                        style: TextStyle(color: AppColors.muted, height: 1.5))),
              ],
            ),
          ),
        ],
      );
}

class _ProfileLine extends StatelessWidget {
  const _ProfileLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          Icon(icon, color: AppColors.gold, size: 18),
          const SizedBox(width: 10),
          Expanded(
              child: SelectableText(text,
                  style: const TextStyle(color: Colors.white, fontSize: 13)))
        ]),
      );
}
