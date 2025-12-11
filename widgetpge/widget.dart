// import 'package:video_player/video_player.dart';
import 'dart:typed_data' show Uint8List;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  const BottomNavigationBarWidget({super.key});

  @override
  State<BottomNavigationBarWidget> createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  int _selectedIndex = 0;

  final List<IconData> icons = [
    Icons.home,
    Icons.search,
    Icons.add,
    Icons.perm_media_outlined,
    Icons.person_outline,
  ];

  final List<String> routes = [
    'home',
    'search',
    'addpage',
    'social',
    'account',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate only if not already on the route
    if (ModalRoute.of(context)?.settings.name != routes[index]) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,

      backgroundColor: Colors.white,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      items: List.generate(
        icons.length,
        (index) => BottomNavigationBarItem(
          icon: icons[index] == Icons.add
              ? _addButton(index == _selectedIndex)
              : Icon(icons[index]),
          label: "",
        ),
      ),
    );
  }

  Widget _addButton(bool isSelected) {
    return CircleAvatar(
      backgroundColor: isSelected ? Colors.black : Colors.grey,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }
}

//profile image uploed/fech

class ImageUploadWidget extends StatefulWidget {
  final String bucketName;
  final double gridSpacing;
  final int crossAxisCount;

  const ImageUploadWidget({
    super.key,
    required this.bucketName,
    this.gridSpacing = 4,
    this.crossAxisCount = 3,
  });

  @override
  State<ImageUploadWidget> createState() => _ImageUploadWidgetState();
}

class _ImageUploadWidgetState extends State<ImageUploadWidget> {
  final supabase = Supabase.instance.client;
  List<String> imageUrls = [];

  @override
  void initState() {
    super.initState();
    _fetchAllImage();
  }

  /// Upload image to Supabase bucket
  Future<void> _uploadImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final Uint8List fileBytes = await pickedFile.readAsBytes();
        final String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

        await supabase.storage
            .from(widget.bucketName)
            .uploadBinary(fileName, fileBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Image uploaded successfully",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        _fetchAllImage();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to upload image: $error",
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Fetch all images from Supabase bucket
  Future<void> _fetchAllImage() async {
    try {
      final files = await supabase.storage.from(widget.bucketName).list();
      final urls = files
          .map(
            (file) => supabase.storage
                .from(widget.bucketName)
                .getPublicUrl(file.name),
          )
          .toList();

      if (mounted) {
        setState(() {
          imageUrls = urls;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Can't fetch images")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Upload button
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: ElevatedButton.icon(
            onPressed: _uploadImage,
            icon: const Icon(Icons.add_photo_alternate_rounded, size: 23),
            label: const Text("Select Image", style: TextStyle(fontSize: 18)),
          ),
        ),

        const SizedBox(height: 10),

        /// Show images
        Expanded(
          child: imageUrls.isEmpty
              ? const Center(
                  child: Text(
                    "No Image uploaded yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.crossAxisCount,
                    mainAxisSpacing: widget.gridSpacing,
                    crossAxisSpacing: widget.gridSpacing,
                  ),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}

///
/// ✅ Reusable Profile Widget
///
class ProfileHeaderWidget extends StatefulWidget {
  const ProfileHeaderWidget({super.key});

  @override
  State<ProfileHeaderWidget> createState() => _ProfileHeaderWidgetState();
}

class _ProfileHeaderWidgetState extends State<ProfileHeaderWidget> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? profile;
  Uint8List? _image;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    setState(() {
      profile = data;
    });
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final Uint8List fileBytes = await pickedFile.readAsBytes();
      final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

      await supabase.storage.from("image").uploadBinary(fileName, fileBytes);
      final imageUrl = supabase.storage.from("image").getPublicUrl(fileName);

      final user = supabase.auth.currentUser;
      if (user != null) {
        await supabase
            .from('profiles')
            .update({'avatar_url': imageUrl})
            .eq('id', user.id);
      }

      setState(() {
        _image = fileBytes;
        profile?['avatar_url'] = imageUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (profile == null) {
      return const ListTile(
        title: Text("Loading..."),
        leading: CircleAvatar(child: Icon(Icons.person)),
      );
    }

    return ListTile(
      leading: GestureDetector(
        onTap: _pickAndUploadImage,
        child: CircleAvatar(
          radius: 25,
          backgroundImage: _image != null
              ? MemoryImage(_image!)
              : (profile?['avatar_url'] != null &&
                    profile!['avatar_url'].isNotEmpty)
              ? NetworkImage(profile!['avatar_url'])
              : const NetworkImage(
                      'https://t3.ftcdn.net/jpg/09/64/89/18/360_F_964891898_SuTIP6H2AVZkBuUG2cIpP9nvdixORKpM.jpg',
                    )
                    as ImageProvider,
        ),
      ),
      title: Text(
        profile?['full_name'] ?? 'No Name',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(profile?['email'] ?? ''),
    );
  }
}
