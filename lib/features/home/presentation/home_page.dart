
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(l10n.appTitle),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.goodMorning,
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 8),

            Text(
              l10n.medicationPlanToday,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 30),

            Text(
              l10n.nextDose,
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 15),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.medication_outlined,
                      size: 40,
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.medicationName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium,
                          ),

                          const SizedBox(height: 5),

                          Text(
                            l10n.scheduledTime('08:00 AM'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            Text(
              l10n.todaysProgress,
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 15),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 35,
                    ),

                    const SizedBox(width: 15),

                    Text(
                      l10n.progressCount(0, 0),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.access_time),
            label: l10n.navSchedule,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            label: l10n.navCalendar,
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_none),
            label: l10n.navNotifications,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            label: l10n.navProfile,
          ),
        ],
      ),
    );
  }
}
