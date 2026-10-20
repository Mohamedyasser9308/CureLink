
import 'dart:io';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'medicine_image_picker.dart';
import 'medicine_textfield.dart';

class MedicineForm extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController doseController;
  final TextEditingController frequencyController;
  final TextEditingController durationController;
  final TextEditingController descriptionController;
  final TextEditingController notesController;

  final ValueChanged<File?> onImageSelected;
  final ValueChanged<List<int>> onWeekdaysChanged;
  final ValueChanged<String> onFrequencyChanged;
  final ValueChanged<String> onDurationChanged;
  final ValueChanged<List<String>> onTimesChanged;

  final String? initialImageUrl;
  final List<int> initialWeekdays;
  final String? initialFrequency;
  final String? initialDuration;
  final List<String> initialTimes;

  const MedicineForm({
    super.key,
    required this.nameController,
    required this.doseController,
    required this.frequencyController,
    required this.durationController,
    required this.descriptionController,
    required this.notesController,
    required this.onImageSelected,
    required this.onWeekdaysChanged,
    required this.onFrequencyChanged,
    required this.onDurationChanged,
    required this.onTimesChanged,
    this.initialImageUrl,
    this.initialWeekdays = const [],
    this.initialFrequency,
    this.initialDuration,
    this.initialTimes = const [],
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
  List<String> selectedTimes = [];

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

    selectedFrequency = resolveFrequency(
      widget.initialFrequency ?? widget.frequencyController.text,
    );

    selectedDuration = resolveDuration(
      widget.initialDuration ?? widget.durationController.text,
    );

    selectedWeekdays = widget.initialWeekdays
        .where((day) => day >= 1 && day <= 7)
        .toSet()
        .toList()
      ..sort();
    selectedTimes = List<String>.from(widget.initialTimes);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncLocalizedLabels();
  }

  @override
  void didUpdateWidget(covariant MedicineForm oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialFrequency != widget.initialFrequency) {
      selectedFrequency = resolveFrequency(
        widget.initialFrequency ?? widget.frequencyController.text,
      );
    }

    if (oldWidget.initialDuration != widget.initialDuration) {
      selectedDuration = resolveDuration(
        widget.initialDuration ?? widget.durationController.text,
      );
    }

    if (oldWidget.initialWeekdays != widget.initialWeekdays) {
      selectedWeekdays = widget.initialWeekdays
          .where((day) => day >= 1 && day <= 7)
          .toSet()
          .toList()
        ..sort();
    }

    _syncLocalizedLabels();
  }

  void _syncLocalizedLabels() {
    final l10n = AppLocalizations.of(context)!;

    if (selectedFrequency != null) {
      final index = frequencyOptions.indexOf(selectedFrequency!);

      if (index >= 0) {
        widget.frequencyController.text = frequencyLabels(l10n)[index];
      }
    }

    if (selectedDuration != null) {
      final index = durationOptions.indexOf(selectedDuration!);

      if (index >= 0) {
        widget.durationController.text = durationLabels(l10n)[index];
      }
    }
  }

  String? resolveFrequency(String value) {
    final normalized = value.trim().toLowerCase();

    if (normalized.isEmpty) return null;

    for (var i = 0; i < frequencyOptions.length; i++) {
      if (frequencyOptions[i].toLowerCase() == normalized) {
        return frequencyOptions[i];
      }
    }

    for (final locale in AppLocalizations.supportedLocales) {
      final labels = frequencyLabels(lookupAppLocalizations(locale));

      for (var i = 0; i < labels.length; i++) {
        if (labels[i].trim().toLowerCase() == normalized) {
          return frequencyOptions[i];
        }
      }
    }

    return null;
  }

  String? resolveDuration(String value) {
    final normalized = value.trim().toLowerCase();

    if (normalized.isEmpty) return null;

    for (var i = 0; i < durationOptions.length; i++) {
      if (durationOptions[i].toLowerCase() == normalized) {
        return durationOptions[i];
      }
    }

    for (final locale in AppLocalizations.supportedLocales) {
      final labels = durationLabels(lookupAppLocalizations(locale));

      for (var i = 0; i < labels.length; i++) {
        if (labels[i].trim().toLowerCase() == normalized) {
          return durationOptions[i];
        }
      }
    }

    final number = int.tryParse(normalized.split(' ').first);

    switch (number) {
      case 7:
        return '7 days';
      case 14:
        return '14 days';
      case 30:
        return '30 days';
      default:
        return null;
    }
  }

  Future<void> selectTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );

    if (!mounted || selectedTime == null) return;

    final time =
        '${selectedTime.hour.toString().padLeft(2, '0')}:'
        '${selectedTime.minute.toString().padLeft(2, '0')}';
    if (selectedTimes.contains(time)) return;
    setState(() {
      selectedTimes = [...selectedTimes, time]..sort();
    });
    widget.onTimesChanged(List<String>.from(selectedTimes));
  }

  Future<List<int>?> selectDays() async {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final selectedDays = selectedWeekdays.toSet();
    final names = dayNames(l10n);

    return showDialog<List<int>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colors.surface,
              title: Text(
                l10n.medSelectDays,
                style: TextStyle(color: colors.onSurface),
              ),
              content: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(7, (index) {
                  final day = index + 1;

                  return FilterChip(
                    label: Text(names[index]),
                    selected: selectedDays.contains(day),
                    selectedColor: colors.primary.withValues(alpha: 0.22),
                    backgroundColor: colors.surface,
                    side: BorderSide(color: colors.outline),
                    labelStyle: TextStyle(
                      color: selectedDays.contains(day)
                          ? colors.primary
                          : colors.onSurface,
                    ),
                    checkmarkColor: colors.primary,
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
    final colors = Theme.of(context).colorScheme;
    final labels = frequencyLabels(l10n);

    final selectedIndex = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: colors.surface,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(frequencyOptions.length, (index) {
              final isSelected =
                  selectedFrequency == frequencyOptions[index];

              return ListTile(
                title: Text(
                  labels[index],
                  style: TextStyle(color: colors.onSurface),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: colors.primary)
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
      selectedWeekdays = selected == 'Specific days' ? days : [];
      widget.frequencyController.text = labels[selectedIndex];
    });

    widget.onFrequencyChanged(selected);
    widget.onWeekdaysChanged(List<int>.from(selectedWeekdays));
  }

  Future<void> selectDuration() async {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final labels = durationLabels(l10n);

    final selectedIndex = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: colors.surface,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(durationOptions.length, (index) {
              final isSelected =
                  selectedDuration == durationOptions[index];

              return ListTile(
                title: Text(
                  labels[index],
                  style: TextStyle(color: colors.onSurface),
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: colors.primary)
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final names = dayNames(l10n);

    final sectionLabelStyle = TextStyle(
      color: colors.onSurface,
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    final iconColor = colors.primary;

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

        Text(l10n.time, style: sectionLabelStyle),
        const SizedBox(height: 8),

        OutlinedButton.icon(
          onPressed: selectTime,
          icon: Icon(Icons.access_time_outlined, color: iconColor),
          label: Text(l10n.medSelectTime),
        ),
        if (selectedTimes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: selectedTimes
                  .map(
                    (time) => Chip(
                      label: Text(time),
                      onDeleted: () {
                        setState(() => selectedTimes.remove(time));
                        widget.onTimesChanged(
                          List<String>.from(selectedTimes),
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
        const SizedBox(height: 20),

        Text(l10n.medFrequencyDuration, style: sectionLabelStyle),
        const SizedBox(height: 8),

        TextFormField(
          controller: widget.frequencyController,
          readOnly: true,
          onTap: selectFrequency,
          validator: (value) {
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
            suffixIcon: Icon(
              Icons.keyboard_arrow_down,
              color: iconColor,
            ),
          ).copyWith(hintText: l10n.medSelectFrequency),
        ),

        if (selectedFrequency == 'Specific days') ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: selectedWeekdays.map((day) {
              return Chip(
                label: Text(
                  names[day - 1],
                  style: TextStyle(color: colors.onSurface),
                ),
                backgroundColor: colors.primary.withValues(
                  alpha: theme.brightness == Brightness.dark ? 0.24 : 0.1,
                ),
                side: BorderSide(color: colors.outline),
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
            if (selectedDuration == null) {
              return l10n.medDurationRequired;
            }
            return null;
          },
          decoration: medicineDecoration(
            context,
            suffixIcon: Icon(
              Icons.calendar_month_outlined,
              color: iconColor,
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
