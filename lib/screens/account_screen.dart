import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart'; // Make sure this imports your login screen
import 'setting_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isEditing = false;
  TextEditingController usernameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  String username = "";
  String bio = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user!.uid).get();

      if (doc.exists) {
        setState(() {
          username = doc['username'] ?? '';
          bio = doc['bio'] ?? '';
          email = user!.email ?? '';
          usernameController.text = username;
          bioController.text = bio;
          emailController.text = email;
        });
      } else {
        setState(() {
          email = user!.email ?? '';
        });
      }
    }
  }

  Future<void> saveProfile() async {
    if (user != null) {
      await _firestore.collection('users').doc(user!.uid).set({
        'username': usernameController.text.trim(),
        'bio': bioController.text.trim(),
        'email': user!.email,
      }, SetOptions(merge: true));

      setState(() {
        username = usernameController.text.trim();
        bio = bioController.text.trim();
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
    }
  }

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Top bar
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Profile",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Profile content
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 30,
                              backgroundColor: Color.fromARGB(255, 255, 255, 255),
                              child: Icon(
                                Icons.person,
                                size: 36,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username.isNotEmpty
                                      ? username
                                      : "No username",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email.isNotEmpty ? email : "No email",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "Bio",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        isEditing
                            ? TextField(
                                controller: bioController,
                                maxLines: 3,
                                maxLength: 250,
                                decoration: const InputDecoration(
                                  hintText:
                                      "Who you are in less than 250 characters",
                                  border: UnderlineInputBorder(),
                                  counterText: '',
                                ),
                              )
                            : Text(
                                bio.isNotEmpty ? bio : "No bio added yet",
                                style: const TextStyle(color: Colors.black87),
                              ),
                        const SizedBox(height: 16),

                        const Text(
                          "Username",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        isEditing
                            ? TextField(
                                controller: usernameController,
                                decoration: const InputDecoration(
                                  hintText: "Enter your username",
                                  border: UnderlineInputBorder(),
                                ),
                              )
                            : Text(
                                username.isNotEmpty
                                    ? username
                                    : "No username set",
                                style: const TextStyle(color: Colors.black87),
                              ),
                        const SizedBox(height: 16),

                        const Text(
                          "E-Mail",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: emailController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Edit / Save button
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8BAEDC),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              if (isEditing) {
                                saveProfile();
                              } else {
                                setState(() {
                                  isEditing = true;
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 10,
                              ),
                              child: Text(
                                isEditing ? "Save Changes" : "Edit Profile",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
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

              // Red Log Out button at the bottom
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: logOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      "Log Out",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
    );
  }
}
