
import 'dart:io';

import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/features/medication/data/models/medication_model.dart';
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
  final String? medicineId;

  const AddMedicinePage({
    super.key,
    this.patientId,
    this.medicineId,
  });

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final doseController = TextEditingController();
  final timeController = TextEditingController();
  final frequencyController = TextEditingController();
  final durationController = TextEditingController();
  final descriptionController = TextEditingController();
  final notesController = TextEditingController();

  late final MedicationCubit medicationCubit;

  File? selectedMedicineImage;
  List<int> selectedWeekdays = [];

  bool isInitializing = true;
  bool isEditMode = false;

  String? existingImageUrl;
  String? selectedFrequencyValue;
  String? selectedDurationValue;

  int formRevision = 0;

  @override
  void initState() {
    super.initState();

    isEditMode = widget.medicineId != null &&
        widget.medicineId!.trim().isNotEmpty;

    medicationCubit = MedicationCubit(
      repository: MedicationRepository(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        loadMedicine();
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    doseController.dispose();
    timeController.dispose();
    frequencyController.dispose();
    durationController.dispose();
    descriptionController.dispose();
    notesController.dispose();

    medicationCubit.close();

    super.dispose();
  }

  String get resolvedPatientId {
    return widget.patientId ??
        FirebaseAuth.instance.currentUser?.uid ??
        '';
  }

  void loadMedicine() {
    medicationCubit.loadMedication(
      patientId: resolvedPatientId,
      medicineId: widget.medicineId,
    );
  }

  void fillForm(MedicationModel medication) {
    nameController.text = medication.name;
    doseController.text = medication.dosage;

    timeController.text = medication.times.isNotEmpty
        ? medication.times.first
        : '';

    // Keep canonical values separate from localized display labels.
    selectedFrequencyValue = medication.frequency;
    selectedDurationValue = medication.durationDays == null
        ? 'Ongoing'
        : '${medication.durationDays} days';

    frequencyController.text = medication.frequency;
    durationController.text = selectedDurationValue!;

    descriptionController.text = medication.description ?? '';
    notesController.text = medication.instructions ?? '';

    selectedWeekdays = List<int>.from(medication.weekdays);
    existingImageUrl = medication.imageUrl;
    selectedMedicineImage = null;

    isEditMode = true;
    formRevision++;
  }

  void saveMedicine() {
    if (isInitializing ||
        medicationCubit.state is MedicationLoading) {
      return;
    }

    if (formKey.currentState?.validate() != true) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final patientId = resolvedPatientId.trim();

    if (patientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.medPatientUnavailable),
        ),
      );
      return;
    }

    final frequency = selectedFrequencyValue;

    if (frequency == null || frequency.isEmpty) {
      return;
    }

    final duration = selectedDurationValue;

    if (duration == null || duration.isEmpty) {
      return;
    }

    final int? durationDays;

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a valid duration.'),
          ),
        );
        return;
    }

    if (frequency == 'Specific days' &&
        selectedWeekdays.isEmpty) {
      return;
    }

    medicationCubit.saveMedication(
      patientId: patientId,
      name: nameController.text.trim(),
      dosage: doseController.text.trim(),
      time: timeController.text.trim(),
      frequency: frequency,
      weekdays: List<int>.from(selectedWeekdays),
      durationDays: durationDays,
      description: descriptionController.text.trim(),
      instructions: notesController.text.trim(),
      image: selectedMedicineImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          isEditMode ? l10n.editMedicine : l10n.addMedicine,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: AppTheme.navy,
          ),
        ),
      ),
      body: BlocConsumer<MedicationCubit, MedicationState>(
        bloc: medicationCubit,
        listener: (context, state) {
          if (state is MedicationLoaded) {
            setState(() {
              fillForm(state.medication);
              isInitializing = false;
            });
          } else if (state is MedicationNew) {
            setState(() {
              isEditMode = false;
              isInitializing = false;
            });
          } else if (state is MedicationSuccess) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.medSavedSuccessfully),
                ),
              );
            }
          } else if (state is MedicationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MedicationLoadFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.navy,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: loadMedicine,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (isInitializing) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final isLoading = state is MedicationLoading;

          return Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
              children: [
                MedicineForm(
                  key: ValueKey(formRevision),
                  nameController: nameController,
                  doseController: doseController,
                  timeController: timeController,
                  frequencyController: frequencyController,
                  durationController: durationController,
                  descriptionController: descriptionController,
                  notesController: notesController,
                  initialImageUrl: existingImageUrl,
                  initialWeekdays: selectedWeekdays,
                  initialFrequency: selectedFrequencyValue,
                  initialDuration: selectedDurationValue,
                  onImageSelected: (image) {
                    selectedMedicineImage = image;
                  },
                  onWeekdaysChanged: (days) {
                    selectedWeekdays = List<int>.from(days);
                  },
                  onFrequencyChanged: (frequency) {
                    selectedFrequencyValue = frequency;
                  },
                  onDurationChanged: (duration) {
                    selectedDurationValue = duration;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : saveMedicine,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.navy,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.medSaveMedicine,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
