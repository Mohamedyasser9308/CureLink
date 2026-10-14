import 'dart:async';
import 'dart:ui' as ui;

import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/features/home/data/models/dose_item.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Navy "Next dose" card with a live countdown.
///
/// The countdown ticks inside this widget only, so the rest of the screen is
/// not rebuilt every second. [onElapsed] fires once when it reaches zero so
/// the Cubit can move on to the following dose.
class NextDoseCard extends StatefulWidget {
  const NextDoseCard({super.key, required this.dose, this.onElapsed});

  /// Null means nothing is left today.
  final DoseItem? dose;
  final VoidCallback? onElapsed;

  @override
  State<NextDoseCard> createState() => _NextDoseCardState();
}

class _NextDoseCardState extends State<NextDoseCard> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _restart();
  }

  @override
  void didUpdateWidget(covariant NextDoseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final a = oldWidget.dose;
    final b = widget.dose;
    if (a?.time != b?.time || a?.medication.id != b?.medication.id) {
      _restart();
    }
  }

  void _restart() {
    _timer?.cancel();
    final dose = widget.dose;
    if (dose == null) {
      _remaining = Duration.zero;
      return;
    }
    _remaining = _diff(dose);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Duration _diff(DoseItem dose) {
    final d = dose.time.difference(DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  void _tick() {
    final dose = widget.dose;
    if (dose == null || !mounted) return;
    final remaining = _diff(dose);
    setState(() => _remaining = remaining);
    if (remaining == Duration.zero) {
      _timer?.cancel();
      widget.onElapsed?.call();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:'
        '${two(d.inSeconds.remainder(60))}';
  }

  @override
  Widget build(BuildContext context) {
    final dose = widget.dose;
    if (dose == null) return const _AllDoneCard();

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final timeLabel = DateFormat.jm(locale).format(dose.time);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.nextDose.toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.cyan,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              _UpcomingChip(label: l10n.statusUpcoming),
            ],
          ),
          const SizedBox(height: 8),
          Directionality(
            textDirection: ui.TextDirection.ltr,
            child: Text(
              l10n.inDuration(_format(_remaining)),
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${dose.medication.name} · ${dose.medication.dosage}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.scheduledTime(timeLabel),
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingChip extends StatelessWidget {
  const _UpcomingChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.mint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule_rounded, size: 15, color: AppTheme.navy),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppTheme.navy,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _AllDoneCard extends StatelessWidget {
  const _AllDoneCard();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.secondary.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 40, color: scheme.tertiary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.allDosesDone, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  l10n.allDosesDoneMessage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
