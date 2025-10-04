import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  // Form controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController assignController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  // Name input for wheel
  final TextEditingController nameController = TextEditingController();

  // Stream controller required by flutter_fortune_wheel
  final StreamController<int> selectedController = StreamController<int>();

  // The wheel's items (starts empty)
  final List<String> members = [];

  // Last selected index (used to display result)
  int? lastSelectedIndex;

  @override
  void dispose() {
    // Always close controllers to avoid memory leaks
    titleController.dispose();
    assignController.dispose();
    descController.dispose();
    dateController.dispose();
    nameController.dispose();
    selectedController.close();
    super.dispose();
  }

  void addName() {
    final name = nameController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      members.add(name);
      nameController.clear();
    });
  }

  void spinWheel() {
    if (members.isEmpty) return; // don't spin empty wheel
    final randIndex = Random().nextInt(members.length);
    // send the chosen index to the FortuneWheel stream
    selectedController.add(randIndex);
    // update UI and assign field
    setState(() {
      lastSelectedIndex = randIndex;
      assignController.text = members[randIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Task")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Task form
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: assignController, decoration: const InputDecoration(labelText: "Assign to")),
            TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
            TextField(controller: dateController, decoration: const InputDecoration(labelText: "Due Date (DD/MM/YYYY)")),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () {
              // Your "Create" logic here
            }, child: const Text("Create")),

            const SizedBox(height: 20),

            // Add name row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "Enter name for wheel"),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: addName, child: const Text("Add")),
              ],
            ),

            const SizedBox(height: 20),

            // The wheel (placeholder when empty)
            SizedBox(
              height: 220,
              child: members.isEmpty
                  ? const Center(child: Text("No names added yet", style: TextStyle(fontSize: 16, color: Colors.grey)))
                  : FortuneWheel(
                      // provide the stream here (package expects Stream<int>)
                      selected: selectedController.stream,
                      // prevent auto animate on first build if you like:
                      animateFirst: false,
                      items: [
                        for (var name in members)
                          FortuneItem(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                name,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                      ],
                    ),
            ),

            const SizedBox(height: 12),
            ElevatedButton(onPressed: spinWheel, child: const Text("Spin")),

            const SizedBox(height: 12),
            if (lastSelectedIndex != null)
              Text(
                "🎉 Assigned to: ${members[lastSelectedIndex!]}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}