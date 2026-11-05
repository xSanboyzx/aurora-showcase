import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'journal_screen.dart';
import 'resources.dart';
import 'help_near_me.dart';
import 'ai_chat.dart';
import 'settings_screen.dart';
import '../config/app_mode.dart';
import '../demo/demo_info_screen.dart';

/// AuroraShell
/// Provides a persistent bottom navigation bar to switch between
/// primary application areas. Uses an IndexedStack to preserve state of
/// each tab (e.g. scroll position or in-progress form input).
class AuroraShell extends StatefulWidget {
  const AuroraShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  /// Programmatically switch tabs from anywhere inside the shell subtree.
  static void navigateTo(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_AuroraShellState>();
    state?._setIndex(index);
  }

  @override
  State<AuroraShell> createState() => _AuroraShellState();
}

class _AuroraShellState extends State<AuroraShell> {
  late int _index;

  late final _pages = <Widget>[
    const DashboardScreen(),
    const JournalScreen(),
    const ResourcesPage(),
    AppMode.isDemo
        ? const DemoInfoScreen(
            title: 'Help Nearby',
            description:
                'Location services are unavailable in the demo. No location permission is requested.')
        : const HelpNearMePage(),
    AppMode.isDemo ? const DemoChatScreen() : const AiChatScreen(),
    AppMode.isDemo
        ? const DemoInfoScreen(
            title: 'Settings',
            description:
                'Accounts and notifications are unavailable in this demo. Use Reset demo to restore the sample journal.')
        : const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Outer scaffold only provides nav bar; inner pages manage their own AppBars.
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          // Slightly smaller label text to reduce wrap on narrow phones
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 11),
          ),
        ),
        child: NavigationBar(
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: _index,
          onDestinationSelected: (i) => _setIndex(i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Journal',
            ),
            NavigationDestination(
              icon: Icon(Icons.library_books_outlined),
              selectedIcon: Icon(Icons.library_books_rounded),
              label: 'Resources',
            ),
            NavigationDestination(
              icon: Icon(Icons.place_outlined),
              selectedIcon: Icon(Icons.place_rounded),
              label: 'Help Nearby',
            ),
            NavigationDestination(
              icon: Icon(Icons.psychology_alt_outlined),
              selectedIcon: Icon(Icons.psychology_alt_rounded),
              label: 'Chat',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  void _setIndex(int i) {
    if (i < 0 || i >= _pages.length) return;
    setState(() => _index = i);
  }
}
