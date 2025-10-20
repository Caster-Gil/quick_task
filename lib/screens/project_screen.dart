import 'package:flutter/material.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Projects")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: const [
            ListTile(title: Text("• Web Design")),
            ListTile(title: Text("• App Development")),
            ListTile(title: Text("• Marketing Ad")),
            ListTile(title: Text("• Group Assignment")),
            ListTile(title: Text("• Redesign Ad")),
            ListTile(title: Text("• Case Study on HR")),
          ],
        ),
      ),
    );
  }
}