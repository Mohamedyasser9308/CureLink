import 'package:curelink/core/widgets/app_bottom_nav_bar.dart';
import 'package:curelink/core/widgets/app_empty_state.dart';
import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../home/patient_home_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const PatientHomeScreen(),
          _TabPlaceholder(
            title: l10n.navSchedule,
            icon: Icons.event_note_outlined,
          ),
          _TabPlaceholder(
            title: l10n.navCalendar,
            icon: Icons.calendar_month_outlined,
          ),
          _TabPlaceholder(
            title: l10n.navNotifications,
            icon: Icons.notifications_none_rounded,
          ),
          _TabPlaceholder(
            title: l10n.navProfile,
            icon: Icons.person_outline_rounded,
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      body: AppEmptyState(title: title, icon: icon),
    );
  }
}
