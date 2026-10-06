import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

const fundamentalSubjects = <String, String>{
  'mmc': 'MMC',
  'hydraulique': 'Hydraulique générale',
  'mecanique': 'Mécanique appliquée',
};

const secondarySessions = <String, List<String>>{
  'sat_hydro': ['Hydrologie'],
  'sat_hydrogeo': ['Hydrogéologie'],
  'sun_electro': ['Électrotechnique'],
  'tue_agro': ['Agropédologie'],
  'wed_hydro': ['Hydrologie'],
  'wed_hydrogeo': ['Hydrogéologie'],
};

const gymRoutines = <int, List<String>>{
  1: ['Dorsaux', 'Biceps', 'Abdominaux', 'Avant-bras'],
  2: ['Épaules', 'Triceps', 'Abdominaux', 'Avant-bras'],
  3: ['Pectoraux', 'Triceps', 'Abdominaux', 'Avant-bras'],
  4: ['Jambes', 'Abdominaux', 'Avant-bras'],
};

const gymExercises = <int, List<String>>{
  1: ['Tractions / tirage', 'Rowing', 'Curl biceps', 'Abdos + avant-bras'],
  2: [
    'Développé épaules',
    'Élévations latérales',
    'Extensions triceps',
    'Abdos + avant-bras'
  ],
  3: [
    'Développé couché',
    'Développé incliné',
    'Extensions triceps',
    'Abdos + avant-bras'
  ],
  4: [
    'Squats',
    'Fentes',
    'Soulevé de terre jambes tendues',
    'Abdos + avant-bras'
  ],
};

class AppStore extends ChangeNotifier {
  AppStore(this._box) {
    final saved = _box.get('state');
    if (saved is String) {
      try {
        _state = Map<String, dynamic>.from(jsonDecode(saved) as Map);
      } catch (_) {
        _state = <String, dynamic>{};
      }
    }
    _state.putIfAbsent('weeks', () => <String, dynamic>{});
    ensureWeek(currentWeekKey);
  }

  final Box<dynamic> _box;
  Map<String, dynamic> _state = <String, dynamic>{};

  String get currentWeekKey => weekKey(DateTime.now());

  static String weekKey(DateTime date) {
    final thursday = date.add(Duration(days: 4 - date.weekday));
    final firstThursday = DateTime(thursday.year, 1, 4);
    final firstWeekThursday =
        firstThursday.add(Duration(days: 4 - firstThursday.weekday));
    final week = 1 + thursday.difference(firstWeekThursday).inDays ~/ 7;
    return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
  }

  static int rotationFor(DateTime date) {
    final match = RegExp(r'W(\d+)').firstMatch(weekKey(date));
    final week = int.tryParse(match?.group(1) ?? '') ?? 1;
    return ((week - 1) % 4) + 1;
  }

  static String fundamentalSeriesTaskId(String subject, DateTime date) {
    final day =
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    return 'fnd_${subject}_series_$day';
  }

  List<String> get weekKeys {
    final keys = (_state['weeks'] as Map).keys.cast<String>().toSet();
    keys.add(currentWeekKey);
    return keys.toList()..sort((a, b) => b.compareTo(a));
  }

  Map<String, dynamic> weekData([String? key]) {
    final weeks = _state['weeks'] as Map;
    final id = key ?? currentWeekKey;
    final existing = weeks[id];
    if (existing is Map) return Map<String, dynamic>.from(existing);
    final fresh = <String, dynamic>{
      'tasks': <String, dynamic>{},
      'incubatorMinutes': 0,
      'milestones': <String>[]
    };
    weeks[id] = fresh;
    return fresh;
  }

  void ensureWeek(String key) {
    final weeks = _state['weeks'] as Map;
    weeks.putIfAbsent(
        key,
        () => <String, dynamic>{
              'tasks': <String, dynamic>{},
              'incubatorMinutes': 0,
              'milestones': <String>[],
            });
  }

  bool isDone(String taskId, [String? key]) {
    final tasks = weekData(key)['tasks'] as Map;
    return tasks[taskId] == true;
  }

  Future<void> setDone(String taskId, bool value, [String? key]) async {
    final week = weekData(key);
    final tasks = Map<String, dynamic>.from(week['tasks'] as Map);
    tasks[taskId] = value;
    week['tasks'] = tasks;
    (_state['weeks'] as Map)[key ?? currentWeekKey] = week;
    await _save();
  }

  int get incubatorMinutes =>
      (weekData()['incubatorMinutes'] as num?)?.toInt() ?? 0;

  Future<void> addIncubatorMinutes(int minutes) async {
    final week = weekData();
    week['incubatorMinutes'] = incubatorMinutes + minutes;
    (_state['weeks'] as Map)[currentWeekKey] = week;
    await _save();
  }

  List<String> get milestones =>
      (weekData()['milestones'] as List? ?? const []).cast<String>();

  Future<void> addMilestone(String value) async {
    final text = value.trim();
    if (text.isEmpty) return;
    final week = weekData();
    final items = List<String>.from(week['milestones'] as List? ?? const []);
    items.insert(0, text);
    week['milestones'] = items.take(20).toList();
    (_state['weeks'] as Map)[currentWeekKey] = week;
    await _save();
  }

  Map<String, int> metrics([String? key]) {
    final id = key ?? currentWeekKey;
    int checked(Iterable<String> ids) =>
        ids.where((task) => isDone(task, id)).length;
    final fundamentals = <String>[
      ...fundamentalSubjects.keys.map((subject) => 'fnd_${subject}_prep'),
      for (var day = 0; day < 7; day++)
        for (final subject in fundamentalSubjects.keys)
          fundamentalSeriesTaskId(
              subject, _mondayForWeekKey(id).add(Duration(days: day))),
    ];
    final secondary = secondarySessions.keys.map((session) => 'sec_$session');
    final rotation = _rotationFromKey(id);
    final gym = List.generate(gymExercises[rotation]!.length, (i) => 'gym_$i');
    final quran = List.generate(4, (i) => 'quran_${i + 1}');
    final minutes = (weekData(id)['incubatorMinutes'] as num?)?.toInt() ?? 0;
    return {
      'QRN': (checked(quran) * 100 ~/ quran.length),
      'FND': (checked(fundamentals) * 100 ~/ fundamentals.length),
      'SEC': (checked(secondary) * 100 ~/ secondary.length),
      'INC': (minutes * 100 ~/ 300).clamp(0, 100).toInt(),
      'GYM': (checked(gym) * 100 ~/ gym.length),
    };
  }

  int overall([String? key]) {
    final values = metrics(key).values;
    return values.reduce((a, b) => a + b) ~/ values.length;
  }

  static int _rotationFromKey(String key) {
    final match = RegExp(r'W(\d+)').firstMatch(key);
    final week = int.tryParse(match?.group(1) ?? '') ?? 1;
    return ((week - 1) % 4) + 1;
  }

  static DateTime _mondayForWeekKey(String key) {
    final match = RegExp(r'^(\d{4})-W(\d{2})$').firstMatch(key);
    final year = int.tryParse(match?.group(1) ?? '') ?? DateTime.now().year;
    final week = int.tryParse(match?.group(2) ?? '') ?? 1;
    final januaryFourth = DateTime(year, 1, 4);
    final firstMonday =
        januaryFourth.subtract(Duration(days: januaryFourth.weekday - 1));
    return firstMonday.add(Duration(days: (week - 1) * 7));
  }

  Future<void> _save() async {
    await _box.put('state', jsonEncode(_state));
    notifyListeners();
  }
}
