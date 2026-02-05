import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_ekg_detector/widgets/ScanModal.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum FloatingMenuMode { home, result }

class GlassFloatingMenu extends StatefulWidget {
  final FloatingMenuMode mode;
  final VoidCallback onPrimaryAction;
  final VoidCallback onLogout;

  const GlassFloatingMenu({
    super.key,
    required this.mode,
    required this.onPrimaryAction,
    required this.onLogout,
  });

  @override
  State<GlassFloatingMenu> createState() => _GlassFloatingMenuState();
}

class _GlassFloatingMenuState extends State<GlassFloatingMenu> {
  static const double size = 56;
  static const double expandedHeight = 168;
  static const double margin = 24;

  Offset? position;
  bool isExpanded = false;
  bool expandDown = true;

  /* ================= INIT ================= */

  void _ensureInitialPosition(Size screen) {
    position ??= Offset(
      screen.width - size - margin,
      screen.height - size - margin,
    );
  }

  void _recalculateExpandDirection(Size screen) {
    final double topSpace = position!.dy;
    final double bottomSpace = screen.height - (position!.dy + size);

    expandDown =
        bottomSpace >= (expandedHeight - size) || bottomSpace >= topSpace;
  }

  /* ================= ACTION ================= */

  void _handleToggle(Size screen) {
    setState(() {
      _recalculateExpandDirection(screen);
      isExpanded = !isExpanded;
    });
  }

  void _handlePrimaryAction() {
    setState(() => isExpanded = false);

    if (widget.mode == FloatingMenuMode.home) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (_) => const ScanModal(),
      );
    } else {
      widget.onPrimaryAction();
    }
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    final rootContext = Navigator.of(context, rootNavigator: true).context;

    final Size screen = MediaQuery.of(rootContext).size;

    _ensureInitialPosition(screen);

    final double effectiveTop = isExpanded && !expandDown
        ? position!.dy - (expandedHeight - size)
        : position!.dy;

    final IconData primaryIcon = widget.mode == FloatingMenuMode.home
        ? LucideIcons.scan
        : LucideIcons.home;

    return Positioned(
      top: effectiveTop,
      left: position!.dx,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            double newX = position!.dx + details.delta.dx;
            double newY = position!.dy + details.delta.dy;

            newX = newX.clamp(0, screen.width - size);
            newY = newY.clamp(0, screen.height - size);

            position = Offset(newX, newY);

            if (isExpanded) {
              _recalculateExpandDirection(screen);
            }
          });
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              width: size,
              height: isExpanded ? expandedHeight : size,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
              ),
              child: Stack(
                alignment: expandDown
                    ? Alignment.bottomCenter
                    : Alignment.topCenter,
                children: [
                  /// LOGOUT
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    top: expandDown ? size * 2 : null,
                    bottom: expandDown ? null : size * 2,
                    left: 0,
                    right: 0,
                    child: _menuIcon(
                      icon: LucideIcons.logOut,
                      onTap: widget.onLogout,
                    ),
                  ),

                  /// PRIMARY
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    top: expandDown ? size : null,
                    bottom: expandDown ? null : size,
                    left: 0,
                    right: 0,
                    child: _menuIcon(
                      icon: primaryIcon,
                      onTap: _handlePrimaryAction,
                    ),
                  ),

                  /// TOGGLE
                  Positioned(
                    top: expandDown ? 0 : null,
                    bottom: expandDown ? null : 0,
                    left: 0,
                    right: 0,
                    child: _menuIcon(
                      icon: isExpanded
                          ? LucideIcons.x
                          : LucideIcons.moreVertical,
                      onTap: () => _handleToggle(screen),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuIcon({required IconData icon, required VoidCallback onTap}) {
    return Material(
      type: MaterialType.transparency,
      child: InkResponse(
        onTap: onTap,
        radius: 28,
        customBorder: const CircleBorder(),
        splashColor: Colors.white.withValues(alpha: 0.2),
        child: SizedBox(width: size, height: size, child: Icon(icon, size: 22)),
      ),
    );
  }
}
