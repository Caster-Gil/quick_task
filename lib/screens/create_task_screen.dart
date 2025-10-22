import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';

class CreateTaskScreen extends StatefulWidget {
  final String projectId;
  final String projectName;

  const CreateTaskScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  // Task info controllers
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _assignedToController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  // Wheel controllers
  final TextEditingController _wheelNameController = TextEditingController();
  final StreamController<int> _wheelController = StreamController<int>();
  final List<String> wheelNames = [];

  @override
  void dispose() {
    _taskNameController.dispose();
    _descriptionController.dispose();
    _assignedToController.dispose();
    _dueDateController.dispose();
    _wheelNameController.dispose();
    _wheelController.close();
    super.dispose();
  }

  void _createTask() async {
    final taskName = _taskNameController.text.trim();
    final description = _descriptionController.text.trim();
    final assignedTo = _assignedToController.text.trim();
    final dueDate = _dueDateController.text.trim();

    if (taskName.isEmpty) return;

    await FirebaseFirestore.instance.collection('tasks').add({
      'project_id': widget.projectId,
      'name': taskName,
      'description': description,
      'assigned_to': assignedTo,
      'due_date': dueDate,
      'created_at': FieldValue.serverTimestamp(),
      'status': 'in progress',
    });

    _taskNameController.clear();
    _descriptionController.clear();
    _assignedToController.clear();
    _dueDateController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Task created successfully!')),
    );
  }

  void _addNameToWheel() {
    final name = _wheelNameController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      wheelNames.add(name);
    });
    _wheelNameController.clear();
  }

  void _spinWheel() {
    if (wheelNames.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least 2 names to spin the wheel")),
      );
      return;
    }

    final randomIndex = (0 + (wheelNames.length * (1.0)).toInt()); // replace with proper random
    _wheelController.add(randomIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Task for ${widget.projectName}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Task Info Block
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Task Name',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _taskNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        hintText: 'Enter task name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Description',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        hintText: 'Enter task description',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Assigned To',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _assignedToController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        hintText: 'Enter assignee name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Due Date',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _dueDateController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                        hintText: 'Enter due date (DD/MM/YYYY)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: _createTask, child: const Text('Create Task')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Wheel Input Block
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Wheel Names',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _wheelNameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              hintText: 'Enter name for wheel',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addNameToWheel,
                          child: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: wheelNames.length < 2
                          ? const Center(
                              child: Text(
                                "Add at least 2 names to spin the wheel",
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : FortuneWheel(
                              selected: _wheelController.stream,
                              animateFirst: false,
                              items: [
                                for (var name in wheelNames)
                                  FortuneItem(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        name,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                        onPressed: _spinWheel, child: const Text('Spin')),
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
