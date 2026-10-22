import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../l10n/app_localizations.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key, required this.patientUid});

  final String patientUid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    return AppScaffold(
      title: l10n.navNotifications,
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(patientUid)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, notificationSnapshot) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(patientUid)
            .collection('doses')
            .where('scheduledAt', isGreaterThanOrEqualTo: Timestamp.fromDate(now.subtract(const Duration(days: 30))))
            .where('scheduledAt', isLessThan: Timestamp.fromDate(now.add(const Duration(days: 30))))
            .orderBy('scheduledAt', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError || notificationSnapshot.hasError) {
            final error = snapshot.error ?? notificationSnapshot.error;
            return Center(child: Text('${l10n.navNotifications}: $error'));
          }
          if (!snapshot.hasData || !notificationSnapshot.hasData) return const Center(child: CircularProgressIndicator());
          final doses = snapshot.data!.docs;
          final notices = notificationSnapshot.data!.docs;
          if (doses.isEmpty && notices.isEmpty) {
            return Center(child: Text(l10n.emptyMedicationsTitle));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notices.length + doses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index < notices.length) {
                final notice = notices[index].data();
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active_outlined),
                    title: Text(notice['title'] as String? ?? l10n.navNotifications),
                    subtitle: Text(notice['body'] as String? ?? ''),
                  ),
                );
              }
              index -= notices.length;
              final data = doses[index].data();
              final scheduled = (data['scheduledAt'] as Timestamp?)?.toDate();
              final status = data['status'] as String? ?? 'upcoming';
              final title = data['medicationName'] as String? ?? l10n.medicationName;
              final dosage = data['dosage'] as String? ?? '';
              final icon = switch (status) {
                'taken' => Icons.check_circle_outline,
                'missed' => Icons.warning_amber_rounded,
                'snoozed' => Icons.snooze,
                _ => Icons.notifications_active_outlined,
              };
              final time = scheduled == null
                  ? ''
                  : MaterialLocalizations.of(context).formatFullDate(scheduled.toLocal());
              final statusLabel = switch (status) {
                'taken' => l10n.scheduleTaken,
                'missed' => l10n.scheduleMissed,
                'snoozed' => l10n.scheduleSnoozed,
                'due' => l10n.scheduleDue,
                _ => l10n.scheduleUpcoming,
              };
              return Card(
                child: ListTile(
                  leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
                  title: Text(title),
                  subtitle: Text('$dosage${time.isEmpty ? '' : '\n$time'}'),
                  isThreeLine: time.isNotEmpty,
                  trailing: Text(statusLabel),
                ),
              );
            },
          );
        },
        ),
      ),
    );
  }
}
