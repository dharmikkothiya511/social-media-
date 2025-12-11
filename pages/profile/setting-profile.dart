import 'package:flutter/material.dart';

class MySettingProfilepage extends StatefulWidget {
  const MySettingProfilepage({super.key});

  @override
  State<MySettingProfilepage> createState() => _MySettingProfilepageState();
}

class _MySettingProfilepageState extends State<MySettingProfilepage> {
  bool isDarkMode = false;
  bool pushNotification = true;
  bool emailNotification = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        leading: const BackButton(),
        actions: const [Icon(Icons.settings), SizedBox(width: 10)],
      ),
      body: ListView(
        children: [
          _buildSectionTitle("Account"),
          _buildSettingItem("Profile Information", Icons.person, () {
            Navigator.pushNamed(context, "presonal");
          }),
          _buildSettingItem("Change Password", Icons.lock, () {
            Navigator.pushNamed(context, "changepass");
          }),
          _buildSettingItem("Privacy Settings", Icons.privacy_tip, () {
            Navigator.pushNamed(context, "privacy");
          }),

          const Divider(),
          _buildSectionTitle("Notifications"),
          SwitchListTile(
            title: const Text("Push Notifications"),
            value: pushNotification,
            onChanged: (value) => setState(() => pushNotification = value),
            secondary: const Icon(Icons.notifications),
          ),
          SwitchListTile(
            title: const Text("Email Notifications"),
            value: emailNotification,
            onChanged: (value) => setState(() => emailNotification = value),
            secondary: const Icon(Icons.email),
          ),

          const Divider(),
          _buildSectionTitle("App"),
          _buildSettingItem("Language", Icons.language, () {
            Navigator.pushNamed(context, 'language');
          }),
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: isDarkMode,
            onChanged: (value) => setState(() => isDarkMode = value),
            secondary: const Icon(Icons.dark_mode),
          ),
          _buildSettingItem("Help & Support", Icons.help_outline, () {}),

          const Divider(),
          _buildSectionTitle("Others"),
          _buildSettingItem("Terms of Service", Icons.description, () {}),
          _buildSettingItem("About App", Icons.info_outline, () {}),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout", style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pushNamed(context, 'logout');
            },
          ),

          const SizedBox(height: 20),
          Center(
            child: Text(
              "App version 1.0.0",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
