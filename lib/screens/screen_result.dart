import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_ekg_detector/features/scan/ekg_repository.dart';
import 'package:flutter_ekg_detector/widgets/dropDown.dart';
import 'package:flutter_ekg_detector/widgets/result_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ResultScreen extends StatelessWidget {
  final EkgRecommendation data;
  final String imagePath;

  const ResultScreen({super.key, required this.data, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final expandHeight = 160.0;
    final double widthScreen = MediaQuery.of(context).size.width;
    // Tentukan warna berdasarkan tingkat kedaruratan
    Color statusColor = Colors.green;
    if (data.urgency.toLowerCase().contains("sedang")) {
      statusColor = Colors.orange;
    }
    if (data.urgency.toLowerCase().contains("tinggi") ||
        data.urgency.toLowerCase().contains("darurat")) {
      statusColor = Colors.red;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            pinned: false,
            floating: false,
            expandedHeight: expandHeight,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Hasil Deteksi',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.start,
              ),
              background: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File(imagePath)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: ResultCard(title: data.label, label: data.label),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: CustomDropdownCard(
                iconcheck: LucideIcons.checkCircle,
                title: const Text("Tindak Lanjut", style: TextStyle(
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.w600,
                  fontSize: 16
                ),),
                recommendation: data.treatment,
              ),
            ),
          ),
          SliverToBoxAdapter(
            
            child: CustomDropdownCard(
              iconcheck: LucideIcons.checkCircle,
              title: const Text("Rekomendasi Obat", style: TextStyle(
                fontFamily: "Montserrat",
                fontWeight: FontWeight.w600,
                fontSize: 16
              ),),
              recommendation: data.medicine,
            ),
          ),

          SliverToBoxAdapter(
            child: _buildInfoCard(
              "🛡️ Pencegahan",
              data.prevention,
              Icons.shield_outlined,
            ),
          ),

          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.stretch,
          //   children: [
          //     // Gambar Hasil Capture
          //     Container(
          //       height: 250,
          //       decoration: BoxDecoration(
          //         image: DecorationImage(
          //           image: FileImage(File(imagePath)),
          //           fit: BoxFit.cover,
          //         ),
          //       ),
          //       child: Container(
          //         decoration: BoxDecoration(
          //           gradient: LinearGradient(
          //             begin: Alignment.topCenter,
          //             end: Alignment.bottomCenter,
          //             colors: [
          //               Colors.transparent,
          //               Colors.black.withOpacity(0.7),
          //             ],
          //           ),
          //         ),
          //         alignment: Alignment.bottomLeft,
          //         padding: const EdgeInsets.all(16),
          //         child: Text(
          //           data.label,
          //           style: const TextStyle(
          //             color: Colors.white,
          //             fontSize: 24,
          //             fontWeight: FontWeight.bold,
          //           ),
          //         ),
          //       ),
          //     ),

          //     Padding(
          //       padding: const EdgeInsets.all(16.0),
          //       child: Column(
          //         children: [
          //           // Kartu Status
          //           Container(
          //             padding: const EdgeInsets.all(16),
          //             decoration: BoxDecoration(
          //               color: statusColor.withOpacity(0.1),
          //               borderRadius: BorderRadius.circular(12),
          //               border: Border.all(color: statusColor),
          //             ),
          //             child: Row(
          //               children: [
          //                 Icon(
          //                   Icons.warning_amber_rounded,
          //                   color: statusColor,
          //                   size: 40,
          //                 ),
          //                 const SizedBox(width: 16),
          //                 Expanded(
          //                   child: Column(
          //                     crossAxisAlignment: CrossAxisAlignment.start,
          //                     children: [
          //                       Text(
          //                         "Tingkat Kedaruratan",
          //                         style: TextStyle(
          //                           color: statusColor,
          //                           fontWeight: FontWeight.bold,
          //                         ),
          //                       ),
          //                       Text(
          //                         data.urgency.toUpperCase(),
          //                         style: TextStyle(
          //                           color: statusColor,
          //                           fontSize: 18,
          //                           fontWeight: FontWeight.bold,
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //           const SizedBox(height: 20),

          //           // Detail Informasi (Accordion / List)
          //           _buildInfoCard(
          //             "🏥 Tindak Lanjut",
          //             data.treatment,
          //             Icons.medical_services_outlined,
          //           ),
          //           _buildInfoCard(
          //             "💊 Rekomendasi Obat",
          //             data.medicine,
          //             Icons.medication_outlined,
          //           ),
          //           _buildInfoCard(
          //             "🛡️ Pencegahan",
          //             data.prevention,
          //             Icons.shield_outlined,
          //           ),
          //         ],
          //       ),
          //     ),
          //   ],
          // ),

          // GlassFloatingMenu(
          //   mode: FloatingMenuMode.result,
          //   onPrimaryAction: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (_) => const ScreenOne()),
          //     );
          //   },
          //   onLogout: () {
          //     showDialog(
          //       context: context,
          //       builder: (_) => LogoutConfirmationDialog(
          //         onCancel: () => Navigator.pop(context),
          //         onConfirm: () {
          //           context.read<AuthBloc>().add(LogoutRequested());
          //           Navigator.pushAndRemoveUntil(
          //             context,
          //             MaterialPageRoute(
          //               builder: (_) => const RegisterScreen(),
          //             ),
          //             (_) => false,
          //           );
          //         },
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    // Split berdasarkan ';'
    final List<String> items = content
        .split(';')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blueAccent),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(),

            // ===== LIST PER POINT =====
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("•  ", style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
