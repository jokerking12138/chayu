import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/brew_screen.dart';
import 'screens/guide_screen.dart';
import 'screens/home_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/library_screen.dart';
import 'state/app_store.dart';
import 'theme/tea_theme.dart';

class TeaApp extends StatefulWidget {
  const TeaApp({super.key});

  @override
  State<TeaApp> createState() => _TeaAppState();
}

class _TeaAppState extends State<TeaApp> {
  final AppStore _store = AppStore();

  @override
  void initState() {
    super.initState();
    _store.load();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppStoreScope(
      store: _store,
      child: MaterialApp(
        title: '茶愉',
        debugShowCheckedModeBanner: false,
        theme: buildTeaTheme(),
        home: const RootShell(),
      ),
    );
  }
}

class AppStoreScope extends InheritedNotifier<AppStore> {
  const AppStoreScope({
    super.key,
    required AppStore store,
    required super.child,
  }) : super(notifier: store);

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStoreScope>();
    assert(scope != null, 'AppStoreScope 未挂载');
    return scope!.notifier!;
  }

  static AppStore read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppStoreScope>();
    assert(scope != null, 'AppStoreScope 未挂载');
    return scope!.notifier!;
  }
}

/// 让任意页面都能切换底部 Tab（例如详情页"用它泡一泡"）。
class TabSwitcher extends InheritedWidget {
  const TabSwitcher({
    super.key,
    required this.go,
    required super.child,
  });

  final void Function(int index) go;

  static TabSwitcher? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<TabSwitcher>();

  @override
  bool updateShouldNotify(TabSwitcher oldWidget) => false;
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  void _go(int index) {
    if (index == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onNavigate: _go),
      const LibraryScreen(),
      const BrewScreen(),
      const GuideScreen(),
      const JournalScreen(),
    ];

    return TabSwitcher(
      go: _go,
      child: Scaffold(
      backgroundColor: TeaPalette.cream,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: TeaPalette.line)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _go,
          destinations: const <NavigationDestination>[
            NavigationDestination(
              icon: Icon(Icons.spa_outlined),
              selectedIcon: Icon(Icons.spa),
              label: '首页',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: '图鉴',
            ),
            NavigationDestination(
              icon: Icon(Icons.timer_outlined),
              selectedIcon: Icon(Icons.timer),
              label: '茶席',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore),
              label: '指南',
            ),
            NavigationDestination(
              icon: Icon(Icons.edit_note_outlined),
              selectedIcon: Icon(Icons.edit_note),
              label: '茶记',
            ),
          ],
        ),
      ),
      ),
    );
  }
}
