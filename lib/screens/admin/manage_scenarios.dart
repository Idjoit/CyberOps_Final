import 'package:flutter/material.dart';
import 'package:cyberops/database/db_helper.dart';
import 'package:cyberops/models/scenario_model.dart';

class ManageScenariosScreen extends StatefulWidget {
  const ManageScenariosScreen({super.key});

  @override
  State<ManageScenariosScreen> createState() => _ManageScenariosScreenState();
}

class _ManageScenariosScreenState extends State<ManageScenariosScreen> {
  final DBHelper _dbHelper = DBHelper();
  List<Scenario> _scenarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScenarios();
  }

  Future<void> _loadScenarios() async {
    final db = await _dbHelper.database;
    final result = await db.query('scenarios', orderBy: 'difficulty ASC');
    setState(() {
      _scenarios = result.map((e) => Scenario.fromMap(e)).toList();
      _isLoading = false;
    });
  }

  Future<void> _deleteScenario(int id) async {
    final db = await _dbHelper.database;
    await db.delete('scenarios', where: 'scenario_id = ?', whereArgs: [id]);
    _loadScenarios();
  }

  void _showScenarioForm({Scenario? scenario}) {
    final titleController = TextEditingController(text: scenario?.title ?? '');
    final descController = TextEditingController(text: scenario?.description ?? '');
    final choiceAController = TextEditingController(text: scenario?.choiceA ?? '');
    final choiceBController = TextEditingController(text: scenario?.choiceB ?? '');
    final feedbackController = TextEditingController(text: scenario?.feedbackText ?? '');
    int difficulty = scenario?.difficulty ?? 1;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(scenario == null ? "Add Scenario" : "Edit Scenario"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
              TextField(controller: choiceAController, decoration: const InputDecoration(labelText: "Choice A")),
              TextField(controller: choiceBController, decoration: const InputDecoration(labelText: "Choice B")),
              TextField(controller: feedbackController, decoration: const InputDecoration(labelText: "Feedback")),
              DropdownButtonFormField<int>(
                value: difficulty,
                decoration: const InputDecoration(labelText: "Difficulty"),
                items: [1, 2, 3].map((d) => DropdownMenuItem(value: d, child: Text("Level $d"))).toList(),
                onChanged: (val) => difficulty = val!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final db = await _dbHelper.database;
              final data = {
                'title': titleController.text,
                'description': descController.text,
                'choice_a': choiceAController.text,
                'choice_b': choiceBController.text,
                'effect_a_security': 10,
                'effect_a_awareness': 5,
                'effect_a_money': -2,
                'effect_a_trust': 5,
                'effect_b_security': -10,
                'effect_b_awareness': -5,
                'effect_b_money': -3,
                'effect_b_trust': -5,
                'correct_choice': 'A',
                'feedback_text': feedbackController.text,
                'difficulty': difficulty,
                'category': 'Phishing',
                'image_path': '',
              };

              if (scenario == null) {
                await db.insert('scenarios', data);
              } else {
                await db.update('scenarios', data,
                    where: 'scenario_id = ?', whereArgs: [scenario.id]);
              }

              Navigator.pop(context);
              _loadScenarios();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Scenarios"),
        backgroundColor: Colors.blueGrey[800],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScenarioForm(),
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: _scenarios.length,
        itemBuilder: (context, index) {
          final s = _scenarios[index];
          return Card(
            child: ListTile(
              title: Text(s.title),
              subtitle: Text("Difficulty: ${s.difficulty}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showScenarioForm(scenario: s)),
                  IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteScenario(s.id!)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
