import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'setting_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  bool isLoading = true;

  bool showNotifications = true;
  bool showBadges = true;
  bool floatingNotifications = true;
  bool lockScreenNotifications = true;
  bool allowSound = true;
  bool allowVibration = true;
  bool allowLED = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  // Load existing settings from Firestore
  Future<void> _loadNotificationSettings() async {
    try {
      if (user == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('settings')
          .doc('notifications')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          showNotifications = data['showNotifications'] ?? true;
          showBadges = data['showBadges'] ?? true;
          floatingNotifications = data['floatingNotifications'] ?? true;
          lockScreenNotifications = data['lockScreenNotifications'] ?? true;
          allowSound = data['allowSound'] ?? true;
          allowVibration = data['allowVibration'] ?? true;
          allowLED = data['allowLED'] ?? true;
        });
      }
    } catch (e) {
      debugPrint("Error loading notification settings: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Save settings to Firestore
  Future<void> _saveNotificationSettings() async {
    try {
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('settings')
          .doc('notifications')
          .set({
        'showNotifications': showNotifications,
        'showBadges': showBadges,
        'floatingNotifications': floatingNotifications,
        'lockScreenNotifications': lockScreenNotifications,
        'allowSound': allowSound,
        'allowVibration': allowVibration,
        'allowLED': allowLED,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error saving notification settings: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3), 
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
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
                          "Notifications",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Card container
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView(
                          children: [
                            const Text(
                              "Configure your notification settings below:",
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.justify,
                            ),
                            const SizedBox(height: 12),
                            const Divider(),

                            // Switch options
                            _buildSwitch(
                              "Show notifications",
                              showNotifications,
                              (val) {
                                setState(() => showNotifications = val);
                                _saveNotificationSettings();
                              },
                            ),
                            _buildSwitch("Show app icon badges", showBadges, (
                              val,
                            ) {
                              setState(() => showBadges = val);
                              _saveNotificationSettings();
                            }),
                            _buildSwitch(
                              "Floating notifications",
                              floatingNotifications,
                              (val) {
                                setState(() => floatingNotifications = val);
                                _saveNotificationSettings();
                              },
                            ),
                            _buildSwitch(
                              "Lock screen notifications",
                              lockScreenNotifications,
                              (val) {
                                setState(() => lockScreenNotifications = val);
                                _saveNotificationSettings();
                              },
                            ),
                            _buildSwitch("Allow sound", allowSound, (val) {
                              setState(() => allowSound = val);
                              _saveNotificationSettings();
                            }),
                            _buildSwitch("Allow vibration", allowVibration, (
                              val,
                            ) {
                              setState(() => allowVibration = val);
                              _saveNotificationSettings();
                            }),
                            _buildSwitch("Allow using LED light", allowLED, (
                              val,
                            ) {
                              setState(() => allowLED = val);
                              _saveNotificationSettings();
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSwitch(String title, bool value, Function(bool) onChanged) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(title),
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blue,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
