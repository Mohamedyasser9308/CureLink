
import 'package:curelink/core/widgets/app_bottom_nav_bar.dart';
import 'package:curelink/core/widgets/app_empty_state.dart';
import 'package:curelink/core/widgets/app_scaffold.dart';
import 'package:curelink/features/calendar/presentation/pages/calendar_page.dart';
import 'package:curelink/features/schedule/presentation/pages/schedule_page.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../home/patient_home_screen.dart';
import '../../profile/presentation/pages/profile_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.patientUid,
  });

  final String patientUid;

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

          // Schedule
          const SchedulePage(),

          // Calendar
          CalendarPage(patientUid: widget.patientUid),

          // Notifications
          _TabPlaceholder(
            title: l10n.navNotifications,
            icon: Icons.notifications_none_rounded,
          ),

          // Profile
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _index,
        onTap: (index) {
          setState(() => _index = index);
        },
      ),
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: title,
      body: AppEmptyState(
        title: title,
        icon: icon,
      ),
    );
  }
}
