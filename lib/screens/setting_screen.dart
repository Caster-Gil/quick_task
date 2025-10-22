import 'package:flutter/material.dart';
import 'package:quick_task/screens/account_screen.dart';
import 'package:quick_task/screens/notifications_screen.dart';
import 'package:quick_task/screens/help_screen.dart';
import 'package:quick_task/screens/about_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar with back button + title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Settings",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            // Card container
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    // Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search for a setting",
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Settings items with dividers
                    buildSettingsItem(
                      context,
                      Icons.person,
                      "Account",
                      const AccountScreen(),
                    ),
                    buildDivider(),
                    buildSettingsItem(
                      context,
                      Icons.notifications,
                      "Notifications",
                      const NotificationsScreen(),
                    ),
                    buildDivider(),
                    buildSettingsItem(
                      context,
                      Icons.headset_mic,
                      "Help & Support",
                      const HelpScreen(),
                    ),
                    buildDivider(),
                    buildSettingsItem(
                      context,
                      Icons.info_outline,
                      "About",
                      const AboutScreen(),
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

  // Build individual settings item
  Widget buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: Colors.black),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }

  // Build divider line
  Widget buildDivider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.black26,
      indent: 16,
      endIndent: 16,
    );
  }
}
