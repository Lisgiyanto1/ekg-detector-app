import 'dart:io';
import 'dart:ui';

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

    Color statusColor = Colors.green;
    String text = "Hasil Sehat, Selamat Pertahankan dan Jaga Kesehatan Ya ....";

    if (data.urgency.toLowerCase().contains("sedang")) {
      statusColor = Colors.orange;
      text = "Hasil Lumayan Sehat Tetap Perhatikan Pola Hidup Sehat.";
    }
    if (data.urgency.toLowerCase().contains("tinggi") ||
        data.urgency.toLowerCase().contains("darurat")) {
      statusColor = Colors.red;
      text = "Hasil Bahaya. Harap Perhatikan Rekomendasi di Bawah ini";
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
                  fontSize: 10,
                  color: const Color.fromARGB(199, 247, 247, 247),
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
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color.fromARGB(0, 0, 0, 0), statusColor],
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top:300, right: 20, left: 20, bottom: 30),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                        child: Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                255,
                                226,
                                226,
                                226,
                              ).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 30, bottom: 30),
                              child: Column(
                                spacing: 20,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 30),
                                    child: Row(
                                      spacing: 15,
                                      children: [
                                        Icon(
                                          Icons.medical_services_outlined,
                                          fontWeight: FontWeight.w600,
                                          size: 30,
                                          color: const Color.fromARGB(255, 59, 59, 59),
                                        ),
                                        Text(
                                          "Anjuran",
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                              255,
                                              56,
                                              56,
                                              56,
                                            ),
                                            fontFamily: "Montserrat",
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 0),
                                  CustomDropdownCard(
                                    iconcheck: LucideIcons.checkCircle,
                                    title: const Text(
                                      "Tindak Lanjut",
                                      style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    recommendation: data.treatment,
                                  ),
                    
                                  CustomDropdownCard(
                                    iconcheck: LucideIcons.checkCircle,
                                    title: const Text(
                                      "Rekomendasi Obat",
                                      style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    recommendation: data.medicine,
                                  ),
                    
                                  CustomDropdownCard(
                                    iconcheck: LucideIcons.checkCircle,
                                    title: const Text(
                                      "Pencegahan",
                                      style: TextStyle(
                                        fontFamily: "Montserrat",
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    recommendation: data.prevention,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    child: ResultCard(
                      title: data.label,
                      label: data.label,
                      textGreet: text,
                    ),
                  ),
                ],
              ),
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
