import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/dose_notification_service.dart';
import '../../data/models/dose_model.dart';

class MedicationReminderPage extends StatefulWidget {
  const MedicationReminderPage({super.key, required this.payload});
  final String payload;

  @override
  State<MedicationReminderPage> createState() => _MedicationReminderPageState();
}

class _MedicationReminderPageState extends State<MedicationReminderPage> {
  bool _saving = false;
  String? _error;
  late final String _patientUid;
  late final String _doseId;
  late final Future<DocumentSnapshot<Map<String, dynamic>>> _doseFuture;

  @override
  void initState() {
    super.initState();
    final parts = widget.payload.split('|');
    _patientUid = parts.isNotEmpty ? parts.first : '';
    _doseId = parts.length > 1 ? parts[1] : '';
    _doseFuture = _patientUid.isEmpty || _doseId.isEmpty
        ? Future.error(StateError('Dose details are unavailable'))
        : _doseRef.get();
  }

  DocumentReference<Map<String, dynamic>> get _doseRef => FirebaseFirestore
      .instance
      .collection('users')
      .doc(_patientUid)
      .collection('doses')
      .doc(_doseId);

  Future<void> _setStatus(DoseStatus status) async {
    if (_saving || _patientUid.isEmpty || _doseId.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.uid != _patientUid) {
      setState(() => _error = 'Ø³Ø¬Ù‘Ù„ Ø§Ù„Ø¯Ø®ÙˆÙ„ Ø¨Ø­Ø³Ø§Ø¨ Ø§Ù„Ù…Ø±ÙŠØ¶ Ù„ØªØ­Ø¯ÙŠØ« Ø§Ù„Ø¬Ø±Ø¹Ø©.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      var alreadyFinished = false;
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(_doseRef);
        final data = snapshot.data();
        if (data == null ||
            data['status'] == 'taken' ||
            data['status'] == 'missed') {
          alreadyFinished = true;
          return;
        }
        final now = DateTime.now();
        transaction.update(_doseRef, {
          'status': status.name,
          'takenAt': status == DoseStatus.taken ? Timestamp.fromDate(now) : null,
          'snoozedUntil': status == DoseStatus.snoozed
              ? Timestamp.fromDate(now.add(const Duration(minutes: 10)))
              : null,
          'updatedAt': Timestamp.fromDate(now),
        });
      });

      if (alreadyFinished) {
        if (mounted) setState(() => _error = 'This dose has already been completed or expired.');
        return;
      }

      final snapshot = await _doseRef.get();
      if (snapshot.exists) {
        final updatedDose = DoseModel.fromMap(snapshot.data()!, snapshot.id);
        if (status == DoseStatus.snoozed) {
          await DoseNotificationService.instance.scheduleDose(
            patientUid: _patientUid,
            dose: updatedDose,
          );
        } else {
          await DoseNotificationService.instance.cancelDose(updatedDose);
        }
      }
      if (mounted) Navigator.of(context).pop();
    } on FirebaseException catch (error) {
      if (mounted) setState(() => _error = 'Could not save (${error.code}). Check your connection and account access.');
    } catch (error) {
      if (mounted) {
        setState(() => _error = 'Could not save: $error');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);
    if (_patientUid.isEmpty || _doseId.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(isArabic ? 'Ø¨ÙŠØ§Ù†Ø§Øª Ø§Ù„Ø¬Ø±Ø¹Ø© ØºÙŠØ± Ù…ØªØ§Ø­Ø©' : 'Dose details are unavailable'),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          future: _doseFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data?.data();
            if (data == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    isArabic
                        ? 'ØªØ¹Ø°Ø± ØªØ­Ù…ÙŠÙ„ ØªÙØ§ØµÙŠÙ„ Ø§Ù„Ø¬Ø±Ø¹Ø©. Ø§ÙØªØ­ Ø§Ù„ØªØ·Ø¨ÙŠÙ‚ ÙˆØ§ØªØµÙ„ Ø¨Ø§Ù„Ø¥Ù†ØªØ±Ù†Øª Ø«Ù… Ø­Ø§ÙˆÙ„ Ù…Ø¬Ø¯Ø¯Ù‹Ø§.'
                        : 'Could not load this dose. Open the app with an internet connection and try again.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final dose = DoseModel.fromMap(data, _doseId);
            final finished = dose.status == DoseStatus.taken ||
                dose.status == DoseStatus.missed;
            final time = MaterialLocalizations.of(context).formatTimeOfDay(
              TimeOfDay.fromDateTime(dose.scheduledAt),
            );

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.alarm_rounded, size: 72, color: Color(0xff81459e)),
                      const SizedBox(height: 20),
                      Text(
                        isArabic ? 'Ù…ÙˆØ¹Ø¯ Ø§Ù„Ø¯ÙˆØ§Ø¡' : 'Medication time',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dose.medicationName,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          child: Column(
                            children: [
                              Text(dose.dosage, style: theme.textTheme.titleLarge),
                              const SizedBox(height: 8),
                              Text(
                                isArabic ? 'Ù…ÙˆØ¹Ø¯ Ø§Ù„Ø¬Ø±Ø¹Ø©: $time' : 'Scheduled for $time',
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(_error!, style: TextStyle(color: theme.colorScheme.error), textAlign: TextAlign.center),
                      ],
                      if (finished) ...[
                        const SizedBox(height: 24),
                        Text(
                          dose.status == DoseStatus.taken
                              ? (isArabic ? 'ØªÙ… ØªØ£ÙƒÙŠØ¯ Ø£Ø®Ø° Ù‡Ø°Ù‡ Ø§Ù„Ø¬Ø±Ø¹Ø©' : 'This dose was marked as taken')
                              : (isArabic ? 'Ø§Ù†ØªÙ‡Ù‰ ÙˆÙ‚Øª Ù‡Ø°Ù‡ Ø§Ù„Ø¬Ø±Ø¹Ø©' : 'The time window for this dose has passed'),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          child: Text(isArabic ? 'Ø¥ØºÙ„Ø§Ù‚' : 'Close'),
                        ),
                      ] else ...[
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _saving ? null : () => _setStatus(DoseStatus.taken),
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text(isArabic ? 'Ø£Ø®Ø°Øª Ø§Ù„Ø¯ÙˆØ§Ø¡' : 'Mark as taken'),
                            style: FilledButton.styleFrom(minimumSize: const Size(0, 54)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _saving ? null : () => _setStatus(DoseStatus.snoozed),
                            icon: const Icon(Icons.snooze),
                            label: Text(isArabic ? 'ØªØ£Ø¬ÙŠÙ„ 10 Ø¯Ù‚Ø§Ø¦Ù‚' : 'Snooze 10 minutes'),
                            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 54)),
                          ),
                        ),
                        if (_saving) ...[
                          const SizedBox(height: 16),
                          const CircularProgressIndicator(),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
