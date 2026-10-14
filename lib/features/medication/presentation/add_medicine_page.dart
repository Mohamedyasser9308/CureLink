
import 'dart:io';

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
    return (widget.patientId ??
            FirebaseAuth.instance.currentUser?.uid ??
            '')
        .trim();
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
    if (isInitializing ||
        medicationCubit.state is MedicationLoading) {
      return;
    }

    if (formKey.currentState?.validate() != true) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final patientId = resolvedPatientId;

    if (FirebaseAuth.instance.currentUser == null) {
      _showMessage(l10n.noAuthenticatedUser);
      return;
    }

    if (patientId.isEmpty) {
      _showMessage(l10n.medPatientUnavailable);
      return;
    }

    final frequency = selectedFrequencyValue;

    if (frequency == null || frequency.isEmpty) {
      _showMessage(l10n.medFrequencyRequired);
      return;
    }

    final duration = selectedDurationValue;

    if (duration == null || duration.isEmpty) {
      _showMessage(l10n.medDurationRequired);
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
        _showMessage(l10n.medDurationRequired);
        return;
    }

    if (frequency == 'Specific days' &&
        selectedWeekdays.isEmpty) {
      _showMessage(l10n.medSelectDays);
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
      image: selectedMedicineImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: colors.onSurface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          isEditMode ? l10n.editMedicine : l10n.addMedicine,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w400,
            color: colors.onSurface,
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
          } else if (state is MedicationLoadFailure) {
            setState(() {
              isInitializing = false;
            });
            _showMessage(state.message);
          } else if (state is MedicationSuccess) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(true);
            } else {
              _showMessage(l10n.medSavedSuccessfully);
            }
          } else if (state is MedicationError) {
            _showMessage(state.message);
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
                        color: colors.onSurface,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isInitializing = true;
                        });
                        loadMedicine();
                      },
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }

          if (isInitializing ||
              state is MedicationInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final isLoading = state is MedicationLoading;

          return SafeArea(
            child: Form(
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
                        backgroundColor: colors.primary,
                        foregroundColor: colors.onPrimary,
                        disabledBackgroundColor:
                            colors.primary.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.onPrimary,
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
            ),
          );
        },
      ),
    );
  }
}
