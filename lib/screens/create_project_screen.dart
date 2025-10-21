import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'project_screen.dart';

class CreateProjectScreen extends StatelessWidget {
  const CreateProjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController createdByController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController dateController = TextEditingController();

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar with back arrow and title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProjectsScreen(),
                        ),
                      );
                    },
                  ),
                  const Text(
                    "New Project",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),

            // Form card
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Project Details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Title Field
                        TextField(
                          controller: titleController,
                          decoration: _inputDecoration("Title"),
                        ),
                        const SizedBox(height: 12),

                        // Created By Field
                        TextField(
                          controller: createdByController,
                          decoration: _inputDecoration("Created by"),
                        ),
                        const SizedBox(height: 12),

                        // Description Field
                        TextField(
                          controller: descriptionController,
                          decoration: _inputDecoration("Project Description"),
                        ),
                        const SizedBox(height: 12),

                        // Date Created Field
                        TextField(
                          controller: dateController,
                          decoration: _inputDecoration("Date Created"),
                        ),
                        const SizedBox(height: 20),

                        // Create Button
                        Center(
                          child: SizedBox(
                            width: 120,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () async {
                                final title = titleController.text.trim();
                                final createdBy =
                                    createdByController.text.trim();
                                final description =
                                    descriptionController.text.trim();
                                final date = dateController.text.trim();

                                if (title.isEmpty ||
                                    createdBy.isEmpty ||
                                    description.isEmpty ||
                                    date.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Please fill in all required fields."),
                                    ),
                                  );
                                  return;
                                }

                                try {
                                  // Auto-generate project ID
                                  final projectRef =
                                      firestore.collection('projects').doc();

                                  await projectRef.set({
                                    'id': projectRef.id,
                                    'name': title,
                                    'createdBy': createdBy,
                                    'description': description,
                                    'dateCreated': date,
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          "Project '${title}' created successfully!"),
                                    ),
                                  );

                                  // Navigate back to ProjectsScreen
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ProjectsScreen(),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text("Error creating project. Try again."),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF76A7D2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "Create",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
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
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Colors.black45),
      filled: true,
      fillColor: const Color(0xFFF1F1F1),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}