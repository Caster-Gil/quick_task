import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tasklist_screen.dart';
import 'create_project_screen.dart';

class ProjectsScreen extends StatelessWidget {
  final String? selectedProjectId;

  ProjectsScreen({Key? key, this.selectedProjectId}) : super(key: key);

  Future<void> _joinProject(BuildContext context) async {
    final TextEditingController codeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Join Project'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(hintText: 'Enter project code'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final code = codeController.text.trim();
              if (code.isEmpty) return;

              final query = await FirebaseFirestore.instance
                  .collection('projects')
                  .where('code', isEqualTo: code)
                  .get();

              if (query.docs.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid project code!')),
                );
                return;
              }

              final projectDoc = query.docs.first;
              final userId = FirebaseAuth.instance.currentUser!.uid;

              final members = List<String>.from(projectDoc['members'] ?? []);
              if (!members.contains(userId)) {
                members.add(userId);
                await FirebaseFirestore.instance
                    .collection('projects')
                    .doc(projectDoc.id)
                    .update({'members': members});
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Joined project successfully!')),
              );
            },
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }

  Future<String> _getCreatorUsername(String creatorId) async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(creatorId)
        .get();
    if (doc.exists && doc.data()?['username'] != null) {
      return doc['username'];
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Projects"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF76A7D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateProjectScreen(),
                  ),
                );
              },
              child: const Text(
                "New Project",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('projects').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No projects available."));
                }

                // Filter: show only projects where user is creator or member
                final projects = snapshot.data!.docs.where((project) {
                  final data = project.data() as Map<String, dynamic>? ?? {};
                  final creatorId = data['creator_id'] ?? '';
                  final members = List<String>.from(data['members'] ?? []);
                  return creatorId == currentUserId ||
                      members.contains(currentUserId);
                }).toList();

                if (projects.isEmpty) {
                  return const Center(
                    child: Text("No projects available for you."),
                  );
                }

                return ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    final projectData =
                        project.data() as Map<String, dynamic>? ?? {};
                    final isSelected = project.id == selectedProjectId;
                    final creatorId = projectData['creator_id'] ?? '';

                    return FutureBuilder<String>(
                      future: _getCreatorUsername(creatorId),
                      builder: (context, snapshot) {
                        final creatorName = snapshot.data ?? 'Loading...';

                        return Card(
                          key: ValueKey(project.id),
                          color: isSelected
                              ? Colors.blue.shade50
                              : Colors.white,
                          child: ListTile(
                            title: Text(
                              projectData['name'] ?? 'Untitled Project',
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Created by: $creatorName"),
                                if (creatorId == currentUserId &&
                                    projectData['code'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      "Project Code: ${projectData['code']}",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TaskListScreen(
                                    projectId: project.id,
                                    projectName:
                                        projectData['name'] ?? 'Project',
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
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _joinProject(context),
                child: const Text('Join Project'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
