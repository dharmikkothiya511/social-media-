import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyPersonalDataProfile extends StatefulWidget {
  const MyPersonalDataProfile({super.key});

  @override
  State<MyPersonalDataProfile> createState() => _MyPersonalDataProfileState();
}

class _MyPersonalDataProfileState extends State<MyPersonalDataProfile> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? profile;
  Uint8List? _image;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  /// Fetch user profile from Supabase
  Future<void> fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("User not logged in")));
      return;
    }

    final response = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response != null) {
      setState(() {
        profile = response;
      });
    } else {
      // Get name from metadata
      String fullName = user.userMetadata?['full_name'] ?? '';

      // If metadata doesn't have name, ask the user
      if (fullName.isEmpty) {
        fullName = await _askForName() ?? '';
      }

      // Create new profile
      await supabase.from('profiles').insert({
        'id': user.id,
        'email': user.email,
        'full_name': fullName,
        'phone': '',
        'dob': '',
        'gender': '',
        'address': '',
        'avatar_url': '',
      });

      fetchProfile();
    }
  }

  /// Prompt user to enter their name
  Future<String?> _askForName() async {
    String name = '';
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Enter Your Name"),
          content: TextField(
            onChanged: (val) => name = val,
            decoration: const InputDecoration(hintText: "Full Name"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, name),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  /// Upload image and update profile avatar
  Future<void> pickAndUploadImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final Uint8List fileBytes = await pickedFile.readAsBytes();
        final String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

        // Upload to Supabase Storage (bucket: "image")
        await supabase.storage.from("image").uploadBinary(fileName, fileBytes);

        // Get public URL
        final imageUrl = supabase.storage.from("image").getPublicUrl(fileName);

        // Update state
        setState(() {
          _image = fileBytes;
          profile!['avatar_url'] = imageUrl;
        });

        // Update profile table
        final user = supabase.auth.currentUser;
        if (user != null) {
          await supabase
              .from('profiles')
              .update({'avatar_url': imageUrl})
              .eq('id', user.id);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Image upload failed: $e")));
    }
  }

  /// Save profile updates
  Future<void> updateProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null || profile == null) return;

    await supabase
        .from('profiles')
        .update({
          'full_name': profile!['full_name'],
          'phone': profile!['phone'],
          'dob': profile!['dob'],
          'gender': profile!['gender'],
          'address': profile!['address'],
        })
        .eq('id', user.id);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile Updated")));
  }

  /// Delete account
  Future<void> deleteAccount() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    await supabase.from('profiles').delete().eq('id', user.id);
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, 'login');
  }

  /// Logout
  Future<void> logout() async {
    await supabase.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, 'login');
  }

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Personal Information"),
        leading: const BackButton(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 64,
                    backgroundImage: _image != null
                        ? MemoryImage(_image!)
                        : (profile!['avatar_url'] != null &&
                              profile!['avatar_url'].isNotEmpty)
                        ? NetworkImage(profile!['avatar_url'])
                        : const NetworkImage(
                                'https://t3.ftcdn.net/jpg/09/64/89/18/360_F_964891898_SuTIP6H2AVZkBuUG2cIpP9nvdixORKpM.jpg',
                              )
                              as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: IconButton(
                      onPressed: pickAndUploadImage,
                      icon: const Icon(
                        Icons.add_a_photo,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// Name & Email
              Text(
                profile!['full_name'] ?? '',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                profile!['email'] ?? '',
                style: const TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 20),
              const Divider(),

              /// Editable fields
              _InfoEditor(
                title: "Full Name",
                value: profile!['full_name'] ?? '',
                onChanged: (val) => profile!['full_name'] = val,
              ),
              _InfoEditor(
                title: "Phone",
                value: profile!['phone'] ?? '',
                onChanged: (val) => profile!['phone'] = val,
              ),
              _InfoEditor(
                title: "DOB",
                value: profile!['dob'] ?? '',
                onChanged: (val) => profile!['dob'] = val,
              ),
              _InfoEditor(
                title: "Gender",
                value: profile!['gender'] ?? '',
                onChanged: (val) => profile!['gender'] = val,
              ),
              _InfoEditor(
                title: "Address",
                value: profile!['address'] ?? '',
                onChanged: (val) => profile!['address'] = val,
              ),

              const Divider(),
              const SizedBox(height: 10),

              /// Save & Change Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: updateProfile,
                    child: const Text("Save Info"),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, 'changepass');
                    },
                    child: const Text("Change Pw"),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              /// Delete & Logout
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                ),
                onPressed: deleteAccount,
                child: const Text("Delete Account"),
              ),
              // TextButton(onPressed: logout, child: const Text("Logout")),
            ],
          ),
        ),
      ),
    );
  }
}

/// Editable field widget
class _InfoEditor extends StatelessWidget {
  final String title;
  final String value;
  final ValueChanged<String> onChanged;

  const _InfoEditor({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(title),
      subtitle: TextFormField(
        initialValue: value,
        onChanged: onChanged,
        decoration: InputDecoration(hintText: "Enter $title"),
      ),
    );
  }
}
