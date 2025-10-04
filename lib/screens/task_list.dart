import 'package:flutter/material.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task List")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: const [
            ListTile(title: Text("✔ Redo Figma")),
            ListTile(title: Text("✔ Update Doc")),
            ListTile(title: Text("✔ Fix bugs")),
            ListTile(title: Text("✔ App Backend")),
            ListTile(title: Text("✔ Redesign Ad")),
            ListTile(title: Text("✔ Prepare presentation")),
          ],
        ),
      ),
    );
  }
}
