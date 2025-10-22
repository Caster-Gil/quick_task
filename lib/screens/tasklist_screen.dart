import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_task_screen.dart';
import 'taskinfo_screen.dart';

class TaskListScreen extends StatelessWidget {
  final String projectId;
  final String projectName;

  const TaskListScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  Future<String> _getUsername(String uid) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (doc.exists && doc.data()?['username'] != null) {
      return doc['username'];
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(title: Text("Tasks for $projectName")),
      body: FutureBuilder<DocumentSnapshot>(
        future: firestore.collection('projects').doc(projectId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Project not found"));
          }

          final projectData =
              snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final code = projectData['code'] ?? 'No code available';
          final memberIds = List<String>.from(projectData['members'] ?? []);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Join Code
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12.0),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  "Project Join Code: $code",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blueAccent,
                  ),
                ),
              ),

              // Members Section
              if (memberIds.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    "Members",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                SizedBox(
                  height: 80,
                  child: FutureBuilder<List<String>>(
                    future: Future.wait(
                      memberIds.map((id) => _getUsername(id)),
                    ),
                    builder: (context, snapshot) {
                      final usernames = snapshot.data ?? memberIds;
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: usernames.length,
                        itemBuilder: (context, index) {
                          final username = usernames[index];
                          return Container(
                            width: 70,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.blue.shade100,
                                  child: const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  username,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Task List Section
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: firestore
                      .collection('tasks')
                      .where('project_id', isEqualTo: projectId)
                      .orderBy('created_at', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text("No tasks for this project."),
                      );
                    }

                    final tasks = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final taskData =
                            tasks[index].data() as Map<String, dynamic>? ?? {};
                        final taskId = tasks[index].id;
                        final name = taskData['name'] ?? "Untitled Task";
                        final assignedTo =
                            taskData['assigned_to'] ?? "Unassigned";
                        final dueDate = taskData['due_date'] ?? "No due date";

                        return Card(
                          key: ValueKey(taskId),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(name),
                            subtitle: Text("Assigned to: $assignedTo"),
                            trailing: Text(dueDate),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      TaskInfoScreen(taskId: taskId),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateTaskScreen(
                projectId: projectId,
                projectName: projectName,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
