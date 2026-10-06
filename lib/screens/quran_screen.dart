import 'package:flutter/material.dart';

import '../services/app_store.dart';
import '../widgets/ui.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final pagesDone = List.generate(4, (i) => store.isDone('quran_${i + 1}'))
        .where((done) => done)
        .length;
    final friday = DateTime.now().weekday == DateTime.friday;
    return ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          const Text('QURAN HUB',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 4),
          const Text('Friday focus · memorize and review Surah Al-Baqarah',
              style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 18),
          AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: .13),
                          borderRadius: BorderRadius.circular(15)),
                      child: const Icon(Icons.menu_book_rounded,
                          color: AppColors.gold, size: 26)),
                  const SizedBox(width: 12),
                  const Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text('Surah Al-Baqarah',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800)),
                        Text('Weekly goal · 4 pages',
                            style:
                                TextStyle(color: AppColors.muted, fontSize: 12))
                      ])),
                  Text('$pagesDone/4',
                      style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w900,
                          fontSize: 18)),
                ]),
                const SizedBox(height: 18),
                ProgressLine(
                    value: pagesDone / 4, height: 9, color: AppColors.green),
                const SizedBox(height: 9),
                Text(
                    pagesDone == 4
                        ? '100% · weekly goal completed'
                        : '${pagesDone * 25}% complete · every page adds 25%',
                    style:
                        const TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 12),
                for (var page = 1; page <= 4; page++)
                  TaskRow(
                    title: 'Page $page of 4',
                    subtitle: page == 1
                        ? 'Memorization + review'
                        : 'Review + reinforce memorization',
                    done: store.isDone('quran_$page'),
                    enabled: friday,
                    onChanged: (value) =>
                        store.setDone('quran_$page', value ?? false),
                  ),
                if (!friday)
                  const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                          'Reserved for Fridays. Page check-offs unlock on Friday.',
                          style:
                              TextStyle(color: AppColors.gold, fontSize: 12))),
              ])),
          const SizedBox(height: 14),
          const AppCard(
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.spa_rounded, color: AppColors.gold),
            SizedBox(width: 12),
            Expanded(
                child: Text(
                    'A focused weekly ritual: complete all four pages to earn a full QRN skill score on your FIFA card.',
                    style: TextStyle(color: AppColors.muted, height: 1.5))),
          ])),
        ]);
  }
}
