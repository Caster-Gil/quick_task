import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'project_screen.dart';
import 'setting_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 50,
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
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "35% Completed",
                                style: TextStyle(color: Colors.green),
                              ),
                              Text(
                                "25% In Progress",
                                style: TextStyle(color: Colors.blue),
                              ),
                              Text(
                                "40% Delayed",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),

            // Upcoming Tasks
            StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('tasks').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Card(
                    child: ListTile(
                      title: const Text("Upcoming Tasks"),
                      subtitle: const Text(
                        "No tasks available. Create a project first!",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                final tasks = snapshot.data!.docs;
                return Card(
                  child: ListTile(
                    title: const Text("Upcoming Tasks"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: tasks
                          .map((task) => Text("✔ ${task['title']}"))
                          .toList(),
                    ),
                  ),
                );
              },
            ),

            // Projects
            StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('projects').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Card(
                    child: ListTile(
                      title: const Text("Projects"),
                      subtitle: const Text(
                        "No projects created yet.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                final projects = snapshot.data!.docs;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProjectsScreen(),
                      ),
                    );
                  },
                  child: Card(
                    child: ListTile(
                      title: const Text("Projects"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: projects
                            .map((project) => Text("• ${project['name']}"))
                            .toList(),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Team Members
            StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('teamMembers').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Card(
                    child: ListTile(
                      title: const Text("Team Members"),
                      subtitle: const Text(
                        "No team members added yet.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }
                final members = snapshot.data!.docs;
                return Card(
                  child: ListTile(
                    title: const Text("Team Members"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: members
                          .map((member) => Text("• ${member['name']}"))
                          .toList(),
                    ),
                  ),
                );
              },
            ),

            const Spacer(),

            // Bottom Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  child: const Text("Task List"),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "No projects available. Create a project first!",
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
                      builder: (context) => const ProjectsScreen(),
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
