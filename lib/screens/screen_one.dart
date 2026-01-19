import 'package:flutter/material.dart';

import '../widgets/FloatingButtons.dart';
import 'screen_two.dart';

class ScreenOne extends StatelessWidget {
  const ScreenOne({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Stack(
        children: [
          const Center(
            child: Text("INI Screen 1", style: TextStyle(fontSize: 24)),
          ),
          GlassFloatingMenu(
            mode: FloatingMenuMode.home,
            onPrimaryAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScreenTwo()),
              );
            },
          ),
        ],
      ),
    );
  }
}
