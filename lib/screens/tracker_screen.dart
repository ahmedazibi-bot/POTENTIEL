import 'package:flutter/material.dart';

import '../services/app_store.dart';
import '../widgets/ui.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key, required this.store});
  final AppStore store;

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  final _milestoneController = TextEditingController();

  @override
  void dispose() {
    _milestoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final rotation = AppStore.rotationFor(DateTime.now());
    return ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          const Text('DAILY TRACKER',
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1)),
          const SizedBox(height: 4),
          const Text('Your complete weekly training plan · stored offline',
              style: TextStyle(color: AppColors.muted)),
          const SizedBox(height: 18),
          AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const SectionHeading('Fondamentales · Saturday intensive prep'),
                const SizedBox(height: 4),
                const Text(
                    'Prepare lectures and TDs, assign the exercise series, then check off each series as you resolve it.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 7),
                for (final subject in fundamentalSubjects.entries) ...[
                  TaskRow(
                      title: '${subject.value} · lecture + TD prep',
                      subtitle: 'Saturday preparation',
                      done: store.isDone('fnd_${subject.key}_prep'),
                      onChanged: (v) =>
                          store.setDone('fnd_${subject.key}_prep', v ?? false)),
                  TaskRow(
                      title: '${subject.value} · exercise series',
                      subtitle:
                          'Today · ${weekdayName(DateTime.now().weekday)}',
                      done: store.isDone(AppStore.fundamentalSeriesTaskId(
                          subject.key, DateTime.now())),
                      onChanged: (v) => store.setDone(
                          AppStore.fundamentalSeriesTaskId(
                              subject.key, DateTime.now()),
                          v ?? false)),
                ],
              ])),
          const SizedBox(height: 14),
          AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const SectionHeading('Secondary modules · night-before check'),
                const SizedBox(height: 4),
                const Text(
                    'Complete preparation the evening before the listed morning session.',
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
                const SizedBox(height: 7),
                for (final entry in secondarySessions.entries)
                  TaskRow(
                    title: entry.value.join(' & '),
                    subtitle:
                        'Prepare ${_dayForSession(entry.key)} night · ready for next morning',
                    done: store.isDone('sec_${entry.key}'),
                    onChanged: (v) =>
                        store.setDone('sec_${entry.key}', v ?? false),
                  ),
              ])),
          const SizedBox(height: 14),
          AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                SectionHeading(
                    'Tuesday gym · 4-week rotation · Week $rotation'),
                const SizedBox(height: 5),
                Text(gymRoutines[rotation]!.join('  ·  '),
                    style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                for (var i = 0; i < gymExercises[rotation]!.length; i++)
                  TaskRow(
                      title: gymExercises[rotation]![i],
                      subtitle: 'Tuesday workout',
                      done: store.isDone('gym_$i'),
                      onChanged: (v) => store.setDone('gym_$i', v ?? false)),
              ])),
          const SizedBox(height: 14),
          AppCard(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const SectionHeading('Incubator · innovation hub'),
                const SizedBox(height: 12),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(
                      (store.incubatorMinutes ~/ 60).toString().padLeft(2, '0'),
                      style: const TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.white)),
                  const Padding(
                      padding: EdgeInsets.only(bottom: 7),
                      child: Text(' h ',
                          style: TextStyle(color: AppColors.muted))),
                  Text((store.incubatorMinutes % 60).toString().padLeft(2, '0'),
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold)),
                  const Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text(' min this week',
                          style:
                              TextStyle(color: AppColors.muted, fontSize: 12))),
                ]),
                const SizedBox(height: 7),
                ProgressLine(value: store.incubatorMinutes / 300),
                const SizedBox(height: 5),
                const Text('Weekly target · 5 hours',
                    style: TextStyle(color: AppColors.muted, fontSize: 11)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _LogButton(
                      label: '+ 30 min',
                      onPressed: () => store.addIncubatorMinutes(30)),
                  _LogButton(
                      label: '+ 1 hour',
                      onPressed: () => store.addIncubatorMinutes(60)),
                ]),
                const SizedBox(height: 15),
                Row(children: [
                  Expanded(
                      child: TextField(
                    controller: _milestoneController,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        hintText: 'Record a milestone…',
                        hintStyle: const TextStyle(color: AppColors.muted),
                        filled: true,
                        fillColor: AppColors.elevated,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 12)),
                    onSubmitted: (_) => _saveMilestone(),
                  )),
                  const SizedBox(width: 8),
                  IconButton.filled(
                      onPressed: _saveMilestone,
                      style: IconButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.background),
                      icon: const Icon(Icons.add)),
                ]),
                const SizedBox(height: 4),
                for (final milestone in store.milestones)
                  ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.flag_rounded,
                          color: AppColors.gold, size: 18),
                      title: Text(milestone,
                          style: const TextStyle(fontSize: 13))),
              ])),
        ]);
  }

  String _dayForSession(String key) => switch (key.split('_').first) {
        'sat' => 'Saturday',
        'sun' => 'Sunday',
        'tue' => 'Tuesday',
        'wed' => 'Wednesday',
        _ => 'scheduled',
      };

  Future<void> _saveMilestone() async {
    await widget.store.addMilestone(_milestoneController.text);
    _milestoneController.clear();
    if (mounted) FocusScope.of(context).unfocus();
  }
}

class _LogButton extends StatelessWidget {
  const _LogButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.goldLight,
            side: BorderSide(color: AppColors.gold.withValues(alpha: .5)),
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10)),
      );
}
