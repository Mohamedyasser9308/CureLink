
import 'dart:io';

import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/features/medication/presentation/widgets/medicine_image_picker.dart';
import 'package:curelink/features/medication/presentation/widgets/medicine_textfield.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class MedicineForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController doseController;
  final TextEditingController timeController;
  final TextEditingController frequencyController;
  final TextEditingController durationController;
  final TextEditingController descriptionController;
  final TextEditingController notesController;

  final ValueChanged<File?> onImageSelected;
  final ValueChanged<List<int>> onWeekdaysChanged;
  final ValueChanged<String> onFrequencyChanged;
  final ValueChanged<String> onDurationChanged;

  final String? initialImageUrl;
  final List<int> initialWeekdays;

  const MedicineForm({
    super.key,
    required this.nameController,
    required this.doseController,
    required this.timeController,
    required this.frequencyController,
    required this.durationController,
    required this.descriptionController,
    required this.notesController,
    required this.onImageSelected,
    required this.onWeekdaysChanged,
    required this.onFrequencyChanged,
    required this.onDurationChanged,
    this.initialImageUrl,
    this.initialWeekdays = const [],
  });

  @override
  State<MedicineForm> createState() => _MedicineFormState();
}

class _MedicineFormState extends State<MedicineForm> {
  static const List<String> frequencyOptions = [
    'Every day',
    'Every other day',
    'Specific days',
    'As needed',
  ];

  static const List<String> durationOptions = [
    '7 days',
    '14 days',
    '30 days',
    'Ongoing',
  ];

  String? selectedFrequency;
  String? selectedDuration;

  List<int> selectedWeekdays = [];

  List<String> frequencyLabels(AppLocalizations l10n) => [
        l10n.medEveryDay,
        l10n.medEveryOtherDay,
        l10n.medSpecificDays,
        l10n.medAsNeeded,
      ];

  List<String> durationLabels(AppLocalizations l10n) => [
        l10n.medSevenDays,
        l10n.medFourteenDays,
        l10n.medThirtyDays,
        l10n.medOngoing,
      ];

  List<String> dayNames(AppLocalizations l10n) => [
        l10n.medMonday,
        l10n.medTuesday,
        l10n.medWednesday,
        l10n.medThursday,
        l10n.medFriday,
        l10n.medSaturday,
        l10n.medSunday,
      ];

  @override
  void initState() {
    super.initState();

    selectedFrequency =
        resolveFrequency(widget.frequencyController.text);

    selectedDuration = resolveDuration(widget.durationController.text);

    selectedWeekdays = List<int>.from(widget.initialWeekdays);
  }

  @override
  void didUpdateWidget(covariant MedicineForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialWeekdays != widget.initialWeekdays) {
      selectedWeekdays = List<int>.from(widget.initialWeekdays);
    }

    if (oldWidget.frequencyController.text !=
        widget.frequencyController.text) {
      selectedFrequency =
          resolveFrequency(widget.frequencyController.text);
    }

    if (oldWidget.durationController.text !=
        widget.durationController.text) {
      selectedDuration =
          resolveDuration(widget.durationController.text);
    }
  }

  String? resolveFrequency(String value) {
    if (value.isEmpty) return null;

    if (frequencyOptions.contains(value)) return value;

    final normalizedValue = value.trim().toLowerCase();

    for (final locale in AppLocalizations.supportedLocales) {
      final labels = frequencyLabels(lookupAppLocalizations(locale));

      for (var i = 0; i < labels.length; i++) {
        if (labels[i].trim().toLowerCase() == normalizedValue) {
          return frequencyOptions[i];
        }
      }
    }

    return null;
  }

  String? resolveDuration(String value) {
    if (value.isEmpty) return null;

    if (durationOptions.contains(value)) return value;

    final normalizedValue = value.trim().toLowerCase();

    for (final locale in AppLocalizations.supportedLocales) {
      final labels = durationLabels(lookupAppLocalizations(locale));

      for (var i = 0; i < labels.length; i++) {
        if (labels[i].trim().toLowerCase() == normalizedValue) {
          return durationOptions[i];
        }
      }
    }

    return null;
  }

  Future<void> selectTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );

    if (!mounted || selectedTime == null) return;

    widget.timeController.text =
        '${selectedTime.hour.toString().padLeft(2, '0')}:'
        '${selectedTime.minute.toString().padLeft(2, '0')}';
  }

  Future<List<int>?> selectDays() async {
    final l10n = AppLocalizations.of(context)!;
    final selectedDays = selectedWeekdays.toSet();
    final names = dayNames(l10n);

    return showDialog<List<int>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.medSelectDays),
              content: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(7, (index) {
                  final day = index + 1;

                  return FilterChip(
                    label: Text(names[index]),
                    selected: selectedDays.contains(day),
                    onSelected: (selected) {
                      setDialogState(() {
                        if (selected) {
                          selectedDays.add(day);
                        } else {
                          selectedDays.remove(day);
                        }
                      });
                    },
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(l10n.medCancel),
                ),
                TextButton(
                  onPressed: selectedDays.isEmpty
                      ? null
                      : () {
                          final days = selectedDays.toList()..sort();
                          Navigator.pop(dialogContext, days);
                        },
                  child: Text(l10n.done),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> selectFrequency() async {
    final l10n = AppLocalizations.of(context)!;
    final labels = frequencyLabels(l10n);

    final selectedIndex = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(frequencyOptions.length, (index) {
              return ListTile(
                title: Text(labels[index]),
                trailing: selectedFrequency == frequencyOptions[index]
                    ? const Icon(
                        Icons.check,
                        color: AppTheme.primary,
                      )
                    : null,
                onTap: () => Navigator.pop(sheetContext, index),
              );
            }),
          ),
        );
      },
    );

    if (!mounted || selectedIndex == null) return;

    final selected = frequencyOptions[selectedIndex];
    List<int> days = [];

    if (selected == 'Specific days') {
      final result = await selectDays();

      if (!mounted || result == null) return;

      days = result;
    }

    setState(() {
      selectedFrequency = selected;
      widget.frequencyController.text = labels[selectedIndex];

      if (selected == 'Specific days') {
        selectedWeekdays = List<int>.from(days);
      } else {
        selectedWeekdays = [];
      }
    });

    widget.onFrequencyChanged(selected);
    widget.onWeekdaysChanged(List<int>.from(selectedWeekdays));
  }

  Future<void> selectDuration() async {
    final l10n = AppLocalizations.of(context)!;
    final labels = durationLabels(l10n);

    final selectedIndex = await showModalBottomSheet<int>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(durationOptions.length, (index) {
              return ListTile(
                title: Text(labels[index]),
                trailing: selectedDuration == durationOptions[index]
                    ? const Icon(
                        Icons.check,
                        color: AppTheme.primary,
                      )
                    : null,
                onTap: () => Navigator.pop(sheetContext, index),
              );
            }),
          ),
        );
      },
    );

    if (!mounted || selectedIndex == null) return;

    final selected = durationOptions[selectedIndex];

    setState(() {
      selectedDuration = selected;
      widget.durationController.text = labels[selectedIndex];
    });

    widget.onDurationChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MedicineImagePicker(
          onImageSelected: widget.onImageSelected,
          initialImageUrl: widget.initialImageUrl,
        ),

        const SizedBox(height: 20),

        MedicineTextField(
          label: l10n.medicationName,
          controller: widget.nameController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.medNameRequired;
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        MedicineTextField(
          label: l10n.medDoseQuantity,
          controller: widget.doseController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.medDoseRequired;
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        Text(
          l10n.time,
          style: const TextStyle(
            color: AppTheme.navy,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: widget.timeController,
          readOnly: true,
          onTap: selectTime,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.medTimeRequired;
            }
            return null;
          },
          decoration: medicineDecoration(
            context,
            suffixIcon: const Icon(
              Icons.access_time_outlined,
              color: AppTheme.primary,
            ),
          ).copyWith(hintText: l10n.medSelectTime),
        ),

        const SizedBox(height: 20),

        Text(
          l10n.medFrequencyDuration,
          style: const TextStyle(
            color: AppTheme.navy,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: widget.frequencyController,
          readOnly: true,
          onTap: selectFrequency,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.medFrequencyRequired;
            }

            if (selectedFrequency == null) {
              return l10n.medFrequencyRequired;
            }

            if (selectedFrequency == 'Specific days' &&
                selectedWeekdays.isEmpty) {
              return l10n.medSelectDays;
            }

            return null;
          },
          decoration: medicineDecoration(
            context,
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.primary,
            ),
          ).copyWith(hintText: l10n.medSelectFrequency),
        ),

        if (selectedFrequency == 'Specific days') ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selectedWeekdays.map((day) {
              final names = dayNames(l10n);

              return Chip(
                label: Text(names[day - 1]),
                backgroundColor: AppTheme.primary.withValues(alpha: 0.1),
              );
            }).toList(),
          ),
        ],

        const SizedBox(height: 12),

        TextFormField(
          controller: widget.durationController,
          readOnly: true,
          onTap: selectDuration,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.medDurationRequired;
            }

            if (selectedDuration == null) {
              return l10n.medDurationRequired;
            }

            return null;
          },
          decoration: medicineDecoration(
            context,
            suffixIcon: const Icon(
              Icons.calendar_month_outlined,
              color: AppTheme.primary,
            ),
          ).copyWith(hintText: l10n.medSelectDuration),
        ),

        const SizedBox(height: 20),

        MedicineTextField(
          label: l10n.medDescription,
          maxLines: 3,
          controller: widget.descriptionController,
        ),

        const SizedBox(height: 20),

        MedicineTextField(
          label: l10n.medNotesInstructions,
          maxLines: 3,
          controller: widget.notesController,
        ),
      ],
    );
  }
}
