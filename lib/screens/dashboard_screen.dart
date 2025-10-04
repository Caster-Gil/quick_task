import 'package:flutter/material.dart';
import 'task_list.dart';
import 'project_screen.dart';
import 'create_task_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QuickTask"),
        actions: const [
          Icon(Icons.settings),
          SizedBox(width: 10),
          Icon(Icons.person),
          SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(
              height: 150,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(value: 35, color: Colors.green, title: "35%"),
                    PieChartSectionData(value: 25, color: Colors.blue, title: "25%"),
                    PieChartSectionData(value: 40, color: Colors.red, title: "40%"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Card(
              child: ListTile(
                title: const Text("Upcoming Tasks"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("✔ Redo Figma"),
                    Text("✔ Update Doc"),
                    Text("✔ Fix Bugs"),
                  ],
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Projects"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("• Web Design"),
                    Text("• App Development"),
                    Text("• Marketing Ad"),
                  ],
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text("Team Members"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("• Anna"),
                    Text("• Tom"),
                    Text("• James"),
                    Text("• Jane"),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  child: const Text("Task List"),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TaskListScreen()),
                  ),
                ),
                ElevatedButton(
                  child: const Text("Projects"),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProjectsScreen()),
                  ),
                ),
                ElevatedButton(
                  child: const Text("Create Task"),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}