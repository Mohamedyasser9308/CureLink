import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curelink/core/widgets/app_bottom_nav_bar.dart';
import 'package:curelink/core/widgets/mode_switcher.dart';
import 'package:curelink/features/calendar/presentation/pages/calendar_page.dart';
import 'package:curelink/features/schedule/presentation/pages/schedule_page.dart';
import 'package:flutter/material.dart';

import '../../patient/patient_home_screen.dart';
import '../../caregiver/presentation/pages/caregiver_home_screen.dart';
import '../../profile/presentation/pages/profile_page.dart';
import '../../notifications/presentation/notifications_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.patientUid, required this.role});

  final String patientUid;
  final String role;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.role == 'caregiver') {
      return _buildShell(context, AppMode.caregiver);
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.patientUid)
          .snapshots(),
      builder: (context, snapshot) {
        final activeMode =
            (snapshot.data?.data()?['activeMode'] as String?)?.toLowerCase() ==
                'caregiver'
            ? AppMode.caregiver
            : AppMode.patient;
        return _buildShell(context, activeMode);
      },
    );
  }

  Widget _buildShell(BuildContext context, AppMode activeMode) {
    final caregiverHome = activeMode == AppMode.caregiver;

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          if (caregiverHome)
            CaregiverHomeScreen(
              patientUid: widget.patientUid,
              role: widget.role,
              showModeSwitcher: widget.role == 'both',
              onModeChanged: _setMode,
            )
          else
            PatientHomeScreen(
              mode: activeMode,
              showModeSwitcher: widget.role == 'both',
              onModeChanged: _setMode,
            ),

          // Schedule
          const SchedulePage(),

          // Calendar
          CalendarPage(patientUid: widget.patientUid),

          // Notifications
          NotificationsPage(patientUid: widget.patientUid),

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

  Future<void> _setMode(AppMode mode) async {
    if (widget.role != 'both') return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.patientUid)
        .update({'activeMode': mode.name});
  }
}
