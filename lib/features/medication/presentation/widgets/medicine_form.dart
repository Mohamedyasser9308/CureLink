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
  final String? initialImageUrl;

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
    this.initialImageUrl,
  });

  @override
  State<MedicineForm> createState() => _MedicineFormState();
}

class _MedicineFormState extends State<MedicineForm> {
  // القيم الأصلية المستخدمة في الحفظ والـ Validation
  final List<String> frequencyOptions = [
    'Every day',
    'Every other day',
    'Specific days',
    'As needed',
  ];

  final List<String> durationOptions = [
    '7 days',
    '14 days',
    '30 days',
    'Ongoing',
  ];

  String? selectedFrequency;
  String? selectedDuration;

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
    selectedFrequency = resolveFrequency(widget.frequencyController.text);

    final duration = widget.durationController.text;
    selectedDuration = durationOptions.contains(duration) ? duration : null;
  }

  String? resolveFrequency(String value) {
    if (value.isEmpty) return null;

    if (frequencyOptions.contains(value)) return value;

    for (final locale in AppLocalizations.supportedLocales) {
      final labels = frequencyLabels(lookupAppLocalizations(locale));
      final index = labels.indexOf(value);

      if (index != -1) return frequencyOptions[index];
    }

    return null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // لو لغة التطبيق اتغيرت، نحدث النص الظاهر للمستخدم.
    final l10n = AppLocalizations.of(context)!;

    if (selectedFrequency != null) {
      final index = frequencyOptions.indexOf(selectedFrequency!);
      if (index != -1) {
        widget.frequencyController.text = frequencyLabels(l10n)[index];
      }
    }

    if (selectedDuration != null) {
      final index = durationOptions.indexOf(selectedDuration!);
      if (index != -1) {
        widget.durationController.text = durationLabels(l10n)[index];
      }
    }
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
    final selectedDays = <int>{};
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
                onTap: () => Navigator.pop(sheetContext, index),
              );
            }),
          ),
        );
      },
    );

    if (!mounted || selectedIndex == null) return;

    final selected = frequencyOptions[selectedIndex];

    if (selected == 'Specific days') {
      final days = await selectDays();

      if (!mounted || days == null) return;

      widget.onWeekdaysChanged(days);
    } else {
      widget.onWeekdaysChanged([]);
    }

    setState(() {
      selectedFrequency = selected;

      // النص الظاهر بالعربي أو الإنجليزي
      widget.frequencyController.text = labels[selectedIndex];
    });
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
                onTap: () => Navigator.pop(sheetContext, index),
              );
            }),
          ),
        );
      },
    );

    if (!mounted || selectedIndex == null) return;

    setState(() {
      selectedDuration = durationOptions[selectedIndex];

      // نخلي القيمة الأصلية عشان AddMedicinePage
      // بتستخدمها لتحويل مدة العلاج لعدد أيام.
      widget.durationController.text = selectedDuration!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        MedicineImagePicker(onImageSelected: widget.onImageSelected,initialImageUrl: widget.initialImageUrl,),

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
          style: TextStyle(
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
              color: Color(0xff86449F),
            ),
          ).copyWith(hintText: l10n.medSelectTime),
        ),
        const SizedBox(height: 20),

        Text(
          l10n.medFrequencyDuration,
          style: TextStyle(
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
            return null;
          },
          decoration: medicineDecoration(
            context,
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xff86449F),
            ),
          ).copyWith(hintText: l10n.medSelectFrequency),
        ),
        const SizedBox(height: 12),

        TextFormField(
          controller: widget.durationController,
          readOnly: true,
          onTap: selectDuration,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return l10n.medDurationRequired;
            }
            return null;
          },
          decoration: medicineDecoration(
            context,
            suffixIcon: const Icon(
              Icons.calendar_month_outlined,
              color: Color(0xff86449F),
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
