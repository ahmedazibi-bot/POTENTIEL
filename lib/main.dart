import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/archive_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/developer_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/tracker_screen.dart';
import 'services/app_store.dart';
import 'widgets/ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  final box = await Hive.openBox<dynamic>('potentiel_offline');
  runApp(PotentielApp(store: AppStore(box)));
}

class PotentielApp extends StatelessWidget {
  const PotentielApp({super.key, required this.store});
  final AppStore store;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'POTENTIEL',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: const ColorScheme.dark(
              primary: AppColors.gold,
              secondary: AppColors.green,
              surface: AppColors.surface),
          appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.background,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false),
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.gold.withValues(alpha: .15),
            labelTextStyle:
                WidgetStateProperty.resolveWith((states) => TextStyle(
                      fontSize: 10,
                      fontWeight: states.contains(WidgetState.selected)
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: states.contains(WidgetState.selected)
                          ? AppColors.gold
                          : AppColors.muted,
                    )),
          ),
          checkboxTheme: CheckboxThemeData(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5))),
          useMaterial3: true,
        ),
        home: _AppShell(store: store),
      );
}

class _AppShell extends StatefulWidget {
  const _AppShell({required this.store});
  final AppStore store;

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(store: widget.store),
      TrackerScreen(store: widget.store),
      QuranScreen(store: widget.store),
      ArchiveScreen(store: widget.store),
      const DeveloperProfileScreen(),
    ];
    final titles = [
      'POTENTIEL',
      'DAILY TRACKER',
      'QURAN HUB',
      'ARCHIVE',
      'DEVELOPER'
    ];
    return AnimatedBuilder(
      animation: widget.store,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Row(children: [
            const Icon(Icons.bolt_rounded, color: AppColors.gold),
            const SizedBox(width: 7),
            Text(titles[_index],
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontSize: 15)),
          ]),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 17),
                child: Center(
                    child: Text(widget.store.currentWeekKey,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 11))))
          ],
        ),
        body: IndexedStack(index: _index, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const [
            NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard'),
            NavigationDestination(
                icon: Icon(Icons.checklist_outlined),
                selectedIcon: Icon(Icons.checklist_rounded),
                label: 'Tracker'),
            NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book_rounded),
                label: 'Quran'),
            NavigationDestination(
                icon: Icon(Icons.insights_outlined),
                selectedIcon: Icon(Icons.insights_rounded),
                label: 'Archive'),
            NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
