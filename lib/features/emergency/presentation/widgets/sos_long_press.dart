import 'dart:async';

import 'package:flutter/material.dart';

class SosLongPress extends StatefulWidget {
  const SosLongPress({
    super.key,
    required this.child,
    required this.onActivated,
    this.duration = const Duration(seconds: 3),
    this.enabled = true,
    this.onProgress,
  });

  final Widget child;
  final VoidCallback onActivated;
  final Duration duration;
  final bool enabled;
  final ValueChanged<double>? onProgress;

  @override
  State<SosLongPress> createState() => _SosLongPressState();
}

class _SosLongPressState extends State<SosLongPress> {
  Timer? _timer;
  Timer? _progressTimer;

  DateTime? _pressStartedAt;
  bool _activated = false;

  void _startPress() {
    if (!widget.enabled || _pressStartedAt != null) return;

    _activated = false;
    _pressStartedAt = DateTime.now();

    widget.onProgress?.call(0);

    _timer = Timer(widget.duration, () {
      if (!mounted || _pressStartedAt == null || _activated) {
        return;
      }

      _activated = true;
      _progressTimer?.cancel();

      widget.onProgress?.call(1);
      widget.onActivated();
    });

    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!mounted || _pressStartedAt == null || _activated) {
        return;
      }

      final elapsed = DateTime.now().difference(_pressStartedAt!);

      final progress = (elapsed.inMilliseconds / widget.duration.inMilliseconds)
          .clamp(0.0, 1.0);

      widget.onProgress?.call(progress);
    });
  }

  void _cancelPress() {
    _timer?.cancel();
    _progressTimer?.cancel();

    _timer = null;
    _progressTimer = null;
    _pressStartedAt = null;

    if (!_activated) {
      widget.onProgress?.call(0);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _startPress(),
      onTapUp: (_) => _cancelPress(),
      onTapCancel: _cancelPress,
      child: widget.child,
    );
  }
}
