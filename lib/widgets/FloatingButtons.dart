import 'dart:ui';

import 'package:flutter/material.dart';
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
  bool isExpanded = false;

  static const double size = 56;
  static const double expandedHeight = 168;

  @override
  Widget build(BuildContext context) {
    final IconData primaryIcon = widget.mode == FloatingMenuMode.home
        ? LucideIcons.scan
        : LucideIcons.home;

    return Positioned(
      bottom: 24,
      right: 24,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
            width: size,
            height: isExpanded ? expandedHeight : size,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                /// ===== LOGOUT =====
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  top: isExpanded ? 0 : size,
                  left: 0,
                  right: 0,
                  child: _menuIcon(
                    icon: LucideIcons.logOut,
                    onTap: () {
                      setState(() => isExpanded = false);
                      widget.onLogout();
                    },
                  ),
                ),

                /// ===== PRIMARY =====
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  top: isExpanded ? size : size,
                  left: 0,
                  right: 0,
                  child: _menuIcon(
                    icon: primaryIcon,
                    onTap: () {
                      setState(() => isExpanded = false);
                      widget.onPrimaryAction();
                    },
                  ),
                ),

                /// ===== TOGGLE =====
                _menuIcon(
                  icon: LucideIcons.moreVertical,
                  onTap: () {
                    setState(() => isExpanded = !isExpanded);
                  },
                ),
              ],
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
        containedInkWell: true,
        radius: 28,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: 22, color: Colors.black87),
        ),
      ),
    );
  }
}
