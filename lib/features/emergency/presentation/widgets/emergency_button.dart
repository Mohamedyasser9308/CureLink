
import 'dart:async';

import 'package:curelink/core/theme/app_theme.dart';
import 'package:curelink/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum SosVisualState {
  idle,
  holding,
  result,
  unavailable,
}

class SosButton extends StatefulWidget {
  const SosButton({
    super.key,
    this.available = true,
    this.interactionEnabled = true,
    this.size = 160,
    this.onVisualStateChanged,
    this.onHoldCompleted,
  });

  final bool available;
  final bool interactionEnabled;
  final double size;
  final ValueChanged<SosVisualState>? onVisualStateChanged;
  final VoidCallback? onHoldCompleted;

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton> {
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();

  SosVisualState _state = SosVisualState.idle;
  double _elapsedSeconds = 0;
  bool _holdTriggered = false;
  int? _activePointer;

  static const Duration _holdDuration = Duration(seconds: 3);
  static const Color _lightPink = Color(0xFFFCE9EC);

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

    if (!widget.available ||
        (oldWidget.interactionEnabled &&
            !widget.interactionEnabled)) {
      _cancelTimer();
      _activePointer = null;
      _holdTriggered = false;
      _elapsedSeconds = 0;

      if (!widget.available) {
        _setState(SosVisualState.unavailable);
      } else if (_state == SosVisualState.holding) {
        _setState(SosVisualState.idle);
      }
    } else if (oldWidget.available != widget.available &&
        widget.available &&
        _state == SosVisualState.unavailable) {
      _setState(SosVisualState.idle);
    }
  }

  void _setState(SosVisualState next) {
    if (!mounted || _state == next) return;

    setState(() {
      _state = next;
    });

    widget.onVisualStateChanged?.call(next);
  }

  void _startHold(int pointer) {
    if (!mounted ||
        !widget.available ||
        !widget.interactionEnabled ||
        _activePointer != null ||
        _state == SosVisualState.holding ||
        _holdTriggered) {
      return;
    }

    _activePointer = pointer;
    _elapsedSeconds = 0;

    _stopwatch
      ..reset()
      ..start();

    _setState(SosVisualState.holding);

    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: 100),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (!widget.available || !widget.interactionEnabled) {
          _cancelTimer();
          _activePointer = null;
          _holdTriggered = false;
          _elapsedSeconds = 0;

          _setState(
            widget.available
                ? SosVisualState.idle
                : SosVisualState.unavailable,
          );
          return;
        }

        final elapsed = _stopwatch.elapsed;
        _elapsedSeconds = elapsed.inMilliseconds / 1000;

        if (elapsed >= _holdDuration && !_holdTriggered) {
          // One callback per completed hold.
          _holdTriggered = true;
          _elapsedSeconds = 3;

          _cancelTimer();

          // Keep the pointer until the user releases it.
          // This prevents a second finger from starting another request.
          _setState(SosVisualState.result);
          widget.onHoldCompleted?.call();
          return;
        }

        setState(() {});
      },
    );
  }

  void _endHold(int pointer) {
    if (_activePointer != pointer) return;

    _activePointer = null;
    _cancelTimer();

    if (_state == SosVisualState.holding) {
      // Released before three seconds: no activation.
      _elapsedSeconds = 0;
      _holdTriggered = false;

      _setState(
        widget.available
            ? SosVisualState.idle
            : SosVisualState.unavailable,
      );
      return;
    }

    // The completed hold has ended. A later, separate hold can be used
    // for another intentional attempt if the page permits it.
    _holdTriggered = false;
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;

    _stopwatch
      ..stop()
      ..reset();
  }

  Widget _stateIcon(Color color) {
    if (_state == SosVisualState.unavailable) {
      return Icon(
        Icons.wifi_off_rounded,
        size: 44,
        color: color,
      );
    }

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
        !widget.available || _state == SosVisualState.unavailable;
    final isEnabled =
        widget.available && widget.interactionEnabled;

    // Swap the red and light-pink colors while holding.
    // No white is used.
    final foreground =
        isHolding ? _lightPink : AppTheme.destructive;
    final fill =
        isHolding ? AppTheme.destructive : _lightPink;

    return Semantics(
      button: true,
      enabled: isEnabled,
      label: l10n.sosButtonLabel,
      hint: isUnavailable
          ? l10n.sosUnavailable
          : l10n.sosHoldHint,
      child: Listener(
        onPointerDown: (event) => _startHold(event.pointer),
        onPointerUp: (event) => _endHold(event.pointer),
        onPointerCancel: (event) => _endHold(event.pointer),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isUnavailable ? Colors.grey.shade200 : fill,
            border: Border.all(
              color: isUnavailable
                  ? Colors.grey.shade400
                  : AppTheme.destructive,
              width: 3,
            ),
            boxShadow: isHolding
                ? [
                    BoxShadow(
                      color: AppTheme.destructive.withValues(alpha: 0.25),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _stateIcon(
                  isUnavailable
                      ? Colors.grey.shade600
                      : foreground,
                ),
                const SizedBox(height: 8),
                Text(
                  'SOS',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: isUnavailable
                            ? Colors.grey.shade600
                            : foreground,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (isHolding) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.sosSeconds(
                      _elapsedSeconds.toStringAsFixed(1),
                    ),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
