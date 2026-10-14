
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

  String? selectedFrequencyValue;
  String? selectedDurationValue;
  String? existingImageUrl;

  bool isInitializing = true;
  int formRevision = 0;

  bool get isEditMode =>
      widget.medicineId != null && widget.medicineId!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    medicationCubit = MedicationCubit(
      repository: MedicationRepository(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        loadMedicine();
      }
    });
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

    timeController.text =
        medication.times.isNotEmpty ? medication.times.first : '';

    frequencyController.text = medication.frequency;
    selectedFrequencyValue = medication.frequency;

    durationController.text = medication.durationDays == null
        ? 'Ongoing'
        : '${medication.durationDays} days';

    selectedDurationValue = medication.durationDays == null
        ? 'Ongoing'
        : '${medication.durationDays} days';

    descriptionController.text = medication.description ?? '';
    notesController.text = medication.instructions ?? '';

    selectedWeekdays = List<int>.from(medication.weekdays);
    existingImageUrl = medication.imageUrl;

    // Clear any newly selected local image when loading an existing medicine.
    selectedImage = null;

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
    final l10n = AppLocalizations.of(context)!;

    if (medicationCubit.state is MedicationLoading) return;

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      _showMessage(l10n.noAuthenticatedUser);
      return;
    }

    final patientId = resolvedPatientId;

    if (patientId.isEmpty) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider.value(
      value: medicationCubit,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          foregroundColor: AppTheme.navy,
          elevation: 0,
          title: Text(
            isEditMode ? l10n.editMedicine : l10n.addMedicine,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: AppTheme.navy,
            ),
          ),
        ),
        body: BlocConsumer<MedicationCubit, MedicationState>(
          listener: (context, state) {
            if (state is MedicationLoaded) {
              setState(() {
                fillForm(state.medication);
                isInitializing = false;
              });
            } else if (state is MedicationNew) {
              setState(() {
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
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppTheme.navy,
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

            if (isInitializing || state is MedicationInitial) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final isLoading = state is MedicationLoading;

            return SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
                        selectedImage = image;
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : saveMedicine,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              AppTheme.primary.withValues(alpha: 0.5),
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
