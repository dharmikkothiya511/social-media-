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
  List<String> imageUrls = [];

  /// here we create function for upload image
  Future<void> _uploadImage() async {
    try {
      final imagePicker = ImagePicker();
      final pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        final Uint8List fileBytes = await pickedFile.readAsBytes();
        final String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";
        await supabase.storage.from("image").uploadBinary(fileName, fileBytes);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Successfully Uplaod Image",
              style: TextStyle(fontSize: 21, color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );

        /// here we fetch all image adding and just show
        _fetchAllImage();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed Uploading Image : $error",
            style: const TextStyle(fontSize: 21, color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    /// fetch initial image
    _fetchAllImage();
  }

  /// here we create function to fetch all image
  Future<void> _fetchAllImage() async {
    try {
      final files = await supabase.storage.from("image").list();
      final urls = files.map((file) {
        return supabase.storage.from("image").getPublicUrl(file.name);
      }).toList();
      if (mounted) {
        setState(() {
          imageUrls = urls;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Can't Fecth error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Supabse : Image Uplaod "), centerTitle: true),

      /// add button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: FloatingActionButton.extended(
          /// here we call upload image functions
          onPressed: () {
            /// here we call
            _uploadImage();
          },
          label: const Text(
            "Select image",
            style: TextStyle(fontSize: 21, color: Colors.white),
          ),
          icon: Icon(
            Icons.add_photo_alternate_rounded,
            size: 23,
            color: Colors.white,
          ),
          backgroundColor: Colors.blue,
        ),
      ),

      /// here we show data
      body: imageUrls.isEmpty
          ? Center(
              child: Text(
                "No Image is uploaded",
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            )
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: imageUrls.length,
              itemBuilder: (BuildContext context, int index) {
                return Image.network(
                  imageUrls[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }
}

/// first connect supa base to flutter link in the description box

/// In this video we upload and fetch image from supabase
/// ------- Supbase Stroage ------------ ///
/// Upload image on Supabase
/// fetch image
///
/// Simple steps
/// add dependency
/// create simple ui
/// implement
/// create basket in supabase project inside the storage

// Complete final check
/// in next video delete operation perform
