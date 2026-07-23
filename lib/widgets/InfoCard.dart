import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ekg_detector/widgets/ConcaveBevelTopRight.dart';

class HealthInfoCard extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;
  final bool isLoading; 

  const HealthInfoCard({
    super.key,
    required this.user,
    required this.onLogout,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final name = user.displayName ?? 'User';
    final bool showSkeleton = isLoading;

    return AspectRatio(
      aspectRatio: 8 / 9,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          /// ================= CARD INNER CONTENT =================
          ClipPath(
            clipper: ConcaveTopRightClipper(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 130, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(132, 255, 255, 255),
                    Color.fromARGB(255, 136, 136, 136),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 1. Teks 'Happy Health' + Ease In Animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeIn,
                    child: showSkeleton
                        ? const _SkeletonPulse(
                            key: ValueKey('sk_happy_health'),
                            child: _SkeletonBlock(
                              width: 130,
                              height: 22,
                              borderRadius: 4,
                            ),
                          )
                        : const Text(
                            'Happy Health',
                            key: ValueKey('txt_happy_health'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                  ),
                  const SizedBox(height: 4),

                  /// 2. Teks Nama User + Ease In Animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeIn,
                    child: showSkeleton
                        ? const _SkeletonPulse(
                            key: ValueKey('sk_name'),
                            child: _SkeletonBlock(
                              width: 80,
                              height: 16,
                              borderRadius: 4,
                            ),
                          )
                        : Text(
                            name,
                            key: const ValueKey('txt_name'),
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade700,
                            ),
                          ),
                  ),
                  const SizedBox(height: 18),

                  /// 3. Teks Utama "Don't Miss a Beat" + Ease In Animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    switchInCurve: Curves.easeIn,
                    child: showSkeleton
                        ? const _SkeletonPulse(
                            key: ValueKey('sk_headline'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SkeletonBlock(
                                  width: 190,
                                  height: 38,
                                  borderRadius: 6,
                                ),
                                SizedBox(height: 6),
                                _SkeletonBlock(
                                  width: 110,
                                  height: 38,
                                  borderRadius: 6,
                                ),
                              ],
                            ),
                          )
                        : const Text(
                            "Don't Miss\na Beat",
                            key: ValueKey('txt_headline'),
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),

                  /// 4. Teks Deskripsi Bawah + Ease In Animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    switchInCurve: Curves.easeIn,
                    child: showSkeleton
                        ? const _SkeletonPulse(
                            key: ValueKey('sk_desc'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SkeletonBlock(
                                  width: 160,
                                  height: 18,
                                  borderRadius: 4,
                                ),
                                SizedBox(height: 5),
                                _SkeletonBlock(
                                  width: 150,
                                  height: 18,
                                  borderRadius: 4,
                                ),
                                SizedBox(height: 5),
                                _SkeletonBlock(
                                  width: 120,
                                  height: 18,
                                  borderRadius: 4,
                                ),
                              ],
                            ),
                          )
                        : Text(
                            "Don't miss your\nheartbeat / Don't\nignore the signs",
                            key: const ValueKey('txt_desc'),
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 20,
                              height: 1.4,
                            ),
                          ),
                  ),
                  const Spacer(),

                  /// 5. Tombol Track Now / Row Bawah + Ease In Animation
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 550),
                    switchInCurve: Curves.easeIn,
                    child: showSkeleton
                        ? const _SkeletonPulse(
                            key: ValueKey('sk_track_row'),
                            child: Row(
                              children: [
                                _SkeletonBlock(
                                  width: 80,
                                  height: 16,
                                  borderRadius: 4,
                                ),
                                SizedBox(width: 6),
                                _SkeletonBlock(
                                  width: 16,
                                  height: 16,
                                  shape: BoxShape.circle,
                                ),
                              ],
                            ),
                          )
                        : const Row(
                            key: ValueKey('row_track_now'),
                            children: [
                              Text(
                                'Track Now',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              SizedBox(width: 6),
                              Icon(Icons.favorite, size: 16),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),

          /// ================= HEART ASSET LAYER =================
          Positioned(
            right: -10,
            bottom: -24,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              switchInCurve: Curves.easeIn,
              child: showSkeleton
                  ? const _SkeletonPulse(
                      key: ValueKey('sk_heart_img'),
                      child: SizedBox(
                        width: 180,
                        height: 180,
                        child: Center(
                          child: _SkeletonBlock(
                            width: 140,
                            height: 140,
                            shape: BoxShape
                                .circle, // Bentuk bundar bayangan aset jantung
                          ),
                        ),
                      ),
                    )
                  : Image.asset(
                      'assets/heart.png',
                      key: const ValueKey('img_heart'),
                      width: 180,
                    ),
            ),
          ),

          /// ================= AVATAR LAYER (PRESISI) =================
          Positioned(
            top: 1,
            right: 1,
            child: GestureDetector(
              onTap: showSkeleton
                  ? null
                  : onLogout, // Matikan klik logout saat loading
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeIn,
                    child: showSkeleton
                        ? const _SkeletonPulse(
                            key: ValueKey('sk_avatar_box'),
                            child: _SkeletonBlock(
                              width: 60,
                              height: 60,
                              borderRadius:
                                  0, // Mengikuti clip dari ClipRRect induknya
                            ),
                          )
                        : _AvatarContent(
                            key: const ValueKey('real_avatar'),
                            user: user,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= HELPER SKELETON WIDGETS (ANIMATED) =================

class _SkeletonPulse extends StatefulWidget {
  final Widget child;
  const _SkeletonPulse({super.key, required this.child});

  @override
  State<_SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<_SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 900,
      ), // Kecepatan kedipan premium halus
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(
        begin: 0.35,
        end: 0.7,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final BoxShape shape;

  const _SkeletonBlock({
    required this.width,
    required this.height,
    this.borderRadius = 0,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors
            .black26, // Warna solid gelap transparan di atas gradient background
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius)
            : null,
      ),
    );
  }
}

/// ================= AVATAR CONTENT SUBCONTENT =================
class _AvatarContent extends StatelessWidget {
  final User user;

  const _AvatarContent({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final String initial = (user.displayName?.isNotEmpty ?? false)
        ? user.displayName![0].toUpperCase()
        : 'U';

    // ===== PRIORITY 1 : NETWORK IMAGE =====
    if (user.photoURL != null && user.photoURL!.isNotEmpty) {
      return Image.network(
        user.photoURL!,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initialAvatar(initial),
      );
    }

    // ===== PRIORITY 2 : ASSET IMAGE =====
    return Image.asset(
      'assets/avatar.png',
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _initialAvatar(initial),
    );
  }

  Widget _initialAvatar(String initial) {
    return Container(
      width: 60,
      height: 60,
      color: const Color(0xFF0E9DA8),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
