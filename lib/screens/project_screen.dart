import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_project_screen.dart';
import 'dashboard_screen.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DashboardScreen(),
              ),
            );
          },
        ),
        title: const Text("Projects"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateProjectScreen(),
                ),
              );
            },
            child: const Text(
              "New Project",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Projects in progress",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    StreamBuilder<QuerySnapshot>(
                      stream: firestore.collection('projects').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              "No projects in progress.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        final projects = snapshot.data!.docs;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: projects
                              .map((project) => Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.circle,
                                            color: Colors.blue, size: 10),
                                        const SizedBox(width: 8),
                                        Text(project['name']),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade400,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          _showJoinProjectDialog(context, firestore);
                        },
                        child: const Text(
                          "Join Project",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Join Project Popup
  void _showJoinProjectDialog(
      BuildContext context, FirebaseFirestore firestore) {
    final TextEditingController projectIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Join Project"),
          content: TextField(
            controller: projectIdController,
            decoration: const InputDecoration(
              hintText: "Enter Project ID",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final projectId = projectIdController.text.trim();
                if (projectId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid Project ID."),
                    ),
                  );
                  return;
                }

                try {
                  final projectDoc =
                      await firestore.collection('projects').doc(projectId).get();

                  if (projectDoc.exists) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Joined project: ${projectDoc['name']} successfully!"),
                      ),
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Project ID not found."),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Error joining project."),
                    ),
                  );
                }
              },
              child: const Text("Join"),
            ),
          ],
        );
      },
    );
  }
}