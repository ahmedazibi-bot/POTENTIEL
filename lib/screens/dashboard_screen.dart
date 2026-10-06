import 'package:flutter/material.dart';

import '../painters/skill_radar_painter.dart';
import '../services/app_store.dart';
import '../widgets/ui.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.store});
  final AppStore store;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late String selectedWeek = widget.store.currentWeekKey;

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final metrics = store.metrics(selectedWeek);
    final rating = store.overall(selectedWeek);
    final isCurrentWeek = selectedWeek == store.currentWeekKey;
    final today = DateTime.now();
    final quests = _todayQuests(today);
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
      children: [
        Row(children: [
          const Expanded(child: SectionHeading('Weekly card')),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: store.weekKeys.contains(selectedWeek)
                  ? selectedWeek
                  : store.currentWeekKey,
              dropdownColor: AppColors.elevated,
              style: const TextStyle(
                  color: AppColors.goldLight,
                  fontWeight: FontWeight.w700,
                  fontSize: 12),
              icon: const Icon(Icons.expand_more, color: AppColors.gold),
              items: store.weekKeys
                  .map((week) =>
                      DropdownMenuItem(value: week, child: Text(week)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => selectedWeek = value ?? store.currentWeekKey),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        _FifaCard(score: rating, week: selectedWeek),
        const SizedBox(height: 14),
        AppCard(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
          child: Column(children: [
            const SectionHeading('Skill polygon · live weekly stats'),
            const SizedBox(height: 6),
            SizedBox(
                height: 226,
                child: CustomPaint(
                    size: Size.infinite,
                    painter: SkillRadarPainter(metrics.values
                        .map((value) => value.toDouble())
                        .toList()))),
            Wrap(
                spacing: 14,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: metrics.entries
                    .map((entry) =>
                        _MetricChip(label: entry.key, value: entry.value))
                    .toList()),
            const SizedBox(height: 8),
          ]),
        ),
        const SizedBox(height: 20),
        SectionHeading("Today's quest · ${weekdayName(today.weekday)}"),
        const SizedBox(height: 10),
        AppCard(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_questTitle(today.weekday),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(_questSubtitle(today.weekday),
                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            const SizedBox(height: 8),
            if (!isCurrentWeek)
              const Text('Archive view · checklist is read-only',
                  style: TextStyle(color: AppColors.gold, fontSize: 12))
            else
              ...quests.map((quest) => TaskRow(
                    key: ValueKey('${selectedWeek}_${quest.$1}'),
                    title: quest.$2,
                    done: store.isDone(quest.$1, selectedWeek),
                    enabled: isCurrentWeek,
                    onChanged: (value) =>
                        store.setDone(quest.$1, value ?? false, selectedWeek),
                  )),
            if (quests.isEmpty)
              const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                      'Recovery and planning day. Keep your weekly streak moving in Daily Tracker.',
                      style: TextStyle(color: AppColors.muted))),
          ]),
        ),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            const Icon(Icons.offline_bolt_rounded, color: AppColors.green),
            const SizedBox(width: 10),
            const Expanded(
                child: Text(
                    'Your data stays on this device. Progress saves automatically.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12))),
            Text('${metrics.values.where((v) => v == 100).length}/5',
                style: const TextStyle(
                    color: AppColors.gold, fontWeight: FontWeight.bold)),
          ]),
        ),
      ],
    );
  }

  List<(String, String)> _todayQuests(DateTime date) {
    final items = <(String, String)>[];
    if (date.weekday == DateTime.saturday) {
      for (final entry in fundamentalSubjects.entries) {
        items.add((
          'fnd_${entry.key}_prep',
          'Saturday intensive prep · ${entry.value}'
        ));
        items.add((
          AppStore.fundamentalSeriesTaskId(entry.key, date),
          'Assign / resolve exercise series · ${entry.value}'
        ));
      }
    } else {
      for (final entry in fundamentalSubjects.entries) {
        items.add((
          AppStore.fundamentalSeriesTaskId(entry.key, date),
          'Resolve exercise series · ${entry.value}'
        ));
      }
    }
    final secondaryForDay = switch (date.weekday) {
      DateTime.saturday => const ['sat_hydro', 'sat_hydrogeo'],
      DateTime.sunday => const ['sun_electro'],
      DateTime.tuesday => const ['tue_agro'],
      DateTime.wednesday => const ['wed_hydro', 'wed_hydrogeo'],
      _ => const <String>[],
    };
    for (final key in secondaryForDay) {
      final subjects = secondarySessions[key]!.join(' & ');
      items.add(('sec_$key', 'Night-before preparation · $subjects'));
    }
    if (date.weekday == DateTime.friday) {
      for (var page = 1; page <= 4; page++) {
        items.add(('quran_$page', 'Al-Baqarah · page $page of 4'));
      }
    }
    if (date.weekday == DateTime.tuesday) {
      final rotation = AppStore.rotationFor(date);
      for (var i = 0; i < gymExercises[rotation]!.length; i++) {
        items.add(('gym_$i', 'Gym · ${gymExercises[rotation]![i]}'));
      }
    }
    return items;
  }

  String _questTitle(int weekday) => switch (weekday) {
        DateTime.friday => 'Quran Hub · 4 pages',
        DateTime.tuesday =>
          'Training day · Week ${AppStore.rotationFor(DateTime.now())}',
        DateTime.saturday => 'Fundamentals intensive prep',
        _ => 'Build the weekly streak',
      };

  String _questSubtitle(int weekday) => switch (weekday) {
        DateTime.friday =>
          'Memorize and review Surah Al-Baqarah · 4/4 pages = 100%',
        DateTime.tuesday =>
          gymRoutines[AppStore.rotationFor(DateTime.now())]!.join('  ·  '),
        DateTime.saturday =>
          'Prepare all three fundamentals and assign the exercise series.',
        DateTime.sunday =>
          'Prepare Électrotechnique tonight for tomorrow morning.',
        DateTime.wednesday => 'Prepare Hydrologie and Hydrogéologie tonight.',
        _ =>
          'Check off today’s series and any scheduled night-before preparation.',
      };
}

class _FifaCard extends StatelessWidget {
  const _FifaCard({required this.score, required this.week});
  final int score;
  final String week;

  @override
  Widget build(BuildContext context) => Container(
        height: 190,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF54411E),
                Color(0xFF20252A),
                Color(0xFF111922)
              ]),
          border: Border.all(
              color: AppColors.gold.withValues(alpha: .72), width: 1.4),
          boxShadow: [
            BoxShadow(
                color: AppColors.gold.withValues(alpha: .10),
                blurRadius: 26,
                spreadRadius: 1)
          ],
        ),
        child: Stack(children: [
          const Positioned(
              right: -8,
              top: -14,
              child: Icon(Icons.workspace_premium_rounded,
                  size: 154, color: Color(0x18E9B949))),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.bolt_rounded,
                  color: AppColors.goldLight, size: 18),
              const SizedBox(width: 5),
              const Text('POTENTIEL',
                  style: TextStyle(
                      letterSpacing: 2,
                      color: AppColors.goldLight,
                      fontWeight: FontWeight.w900,
                      fontSize: 12)),
              const Spacer(),
              Text(week,
                  style: const TextStyle(color: AppColors.muted, fontSize: 11)),
            ]),
            const Spacer(),
            Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('$score',
                  style: const TextStyle(
                      fontSize: 62,
                      height: .95,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
              const Padding(
                  padding: EdgeInsets.only(left: 7, bottom: 8),
                  child: Text('OVR',
                      style: TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.3))),
              const Spacer(),
              const Icon(Icons.shield_rounded, size: 47, color: AppColors.gold),
            ]),
            const SizedBox(height: 4),
            Text(ratingTitle(score),
                style: const TextStyle(
                    color: AppColors.goldLight,
                    letterSpacing: 2,
                    fontSize: 15,
                    fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            const Text('HYDRAULICS ENGINEERING · ENSH',
                style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 9,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700)),
          ]),
        ]),
      );
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text('$value',
            style: const TextStyle(
                color: AppColors.gold,
                fontSize: 11,
                fontWeight: FontWeight.w800)),
      ]);
}
