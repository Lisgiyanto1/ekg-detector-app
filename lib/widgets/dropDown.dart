import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CustomDropdownCard extends StatefulWidget {
  final IconData iconcheck;
  final Widget title;
  final String recommendation;


  const CustomDropdownCard({
    super.key,
    required this.iconcheck,
    required this.title,
    required this.recommendation,
  
  });

  @override
  State<CustomDropdownCard> createState() => _CustomDropdownCardState();
}

class _CustomDropdownCardState extends State<CustomDropdownCard>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late final List<String> items;

  @override
  void initState() {
    super.initState();

    items = widget.recommendation
        .split(';')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0),
      padding: const EdgeInsets.only(right: 30, left: 30),
      decoration: BoxDecoration(
        color: const Color.fromARGB(0, 255, 227, 224), // warna seperti contoh
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          /// HEADER
          Column(
            children: [
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [Icon(widget.iconcheck), widget.title],
              ),
              const Divider(thickness: 1, indent: 35.0),
            ],
          ),

          /// CONTENT (ANIMATED)
          Padding(
            padding: isExpanded
                ? EdgeInsets.only(top: 40, left: 35)
                : EdgeInsets.only(top: 13, left: 35),
            child: Column(
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: isExpanded
                      ? Padding(
                          padding: isExpanded
                              ? EdgeInsets.only(top: 5)
                              : EdgeInsets.all(0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// RECOMMENDATION LIST
                              ...items.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text("• "),
                                      Expanded(
                                        child: Text(
                                          e,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Stack(
                      children: [
                        isExpanded
                            ? const Divider(thickness: 1)
                            : Divider(thickness: 0, color: Colors.transparent),

                        Padding(
                          padding: const EdgeInsets.only(top: 9),
                          child: Center(
                            child: Container(
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                                color: const Color.fromARGB(126, 185, 185, 185),
                              ),
                              child: Center(
                                child: AnimatedRotation(
                                  turns: isExpanded ? 0.5 : 0.0,
                                  duration: const Duration(milliseconds: 250),
                                  child: const Icon(
                                    LucideIcons.listFilter,
                                    color: Color.fromARGB(255, 102, 102, 102),
                                  ),
                                ),
                              ),
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
        ],
      ),
    );
  }
}
