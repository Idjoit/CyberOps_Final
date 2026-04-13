import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

/// Entry point of the CyberOps application
/// ------------------------------------------------------------
/// This function:
/// - Ensures Flutter bindings are initialized
/// - Initializes Firebase services
/// - Launches the main application widget
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before the app starts
  await Firebase.initializeApp();

  runApp(const CyberOpsApp());
}

/// Root widget of the CyberOps application
class CyberOpsApp extends StatelessWidget {
  const CyberOpsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      /// Application title (used by OS/task switcher)
      title: 'CyberOps',

      /// Removes the debug banner in development mode
      debugShowCheckedModeBanner: false,

      /// Global theme configuration
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        fontFamily: 'Roboto',
      ),

      /// First screen shown when app launches
      home: const SplashScreen(),
    );
  }
}
