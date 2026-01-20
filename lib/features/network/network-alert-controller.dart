import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ekg_detector/widgets/NetworkAlert.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NetworkAlertController {
  static OverlayEntry? _entry;
  static bool _isInserted = false;
  static Timer? _timer;

  static void showDisconnected(OverlayState overlayState) {
    _remove();

    _entry = OverlayEntry(
      builder: (_) => _AnimatedTopAlert(
        child: const NetworkAlert(
          message: 'Tidak ada koneksi internet',
          backgroundColor: Colors.redAccent,
          icon: LucideIcons.wifiOff,
        ),
      ),
    );

    overlayState.insert(_entry!);
    _isInserted = true;
  }

  static void showConnected(OverlayState overlayState) {
    _remove();

    _entry = OverlayEntry(
      builder: (_) => _AnimatedTopAlert(
        child: const NetworkAlert(
          message: 'Koneksi internet tersambung',
          backgroundColor: Colors.green,
          icon: LucideIcons.wifi,
        ),
      ),
    );

    overlayState.insert(_entry!);
    _isInserted = true;

    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 2), _remove);
  }

  static void _remove() {
    if (!_isInserted) return;

    _entry?.remove();
    _entry = null;
    _isInserted = false;
  }
}

class _AnimatedTopAlert extends StatefulWidget {
  final Widget child;

  const _AnimatedTopAlert({required this.child});

  @override
  State<_AnimatedTopAlert> createState() => _AnimatedTopAlertState();
}

class _AnimatedTopAlertState extends State<_AnimatedTopAlert>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _offset = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
