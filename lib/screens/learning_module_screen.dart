import 'package:cyberops/screens/learning_module_components/learning_module_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// LearningModuleScreen
/// ------------------------------------------------------------
/// Displays a list of learning modules fetched in real-time from Firestore.
///
/// Features:
/// - Stream-based Firestore data (real-time updates)
/// - Displays module list (title, description, duration)
/// - Navigates to module detail screen on tap
/// - Supports user tracking via userId (Firestore-based users)
class LearningModuleScreen extends StatelessWidget {

  /// Firestore user ID used for tracking progress
  final String userId;

  /// Flag to determine if user is a guest (optional future use)
  final bool isGuest;

  const LearningModuleScreen({
    super.key,
    required this.userId,
    this.isGuest = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Main dark theme background
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

      // Gradient background for cyber-themed UI
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF001F2E), Color(0xFF003D40)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        // Real-time Firestore listener for learning modules
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('learning_modules')
              .orderBy('order')
              .snapshots(),

          builder: (context, snapshot) {

            // Show loading indicator while fetching data
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.tealAccent,
                ),
              );
            }

            // Handle empty or missing data
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

            // Convert Firestore documents to list
            final modules = snapshot.data!.docs;

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: modules.length,

              itemBuilder: (context, index) {

                // Extract module data from Firestore document
                final module =
                    modules[index].data() as Map<String, dynamic>;

                return GestureDetector(

                  // Navigate to module detail screen when tapped
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LearningModuleDetailScreen(

                          userId: userId,

                          // Module core details
                          title: module["title"] ?? "Untitled Module",
                          description: module["description"] ?? "",
                          heading: module["heading"] ?? "",
                          duration: module["duration"] ?? "Unknown",

                          // Convert Firestore array into typed list
                          sections: List<Map<String, dynamic>>.from(
                            (module["sections"] ?? []),
                          ),

                          // Additional module metadata
                          gameType: module["gameType"] ?? "strategy",
                          order: module["order"] ?? (index + 1),
                        ),
                      ),
                    );
                  },

                  child: Container(

                    // Card spacing
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),

                    // Card styling (glass + glow effect)
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.tealAccent.withOpacity(0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.tealAccent.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),

                    // Module preview layout
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          color: Colors.tealAccent,
                          size: 50,
                        ),

                        const SizedBox(width: 16),

                        // Module text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              // Module title
                              Text(
                                module["title"] ?? "Untitled Module",
                                style: GoogleFonts.orbitron(
                                  color: Colors.tealAccent,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Module description
                              Text(
                                module["description"] ?? "",
                                style: GoogleFonts.orbitron(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Duration row
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.tealAccent,
                                  ),
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

                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.tealAccent,
                          size: 16,
                        ),
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
