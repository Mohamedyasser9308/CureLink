
import 'dart:async';

import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum SosVisualState { idle, holding, result, unavailable }

/// UI-only SOS control. It does not send an alert or call Firebase.
class SosButton extends StatefulWidget {
  const SosButton({
    super.key,
    this.available = true,
    this.size = 160,
    this.onVisualStateChanged,
  });

  final bool available;
  final double size;
  final ValueChanged<SosVisualState>? onVisualStateChanged;

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> {
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();

  SosVisualState _state = SosVisualState.idle;
  double _elapsedSeconds = 0;

  @override
  void initState() {
    super.initState();

    if (!widget.available) {
      _state = SosVisualState.unavailable;
    }
  }

  @override
  void didUpdateWidget(covariant SosButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.available != widget.available) {
      _cancelTimer();
      _elapsedSeconds = 0;

      _setState(
        widget.available
            ? SosVisualState.idle
            : SosVisualState.unavailable,
      );
    }
  }

  void _setState(SosVisualState next) {
    if (!mounted) return;

    setState(() => _state = next);
    widget.onVisualStateChanged?.call(next);
  }

  void _startHold() {
    if (!widget.available ||
        _state == SosVisualState.holding ||
        _state == SosVisualState.result) {
      return;
    }

    _stopwatch
      ..reset()
      ..start();

    _elapsedSeconds = 0;
    _setState(SosVisualState.holding);

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        _elapsedSeconds = _stopwatch.elapsedMilliseconds / 1000;

        if (_elapsedSeconds >= 3) {
          _cancelTimer();
          _setState(SosVisualState.result);
        } else {
          setState(() {});
        }
      },
    );
  }

  void _endHold() {
    if (_state != SosVisualState.holding) return;

    _cancelTimer();
    _elapsedSeconds = 0;

    _setState(
      widget.available
          ? SosVisualState.idle
          : SosVisualState.unavailable,
    );
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;

    _stopwatch
      ..stop()
      ..reset();
  }

  Widget _stateIcon(Color color) {
    switch (_state) {
      case SosVisualState.idle:
      case SosVisualState.holding:
      case SosVisualState.result:
        return SvgPicture.asset(
          'assets/siren.svg',
          width: 44,
          height: 44,
          colorFilter: ColorFilter.mode(
            color,
            BlendMode.srcIn,
          ),
          semanticsLabel: 'Emergency siren',
        );

      case SosVisualState.unavailable:
        return Icon(
          Icons.wifi_off_rounded,
          size: 44,
          color: color,
        );
    }
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final isHolding = _state == SosVisualState.holding;
    final isUnavailable =
        _state == SosVisualState.unavailable || !widget.available;

    const pink = Color(0xFFFCE9EC);

    final foreground =
        isHolding ? pink : AppTheme.destructive;

    final fill =
        isHolding ? AppTheme.destructive : pink;

    return Semantics(
      button: true,
      enabled: !isUnavailable,
      label: 'SOS',
      hint: isUnavailable ? l10n.sosUnavailable : l10n.sosHoldHint,
      child: Listener(
        onPointerDown: (_) => _startHold(),
        onPointerUp: (_) => _endHold(),
        onPointerCancel: (_) => _endHold(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            border: isHolding
                ? null
                : Border.all(
                    color: AppTheme.destructive,
                    width: 2.5,
                  ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stateIcon(foreground),
              const SizedBox(height: 5),
              Text(
                'SOS',
                style: TextStyle(
                  color: foreground,
                  fontSize: 26,
                  height: 1.1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isHolding) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.sosSeconds(
                    _elapsedSeconds.toStringAsFixed(1),
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 15,
                    height: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
