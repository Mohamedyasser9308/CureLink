import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../router/routes_names.dart';
import '../../features/shell/presentation/main_shell.dart';

class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  Future<DocumentSnapshot<Map<String, dynamic>>>? _profileFuture;

  Future<DocumentSnapshot<Map<String, dynamic>>> _loadProfile(String uid) async {
    late DocumentSnapshot<Map<String, dynamic>> snapshot;
    for (var attempt = 0; attempt < 3; attempt++) {
      snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get(const GetOptions(source: Source.server));
      if (snapshot.data()?['profileCompleted'] == true || attempt == 2) {
        return snapshot;
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    return snapshot;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(RoutesNames.loginPage, (_) => false);
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    _profileFuture ??= _loadProfile(user.uid);

    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Could not verify your account. Check your connection.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        setState(() => _profileFuture = _loadProfile(user.uid));
                      },
                      child: const Text('Retry'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          RoutesNames.loginPage,
                          (_) => false,
                        );
                      },
                      child: const Text('Log out'),
                    ),
                  ],
                ),
              ),
          ),
        );
        }

        final data = snapshot.data?.data();

        if (data == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil(RoutesNames.loginPage, (_) => false);
          });

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (data['profileCompleted'] != true) {
          final name = data['name'] as String? ?? '';
          final role = data['role'] as String? ?? '';
          final ageGroup = data['ageGroup'] as String? ?? '';

          if (name.isNotEmpty && role.isNotEmpty && ageGroup.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;
              Navigator.of(context).pushNamedAndRemoveUntil(
                RoutesNames.completeProfilePage,
                (_) => false,
                arguments: {'name': name, 'role': role, 'ageGroup': ageGroup},
              );
            });

            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Your profile needs to be completed. Please sign in again and continue your registration.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          RoutesNames.loginPage,
                          (_) => false,
                        );
                      },
                      child: const Text('Log out'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return MainShell(
          patientUid: user.uid,
          role: (data['role'] as String? ?? '').toLowerCase(),
        );
      },
    );
  }
}
