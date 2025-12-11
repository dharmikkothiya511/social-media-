import 'package:flutter/material.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool _isPrivate = false;
  bool _allowFriendRequests = true;
  bool _showOnlineStatus = true;
  bool _shareActivityStatus = false;
  bool _isSaving = false;

  void _saveSettings() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Save'),
        content: const Text('Do you want to save these privacy settings?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isSaving = true);

    // Simulate save delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isSaving = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Privacy settings updated')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Private Account"),
            subtitle: const Text(
              "Only approved followers can see your content",
            ),
            value: _isPrivate,
            onChanged: (val) => setState(() => _isPrivate = val),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Allow Friend Requests"),
            subtitle: const Text("Let others send you friend requests"),
            value: _allowFriendRequests,
            onChanged: (val) => setState(() => _allowFriendRequests = val),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Show Online Status"),
            subtitle: const Text("Others can see when you're online"),
            value: _showOnlineStatus,
            onChanged: (val) => setState(() => _showOnlineStatus = val),
          ),
          const Divider(),
          SwitchListTile(
            title: const Text("Share Activity Status"),
            subtitle: const Text(
              "Allow apps to show your activity (e.g. last seen)",
            ),
            value: _shareActivityStatus,
            onChanged: (val) => setState(() => _shareActivityStatus = val),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveSettings,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.lock),
              label: const Text("Save Settings"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
