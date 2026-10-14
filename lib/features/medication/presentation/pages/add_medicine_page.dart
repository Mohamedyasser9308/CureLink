import 'dart:io';

import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/features/medication/data/repositries/medication_repository.dart';
import 'package:curelink/features/medication/presentation/cubit/medication_cubit.dart';
import 'package:curelink/features/medication/presentation/cubit/medication_state.dart';
import 'package:curelink/features/medication/presentation/widgets/medicine_form.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddMedicinePage extends StatefulWidget {
  final String? patientId;

  const AddMedicinePage({
    super.key,
    this.patientId,
  });

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();

  late final MedicationCubit medicationCubit;

  final nameController = TextEditingController();
  final doseController = TextEditingController();
  final timeController = TextEditingController();
  final frequencyController = TextEditingController();
  final durationController = TextEditingController();
  final descriptionController = TextEditingController();
  final notesController = TextEditingController();

  File? selectedImage;
  List<int> selectedWeekdays = [];

  // Canonical values are saved, not translated display labels.
  String? selectedFrequencyValue;
  String? selectedDurationValue;

  @override
  void initState() {
    super.initState();

    medicationCubit = MedicationCubit(
      repository: MedicationRepository(),
    );
  }

  @override
  void dispose() {
    medicationCubit.close();

    nameController.dispose();
    doseController.dispose();
    timeController.dispose();
    frequencyController.dispose();
    durationController.dispose();
    descriptionController.dispose();
    notesController.dispose();

    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> saveMedicine() async {
    final l10n = AppLocalizations.of(context)!;

    if (medicationCubit.state is MedicationLoading) {
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _showMessage(l10n.noAuthenticatedUser);
      return;
    }

    // Use the provided patient ID when adding for a patient.
    // Otherwise, use the currently authenticated user.
    final patientId = widget.patientId ?? currentUser.uid;

    if (patientId.trim().isEmpty) {
      _showMessage(l10n.medPatientUnavailable);
      return;
    }

    final frequency = selectedFrequencyValue;
    final duration = selectedDurationValue;

    if (frequency == null || duration == null) {
      _showMessage(l10n.medFrequencyRequired);
      return;
    }

    if (frequency == 'Specific days' && selectedWeekdays.isEmpty) {
      _showMessage(l10n.medSelectDays);
      return;
    }

    int? durationDays;

    switch (duration) {
      case '7 days':
        durationDays = 7;
        break;

      case '14 days':
        durationDays = 14;
        break;

      case '30 days':
        durationDays = 30;
        break;

      case 'Ongoing':
        durationDays = null;
        break;

      default:
        _showMessage(l10n.medDurationRequired);
        return;
    }

    await medicationCubit.saveMedication(
      patientId: patientId,
      name: nameController.text.trim(),
      dosage: doseController.text.trim(),
      time: timeController.text.trim(),
      frequency: frequency,
      weekdays: List<int>.from(selectedWeekdays),
      durationDays: durationDays,
      description: descriptionController.text.trim(),
      instructions: notesController.text.trim(),
      image: selectedImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: medicationCubit,
      child: BlocConsumer<MedicationCubit, MedicationState>(
        listener: (context, state) {
          if (state is MedicationSuccess) {
            _showMessage(l10n.medSavedSuccessfully);
            Navigator.of(context).pop(true);
          } else if (state is MedicationError) {
            _showMessage(state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is MedicationLoading;

          return Scaffold(
            backgroundColor: AppTheme.background,
            appBar: AppBar(
              title: Text(l10n.addMedicine),
              backgroundColor: AppTheme.background,
              foregroundColor: AppTheme.navy,
              elevation: 0,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: MedicineForm(
                    nameController: nameController,
                    doseController: doseController,
                    timeController: timeController,
                    frequencyController: frequencyController,
                    durationController: durationController,
                    descriptionController: descriptionController,
                    notesController: notesController,
                    onImageSelected: (image) {
                      setState(() {
                        selectedImage = image;
                      });
                    },
                    onWeekdaysChanged: (days) {
                      setState(() {
                        selectedWeekdays = List<int>.from(days);
                      });
                    },
                    onFrequencyChanged: (frequency) {
                      selectedFrequencyValue = frequency;
                    },
                    onDurationChanged: (duration) {
                      selectedDurationValue = duration;
                    },
                  ),
                ),
              ),
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : saveMedicine,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          AppTheme.primary.withValues(alpha: 0.5),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.medSaveMedicine,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
