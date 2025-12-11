import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogoutProfilePage extends StatelessWidget {
  const LogoutProfilePage({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final supabase = Supabase.instance.client;

    try {
      await supabase.auth.signOut();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Logged out successfully")));

      // Navigate to signup page and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(context, 'sing', (route) => false);
    } catch (e) {
      debugPrint("Logout failed: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Logout failed")));
    }
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              _handleLogout(context); // Perform logout
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Logout"), leading: const BackButton()),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout, size: 80, color: Colors.redAccent),
              const SizedBox(height: 24),
              const Text(
                "Logging out will end your current session.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              // ElevatedButton(onPressed: () {}, child: Text("cancle")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                onPressed: () => _showLogoutConfirmationDialog(context),
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
