
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _switchMode(String mode) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({'activeMode': mode});
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Please sign in again.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Could not load your profile.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final data = snapshot.data!.data() ?? {};
          final name = data['name'] as String? ?? user.displayName ?? '';
          final email = data['email'] as String? ?? user.email ?? '';
          final phone = data['phone'] as String? ?? '';
          final role = (data['role'] as String? ?? '').toLowerCase();
          final activeMode =
              (data['activeMode'] as String? ?? 'patient').toLowerCase();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 45,
                backgroundImage: user.photoURL != null
                    ? NetworkImage(user.photoURL!)
                    : null,
                child: user.photoURL == null
                    ? const Icon(Icons.person_outline, size: 48)
                    : null,
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  name.isEmpty ? 'CureLink User' : name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              Center(child: Text(email)),
              if (phone.isNotEmpty) ...[
                const SizedBox(height: 8),
                Center(child: Text(phone)),
              ],
              const SizedBox(height: 28),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Account role'),
                subtitle: Text(role.isEmpty ? 'Not set' : role),
              ),
              if (role == 'both') ...[
                const SizedBox(height: 12),
                Text(
                  'Active mode',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'patient',
                      label: Text('Patient'),
                      icon: Icon(Icons.person_outline),
                    ),
                    ButtonSegment(
                      value: 'caregiver',
                      label: Text('Caregiver'),
                      icon: Icon(Icons.health_and_safety_outlined),
                    ),
                  ],
                  selected: {
                    activeMode == 'caregiver' ? 'caregiver' : 'patient',
                  },
                  onSelectionChanged: (selection) async {
                    try {
                      await _switchMode(selection.first);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Active mode updated.'),
                        ),
                      );
                    } catch (_) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not update active mode.'),
                        ),
                      );
                    }
                  },
                ),
              ],
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Settings'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SettingsPage(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
