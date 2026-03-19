import 'package:cyberops/screens/learning_module_components/learning_module_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LearningModuleScreen extends StatelessWidget {
  final String userId; // ✅ Firestore user ID
  final bool isGuest;

  const LearningModuleScreen({
    super.key,
    required this.userId,
    this.isGuest = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "CyberOps Academy",
          style: GoogleFonts.orbitron(
            color: Colors.tealAccent,
            fontSize: 18,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black.withOpacity(0.6),
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001F2E), Color(0xFF003D40)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('learning_modules')
              .orderBy('order')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.tealAccent),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  "No learning modules available yet.",
                  style: GoogleFonts.orbitron(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              );
            }

            final modules = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index].data() as Map<String, dynamic>;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LearningModuleDetailScreen(
                          userId: userId,
                          title: module["title"] ?? "Untitled Module",
                          description: module["description"] ?? "",
                          heading: module["heading"] ?? "",
                          duration: module["duration"] ?? "Unknown",
                          sections: List<Map<String, dynamic>>.from(
                            (module["sections"] ?? []),
                          ),
                          // 🆕 Added dynamic data from Firestore
                          gameType: module["gameType"] ?? "strategy",
                          order: module["order"] ?? (index + 1),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.tealAccent.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.menu_book_rounded,
                            color: Colors.tealAccent, size: 50),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                module["title"] ?? "Untitled Module",
                                style: GoogleFonts.orbitron(
                                  color: Colors.tealAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                module["description"] ?? "",
                                style: GoogleFonts.orbitron(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 14, color: Colors.tealAccent),
                                  const SizedBox(width: 6),
                                  Text(
                                    module["duration"] ?? "Unknown",
                                    style: GoogleFonts.orbitron(
                                      color: Colors.tealAccent,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios,
                            color: Colors.tealAccent, size: 16),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
