import 'package:flutter/material.dart';

import '../widgets/FloatingButtons.dart';

class ScreenTwo extends StatelessWidget {
  const ScreenTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Center(
            child: Text("Ini adalah screen 2", style: TextStyle(fontSize: 24)),
          ),
          GlassFloatingMenu(
            mode: FloatingMenuMode.result,
            onPrimaryAction: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
