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

  const AddMedicinePage({super.key, this.patientId, this.medicineId});

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

  // True until the medicine check finishes (Edit or Add Mode is known).
  bool isInitializing = true;
  String? existingImageUrl;

  @override
  void initState() {
    super.initState();

    medicationCubit = MedicationCubit(repository: MedicationRepository());

    // Wait for the first frame so BlocConsumer is already listening.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) loadMedicine();
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

  void loadMedicine() {
    final patientId =
        widget.patientId ?? FirebaseAuth.instance.currentUser?.uid ?? '';

    medicationCubit.loadMedication(
      patientId: patientId,
      medicineId: widget.medicineId,
    );
  }

  void fillForm(MedicationModel medication) {
    nameController.text = medication.name;
    doseController.text = medication.dosage;
    timeController.text = medication.times.isNotEmpty
        ? medication.times.first
        : '';
    frequencyController.text = medication.frequency;

    // Same raw values MedicineForm uses, so the save logic stays unchanged.
    durationController.text = medication.durationDays == null
        ? 'Ongoing'
        : '${medication.durationDays} days';

    descriptionController.text = medication.description ?? '';
    notesController.text = medication.instructions ?? '';

    selectedWeekdays = List<int>.from(medication.weekdays);
    existingImageUrl = medication.imageUrl;
  }

  void saveMedicine() {
    // Validate the form before saving.
    if (formKey.currentState?.validate() != true) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;

    final patientId =
        widget.patientId ?? FirebaseAuth.instance.currentUser?.uid;

    if (patientId == null || patientId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.medPatientUnavailable)));
      return;
    }

    // Keep existing duration handling.
    final durationText = durationController.text;

    final int? durationDays = durationText == 'Ongoing'
        ? null
        : int.tryParse(durationText.split(' ').first);

    medicationCubit.saveMedication(
      patientId: patientId,
      name: nameController.text.trim(),
      dosage: doseController.text.trim(),
      time: timeController.text.trim(),
      frequency: frequencyController.text.trim(),
      weekdays: selectedWeekdays,
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
          medicationCubit.isEditMode ? l10n.editMedicine : l10n.addMedicine,
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
          }

          if (state is MedicationNew) {
            setState(() {
              isInitializing = false;
            });
          }

          if (state is MedicationSuccess) {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(true);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.medSavedSuccessfully)),
              );
            }
          }

          if (state is MedicationError) {
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
                      style: TextStyle(color: AppTheme.navy, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    IconButton(
                      onPressed: loadMedicine,
                      icon: Icon(Icons.refresh, color: AppTheme.navy),
                    ),
                  ],
                ),
              ),
            );
          }

          if (isInitializing) {
            return const Center(child: CircularProgressIndicator());
          }

          final isLoading = state is MedicationLoading;

          return Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                MedicineForm(
                  nameController: nameController,
                  doseController: doseController,
                  timeController: timeController,
                  frequencyController: frequencyController,
                  durationController: durationController,
                  descriptionController: descriptionController,
                  notesController: notesController,
                  initialImageUrl: existingImageUrl,

                  onImageSelected: (image) {
                    selectedMedicineImage = image;
                  },

                  onWeekdaysChanged: (days) {
                    selectedWeekdays = days;
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