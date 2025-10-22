import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskInfoScreen extends StatefulWidget {
  final String taskId;

  const TaskInfoScreen({super.key, required this.taskId});

  @override
  _TaskInfoScreenState createState() => _TaskInfoScreenState();
}

class _TaskInfoScreenState extends State<TaskInfoScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String _selectedStatus = "In Progress";
  final List<String> _statuses = ["Delayed", "In Progress", "Completed"];

  void _updateStatus(String status) async {
    try {
      await firestore.collection('tasks').doc(widget.taskId).update({
        'status': status,
      });
      setState(() {
        _selectedStatus = status;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Status updated to $status')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "Delayed":
        return Colors.red;
      case "In Progress":
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task Info")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firestore.collection('tasks').doc(widget.taskId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Task not found."));
          }

          final taskData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final name = taskData['name'] ?? "Untitled Task";
          final description = taskData['description'] ?? "No description";
          final assignedTo =
              taskData['assigned_to'] ?? "Unassigned"; // <-- direct username
          final dueDate = taskData['due_date'] ?? "No due date";
          final firestoreStatus = taskData['status'] ?? "In Progress";

          if (_statuses.contains(firestoreStatus)) {
            _selectedStatus = firestoreStatus;
          } else {
            _selectedStatus = "In Progress";
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Description: $description",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Assigned to: $assignedTo",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Due date: $dueDate",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Status:",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: _getStatusColor(
                                  _selectedStatus,
                                ).withOpacity(0.2),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedStatus,
                                underline: const SizedBox(),
                                icon: const Icon(Icons.keyboard_arrow_down),
                                items: _statuses
                                    .map(
                                      (status) => DropdownMenuItem(
                                        value: status,
                                        child: Text(status),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) {
                                  if (value != null) _updateStatus(value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
