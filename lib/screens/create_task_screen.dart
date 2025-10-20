import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tasklist_screen.dart';

class CreateTaskScreen extends StatefulWidget {
  final String? projectId; // optional projectId

  const CreateTaskScreen({super.key, this.projectId});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  // Form controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController assignController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  final StreamController<int> selectedController = StreamController<int>();
  final List<String> members = [];
  int? lastSelectedIndex;
  bool isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    assignController.dispose();
    descController.dispose();
    dateController.dispose();
    nameController.dispose();
    selectedController.close();
    super.dispose();
  }

  // Add name to the wheel
  void addName() {
    final name = nameController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      members.add(name);
      nameController.clear();
    });
  }

  // Spin the wheel
  void spinWheel() {
    if (members.isEmpty) return;
    final randIndex = Random().nextInt(members.length);
    selectedController.add(randIndex);
    setState(() {
      lastSelectedIndex = randIndex;
      assignController.text = members[randIndex];
    });
  }

  // Create Task Function — Saves to Firestore and redirects
  Future<void> createTask() async {
    final title = titleController.text.trim();
    final assignedTo = assignController.text.trim();
    final description = descController.text.trim();
    final dueDate = dateController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (title.isEmpty ||
        assignedTo.isEmpty ||
        description.isEmpty ||
        dueDate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user logged in")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('tasks').add({
        'title': title,
        'assigned_to': assignedTo,
        'description': description,
        'due_date': dueDate,
        'created_by': user.uid,
        'created_at': FieldValue.serverTimestamp(),
        'project_id': widget.projectId ?? '', // store projectId if available
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task created successfully!")),
      );

      // Clear fields
      titleController.clear();
      assignController.clear();
      descController.clear();
      dateController.clear();
      setState(() => lastSelectedIndex = null);

      // Redirect after short delay
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        if (widget.projectId != null && widget.projectId!.isNotEmpty) {
          // Navigate to TaskListScreen if project exists
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TaskListScreen(projectId: widget.projectId!),
            ),
          );
        } else {
          // Show message if no project exists
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    "Task created, but no project exists. Create a project first.")),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating task: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Task")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: assignController,
              decoration: const InputDecoration(labelText: "Assign to"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: "Due Date (DD/MM/YYYY)",
              ),
            ),
            const SizedBox(height: 12),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: createTask,
                    child: const Text("Create"),
                  ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Enter name for wheel",
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: addName, child: const Text("Add")),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: members.isEmpty
                  ? const Center(
                      child: Text(
                        "No names added yet",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : FortuneWheel(
                      selected: selectedController.stream,
                      animateFirst: false,
                      items: [
                        for (var name in members)
                          FortuneItem(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: spinWheel, child: const Text("Spin")),
            const SizedBox(height: 12),
            if (lastSelectedIndex != null)
              Text(
                "🎉 Assigned to: ${members[lastSelectedIndex!]}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}