import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'project_screen.dart';
import 'setting_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<String> _getUsername(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data()?['username'] != null) {
      return doc['username'];
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QuickTask"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingScreen()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Task Overview Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Task Overview",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 150,
                      child: Row(
                        children: [
                          // Left: Text labels
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  "Completed",
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "In Progress",
                                  style: TextStyle(
                                      color: Colors.blue, fontSize: 16),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Delayed",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          // Right: Pie Chart
                          Expanded(
                            flex: 1,
                            child: Center(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: PieChart(
                                  PieChartData(
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40,
                                    borderData: FlBorderData(show: false),
                                    sections: [
                                      PieChartSectionData(
                                        value: 100,
                                        color: Colors.grey.shade200,
                                        showTitle: false,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Projects Section
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: firestore.collection('projects').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No projects available."));
                  }

                  // Filter projects where current user is a member or creator
                  final allProjects = snapshot.data!.docs;
                  final userProjects = allProjects.where((project) {
                    final projectData =
                        project.data() as Map<String, dynamic>? ?? {};
                    final members = List<String>.from(projectData['members'] ?? []);
                    final creatorId = projectData['creator_id'] ?? '';
                    return members.contains(currentUserId) || creatorId == currentUserId;
                  }).toList();

                  if (userProjects.isEmpty) {
                    return const Center(child: Text("You have no projects yet."));
                  }

                  return ListView.builder(
                    itemCount: userProjects.length,
                    itemBuilder: (context, index) {
                      final project = userProjects[index];
                      final projectData =
                          project.data() as Map<String, dynamic>? ?? {};
                      final creatorId = projectData['creator_id'] ?? '';

                      return FutureBuilder<String>(
                        future: _getUsername(creatorId),
                        builder: (context, usernameSnapshot) {
                          final creatorUsername =
                              usernameSnapshot.data ?? 'Loading...';

                          return Card(
                            child: ListTile(
                              title: Text(projectData['name'] ?? 'Unnamed Project'),
                              subtitle: Text("Created by: $creatorUsername"),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProjectsScreen(
                                      selectedProjectId: project.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // Bottom Buttons (always visible)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  child: const Text("Task List"),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Select a project first to see tasks.",
                        ),
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  child: const Text("Projects"),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
