import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/issue_service.dart';
import 'my_reports_screen.dart';
import 'notification_screen.dart';
import 'loginscreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final IssueService _issueService = IssueService();
  bool _uploadingAvatar = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  Future<void> _pickAndUploadAvatar() async {
    final user = _currentUser;
    if (user == null) {
      _showSnack("Please log in to update your profile photo.");
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() => _uploadingAvatar = true);

    try {
      final downloadUrl = await _storageService.uploadAvatar(
        userId: user.uid,
        imageFile: picked,
      );

      if (downloadUrl != null) {
        await user.updatePhotoURL(downloadUrl);
        await user.reload();
        if (mounted) {
          setState(() {});
          _showSnack("Profile photo updated successfully!");
        }
      } else {
        _showSnack("Could not upload profile photo.");
      }
    } catch (e) {
      _showSnack("Error updating photo: $e");
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _showChangePasswordDialog() async {
    final user = _currentUser;
    final email = user?.email;

    if (email == null || email.isEmpty) {
      _showSnack("No registered email found for this session.");
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Reset Password"),
        content: Text("A password reset link will be sent to:\n$email"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            child: const Text("Send Link", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _authService.sendPasswordResetEmail(email);
        _showSnack("Password reset email sent to $email");
      } catch (e) {
        _showSnack("Could not send password reset email: $e");
      }
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.add_road, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text("About RoadCare"),
          ],
        ),
        content: const Text(
          "RoadCare is a community-driven smart infrastructure reporting platform. "
          "It connects citizens directly with municipal authorities to detect, report, and fix road hazards faster.\n\n"
          "Version: 1.0.0 (Production Ready)\n"
          "Powered by Flutter, OpenStreetMap & Firebase.",
          style: TextStyle(height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            child: const Text("Close", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showHelpSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Help & Support"),
        content: const Text(
          "Need help or want to report an emergency?\n\n"
          "• Email: support@roadcare.app\n"
          "• Helpline: 1800-ROAD-CARE (Toll Free)\n"
          "• Emergency Services: 112\n\n"
          "Our civic response team operates 24/7.",
          style: TextStyle(height: 1.4),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB)),
            child: const Text("Got it", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _authService.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool("onboardingDone", true);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    final userName = user?.displayName ?? (user?.email != null ? user!.email!.split('@').first : "Active Citizen");
    final userEmail = user?.email ?? "community@roadcare.app";
    final photoUrl = user?.photoURL;
    final stats = _issueService.calculateStatistics();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Blue curved header
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 36),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                        child: _uploadingAvatar
                            ? const CircularProgressIndicator(color: Colors.white)
                            : (photoUrl == null
                                ? const Icon(Icons.person, size: 50, color: Colors.white)
                                : null),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickAndUploadAvatar,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, size: 16, color: Color(0xFF2563EB)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userEmail,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  // Quick Stats Row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _profileStatItem("${stats['total']}", "Total Reports"),
                        Container(height: 24, width: 1, color: Colors.white24),
                        _profileStatItem("${stats['fixed']}", "Fixed Issues"),
                        Container(height: 24, width: 1, color: Colors.white24),
                        _profileStatItem("Level 2", "Civic Rank"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Menu items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.assignment_outlined,
                    label: "My Reports",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MyReportsScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    label: "Notifications",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.lock_outline,
                    label: "Change Password",
                    onTap: _showChangePasswordDialog,
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    label: "Help & Support",
                    onTap: _showHelpSupportDialog,
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    label: "About Us",
                    onTap: _showAboutDialog,
                  ),
                  _buildMenuItem(
                    icon: Icons.logout,
                    label: "Logout",
                    isDestructive: true,
                    onTap: _logout,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _profileStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDestructive ? const Color(0xFFFEE2E2) : const Color(0xFFDBEAFE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : const Color(0xFF2563EB),
            size: 20,
          ),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : const Color(0xFF0F172A),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}