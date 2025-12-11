import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app/widgetpge/widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUpload extends StatefulWidget {
  const ImageUpload({super.key});

  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> posts = [];

  /// Upload image to Supabase Storage + Insert in posts table
  Future<void> _uploadImage() async {
    try {
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        final Uint8List fileBytes = await pickedFile.readAsBytes();
        final String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        final userId = supabase.auth.currentUser?.id;

        if (userId == null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("❌ Please login first")));
          return;
        }

        // Upload to storage
        await supabase.storage.from("image").uploadBinary(fileName, fileBytes);

        // Get public URL
        final publicUrl = supabase.storage.from("image").getPublicUrl(fileName);

        // Insert in posts table
        await supabase.from("posts").insert({
          'user_id': userId,
          'image_url': publicUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Image uploaded & post created"),
            backgroundColor: Colors.green,
          ),
        );

        // _fetchPosts();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to upload: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Fetch posts from table
  Future<void> _fetchPosts() async {
    try {
      final data = await supabase 
          .from("posts")
          .select("id, image_url")
          .order("created_at", ascending: false);
      setState(() {
        posts = List<Map<String, dynamic>>.from(data);
      });
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("❌ Failed to fetch posts")));
    }
  }

  /// Delete post
  Future<void> _deletePost(Map<String, dynamic> post) async {
    try {
      // Get file name from URL
      final imageUrl = post['image_url'] as String;
      final fileName = imageUrl
          .split("/")
          .last
          .split("?")
          .first; // remove query params if any

      // Delete from storage
      await supabase.storage.from("image").remove([fileName]);

      // Delete from table
      await supabase.from("posts").delete().match({'id': post['id']});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("🗑 Post deleted"),
          backgroundColor: Colors.red,
        ),
      );

      _fetchPosts();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed to delete: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Show dialog to choose a post for deletion
  void _showDeleteDialog() {
    if (posts.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No posts to delete")));
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select a post to delete"),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (_, i) {
              final post = posts[i];
              return ListTile(
                leading: Image.network(
                  post['image_url'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text("Post ID: ${post['id']}"),
                onTap: () {
                  Navigator.pop(context);
                  _deletePost(post);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📸 Social Feed"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _showDeleteDialog,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: FloatingActionButton.extended(
          onPressed: _uploadImage,
          label: const Text(
            "Upload Image",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          icon: const Icon(
            Icons.add_photo_alternate_rounded,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue,
        ),
      ),
      body: posts.isEmpty
          ? const Center(
              child: Text("No posts yet 👀", style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Image.network(post['image_url']),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Post ID: ${post['id']}"),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }
}
