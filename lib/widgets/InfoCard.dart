import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ekg_detector/widgets/ConcaveBevelTopRight.dart';

class HealthInfoCard extends StatelessWidget {
  final User user;
  final VoidCallback onLogout;

  const HealthInfoCard({super.key, required this.user, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final name = user.displayName ?? 'User';

    return AspectRatio(
      aspectRatio: 8 / 9,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          /// ================= CARD =================
          ClipPath(
            clipper: ConcaveTopRightClipper(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 130, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color.fromARGB(132, 255, 255, 255), Color.fromARGB(255, 136, 136, 136)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Happy Health',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    name,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "Don't Miss\na Beat",
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Don't miss your\nheartbeat / Don't\nignore the signs",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 20,
                      height: 1.4,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: const [
                      Text(
                        'Track Now',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.favorite, size: 16),
                    ],
                  ),
                ],
              ),
            ),
          ),

          /// ================= HEART =================
          Positioned(
            right: -10,
            bottom: -24,
            child: Image.asset('assets/heart.png', width: 180),
          ),

          /// ================= AVATAR (PRESISI) =================
          Positioned(
            top: 1,
            right: 1,
            child: GestureDetector(
              onTap: onLogout,
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
                  child: _AvatarContent(user: user),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//AVATAR
class _AvatarContent extends StatelessWidget {
  final User user;

  const _AvatarContent({required this.user});

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
