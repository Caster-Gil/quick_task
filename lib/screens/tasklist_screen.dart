import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'project_screen.dart';

class TaskListScreen extends StatefulWidget {
  final String projectId;
  const TaskListScreen({super.key, required this.projectId});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchProjectData() async {
    return await _firestore.collection('projects').doc(widget.projectId).get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _fetchTasks() {
    return _firestore
        .collection('projects')
        .doc(widget.projectId)
        .collection('tasks')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProjectsScreen(),
                            ),
                          );
                        },
                      ),
                      FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        future: _fetchProjectData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Text("Loading...", style: TextStyle(fontSize: 20));
                          }
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Text("Unknown Project", style: TextStyle(fontSize: 20));
                          }
                          String projectName = snapshot.data!.data()?['name'] ?? "Project";
                          return Text(
                            projectName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8BAEDC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "New Task",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Task Lists",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: _fetchTasks(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Text("No tasks yet.", style: TextStyle(color: Colors.grey));
                              }
                              final tasks = snapshot.data!.docs;
                              return Column(
                                children: tasks.map((taskDoc) {
                                  final taskData = taskDoc.data();
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.circle, size: 10, color: Color(0xFF8BAEDC)),
                                        const SizedBox(width: 10),
                                        Text(taskData['title'] ?? 'Untitled Task'),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: _fetchProjectData(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        }
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text("No members found."),
                          );
                        }
                        final projectData = snapshot.data!.data();
                        final List<dynamic> members = projectData?['members'] ?? [];
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Members",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...members.map((member) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.person, size: 18, color: Color(0xFF8BAEDC)),
                                        const SizedBox(width: 10),
                                        Text(member.toString()),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}