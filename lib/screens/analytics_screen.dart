// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:cyberops/services/analytics_service.dart';

// class AnalyticsScreen extends StatefulWidget {
//   final int userId;
//   const AnalyticsScreen({super.key, required this.userId});

//   @override
//   State<AnalyticsScreen> createState() => _AnalyticsScreenState();
// }

// class _AnalyticsScreenState extends State<AnalyticsScreen>
//     with SingleTickerProviderStateMixin {
//   final AnalyticsService _analyticsService = AnalyticsService();
//   bool _loading = true;
//   Map<String, dynamic> _data = {};

//   late AnimationController _controller;
//   late Animation<double> _fadeAnim;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );
//     _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo);
//     _loadAnalytics();
//   }

//   Future<void> _loadAnalytics() async {
//     final data = await _analyticsService.getUserAnalytics(widget.userId);
//     if (!mounted) return;
//     setState(() {
//       _data = data;
//       _loading = false;
//     });
//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

//     return Scaffold(
//       extendBody: true,
//       backgroundColor: Colors.black,
//       body: FadeTransition(
//         opacity: _fadeAnim,
//         child: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF001F2E), Color(0xFF003D40)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: _loading
//               ? const Center(
//                   child: CircularProgressIndicator(color: Colors.tealAccent),
//                 )
//               : RefreshIndicator(
//                   onRefresh: _loadAnalytics,
//                   color: Colors.tealAccent,
//                   child: LayoutBuilder(
//                     builder: (context, constraints) {
//                       return SingleChildScrollView(
//                         physics: const AlwaysScrollableScrollPhysics(),
//                         padding:
//                             EdgeInsets.fromLTRB(20, 100, 20, bottomPadding),
//                         child: ConstrainedBox(
//                           constraints:
//                               BoxConstraints(minHeight: constraints.maxHeight),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               _buildOverview(),
//                               const SizedBox(height: 30),
//                               _buildAccuracyGauge(),
//                               const SizedBox(height: 40),
//                               _buildScenarioBars(),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }

//   // 🧩 Overview summary (Sessions & Accuracy)
//   Widget _buildOverview() {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.06),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.tealAccent.withOpacity(0.4)),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _buildStatBox(
//             title: "Sessions",
//             value: _data['totalSessions'].toString(),
//             icon: Icons.play_circle_outline,
//           ),
//           _buildStatBox(
//             title: "Accuracy",
//             value:
//                 "${((_data['averageAccuracy'] ?? 0.0) * 100).toStringAsFixed(1)}%",
//             icon: Icons.track_changes,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatBox({
//     required String title,
//     required String value,
//     required IconData icon,
//   }) {
//     return Column(
//       children: [
//         Icon(icon, color: Colors.tealAccent, size: 28),
//         const SizedBox(height: 8),
//         Text(
//           value,
//           style: GoogleFonts.orbitron(
//             color: Colors.tealAccent,
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           title.toUpperCase(),
//           style: GoogleFonts.orbitron(
//             color: Colors.white70,
//             fontSize: 11,
//             letterSpacing: 1.2,
//           ),
//         ),
//       ],
//     );
//   }

//   // 🎯 Circular custom accuracy gauge
//   Widget _buildAccuracyGauge() {
//     final accuracy = ((_data['averageAccuracy'] ?? 0.0) * 100).clamp(0.0, 100.0);

//     return Column(
//       children: [
//         Text(
//           "Accuracy Overview",
//           style: GoogleFonts.orbitron(
//             color: Colors.white,
//             fontSize: 16,
//             letterSpacing: 1.2,
//           ),
//         ),
//         const SizedBox(height: 20),
//         SizedBox(
//           height: 160,
//           width: 160,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               Container(
//                 height: 160,
//                 width: 160,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: Colors.tealAccent.withOpacity(0.2),
//                     width: 12,
//                   ),
//                 ),
//               ),
//               ShaderMask(
//                 shaderCallback: (rect) => SweepGradient(
//                   startAngle: 0.0,
//                   endAngle: 3.14 * 2,
//                   stops: [accuracy / 100, accuracy / 100],
//                   colors: [Colors.tealAccent, Colors.transparent],
//                 ).createShader(rect),
//                 child: Container(
//                   height: 160,
//                   width: 160,
//                   decoration: const BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//               // 💡 Text with shadow stroke for visibility
//               Text(
//                 "${accuracy.toStringAsFixed(1)}%",
//                 style: GoogleFonts.orbitron(
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.tealAccent,
//                   shadows: [
//                     Shadow(
//                       color: Colors.black.withOpacity(0.7),
//                       blurRadius: 4,
//                       offset: const Offset(1, 1),
//                     ),
//                     Shadow(
//                       color: Colors.black.withOpacity(0.5),
//                       blurRadius: 8,
//                       offset: const Offset(-1, -1),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   // 📈 Scenario accuracy bars with readable overlay text
//   Widget _buildScenarioBars() {
//     final List<Map<String, dynamic>> scenarios =
//         List<Map<String, dynamic>>.from(_data['scenarios'] ?? []);

//     if (scenarios.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.only(top: 20),
//         child: Text(
//           "No scenario data available.",
//           style: GoogleFonts.orbitron(color: Colors.white70, fontSize: 13),
//         ),
//       );
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Scenario Performance",
//           style: GoogleFonts.orbitron(
//             color: Colors.white,
//             fontSize: 16,
//             letterSpacing: 1.2,
//           ),
//         ),
//         const SizedBox(height: 16),
//         ...scenarios.map((s) {
//           final corrects = s['corrects'] ?? 0;
//           final attempts = s['attempts'] ?? 1;
//           final accuracy = (corrects / attempts * 100).clamp(0.0, 100.0);

//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Scenario ${s['scenario_id']}",
//                   style: GoogleFonts.orbitron(
//                     color: Colors.tealAccent,
//                     fontSize: 13,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Stack(
//                   alignment: Alignment.centerRight,
//                   children: [
//                     Container(
//                       height: 10,
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                         color: Colors.white12,
//                         borderRadius: BorderRadius.circular(6),
//                       ),
//                     ),
//                     AnimatedContainer(
//                       duration: const Duration(milliseconds: 600),
//                       height: 10,
//                       width:
//                           (accuracy / 100) * MediaQuery.of(context).size.width * 0.85,
//                       decoration: BoxDecoration(
//                         color: Colors.tealAccent,
//                         borderRadius: BorderRadius.circular(6),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.tealAccent.withOpacity(0.4),
//                             blurRadius: 8,
//                             spreadRadius: 1,
//                           ),
//                         ],
//                       ),
//                     ),
//                     // ✅ Overlay text for percentage — always visible
//                     Positioned(
//                       right: 6,
//                       child: Text(
//                         "${accuracy.toStringAsFixed(1)}%",
//                         style: GoogleFonts.orbitron(
//                           fontSize: 11,
//                           fontWeight: FontWeight.bold,
//                           color: accuracy > 50
//                               ? Colors.black
//                               : Colors.white, // dynamic contrast
//                           shadows: [
//                             Shadow(
//                               color: Colors.black.withOpacity(0.7),
//                               blurRadius: 3,
//                               offset: const Offset(1, 1),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   "Avg Time: ${(s['avg_time'] ?? 0).toStringAsFixed(1)}s",
//                   style: GoogleFonts.orbitron(
//                     color: Colors.white70,
//                     fontSize: 11,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ],
//     );
//   }
// }
