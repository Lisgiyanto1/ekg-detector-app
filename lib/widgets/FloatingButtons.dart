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
  bool isExpanded = false;

  static const double size = 56;
  static const double expandedHeight = 168;

  void _handlePrimaryAction() {
    setState(() => isExpanded = false);

    // LOGIKA TAMBAHAN: Tampilkan Modal jika di mode home (Scan)
    if (widget.mode == FloatingMenuMode.home) {
      showDialog(
        context: context,
        barrierColor: Colors.black.withValues(
          alpha: 0.5,
        ), // Efek redup di belakang modal
        builder: (context) => const ScanModal(),
      );
    } else {
      // Jika bukan mode home, jalankan aksi default
      widget.onPrimaryAction();
    }
  }

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
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
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

                /// ===== PRIMARY (SCAN / HOME) =====
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  top: isExpanded ? size : size,
                  left: 0,
                  right: 0,
                  child: _menuIcon(
                    icon: primaryIcon,
                    onTap: _handlePrimaryAction, // Menggunakan handler baru
                  ),
                ),

                /// ===== TOGGLE =====
                // Posisinya statis di bawah (Stack paling atas)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _menuIcon(
                    icon: isExpanded ? LucideIcons.x : LucideIcons.moreVertical,
                    onTap: () {
                      setState(() => isExpanded = !isExpanded);
                    },
                  ),
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
        splashColor: Colors.white.withValues(alpha: 0.2),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: 22, color: Colors.black87),
        ),
      ),
    );
  }
}
