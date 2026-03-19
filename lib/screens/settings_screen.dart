import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.blueGrey[800],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text("App Preferences",
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text("Dark Mode", style: TextStyle(color: Colors.white)),
            value: true,
            onChanged: (_) {},
          ),
          ListTile(
            leading: const Icon(Icons.info, color: Colors.white),
            title: const Text("App Version 1.0.0",
                style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
