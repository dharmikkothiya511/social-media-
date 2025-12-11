import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:social_app/widgetpge/widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FilesUploadScreen extends StatefulWidget {
  const FilesUploadScreen({super.key});

  @override
  State<FilesUploadScreen> createState() => _FilesUploadScreenState();
}

class _FilesUploadScreenState extends State<FilesUploadScreen> {
  final supabaseStorage = Supabase.instance.client;
  List<FileObject> allFiles = [];
  bool isLoading = false;
  bool isUploading = false;

  /// here we create function to upload files
  Future<void> _uploadFiles() async {
    /// here we pick file first
    FilePickerResult? filePickerResult = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );
    if (filePickerResult == null) return;
    File file = File(filePickerResult.files.single.path!);
    String name = filePickerResult.files.single.name;
    String fileName = "${DateTime.now().millisecondsSinceEpoch}_$name";
    setState(() {
      isUploading = true;
    });

    try {
      await supabaseStorage.storage.from("files").upload(fileName, file);
      mySnackBar(
        message: 'File Upload Successfully',
        backgroundColor: Colors.green,
      );

      /// here we call to auto update
      setState(() {
        _fetchAllFiles();
      });
    } catch (e) {
      mySnackBar(message: 'Uploading failed', backgroundColor: Colors.red);
    }
    setState(() {
      isUploading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchAllFiles();
  }

  /// here we create function to fetch all files
  Future<void> _fetchAllFiles() async {
    setState(() {
      isLoading = true;
    });
    try {
      final List<FileObject> responseFile = await supabaseStorage.storage
          .from("files")
          .list();
      setState(() {
        setState(() {
          allFiles = responseFile;
        });
      });
      mySnackBar(
        message: "Successfully Fetch all files",
        backgroundColor: Colors.green,
      );
    } catch (e) {
      mySnackBar(
        message: "Failed to fetching files $e",
        backgroundColor: Colors.red,
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  /// here we create function to download the files
  Future<void> downloadAndOpen(String filePath) async {
    setState(() {
      isLoading = true;
    });
    try {
      final tempDir = await getTemporaryDirectory();
      final localPath = "${tempDir.path}/${filePath.split('/').last}";
      final localFile = File(localPath);
      final fileData = await supabaseStorage.storage
          .from("files")
          .download(filePath);
      await localFile.writeAsBytes(fileData);
      await OpenFilex.open(localPath);
    } catch (e) {
      mySnackBar(message: "Error Can,t OPen : $e", backgroundColor: Colors.red);
    }
    setState(() {
      isLoading = false;
    });
  }

  /// here we create function to delete file

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Files upload and fetch from supabase",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepOrangeAccent,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      /// file select button
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: isUploading
            ? const Center(child: CircularProgressIndicator())
            : FloatingActionButton.extended(
                /// here we call file select and upload file function
                onPressed: _uploadFiles,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                backgroundColor: Colors.deepOrangeAccent,
                icon: const Icon(Icons.upload, color: Colors.white, size: 31),
                label: const Text(
                  "Select File",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
      ),

      /// ----- BODY ---- ///
      backgroundColor: Colors.white,

      /// data show here in list view
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: allFiles.length,
              itemBuilder: (context, index) {
                final myFile = allFiles[index];
                return Card(
                  child: ListTile(
                    title: Text(myFile.name),
                    leading: const Icon(
                      Icons.insert_drive_file,
                      color: Colors.blue,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          /// here we call file open functions
                          onPressed: () => downloadAndOpen(myFile.name),
                          icon: const Icon(
                            Icons.download,
                            color: Colors.green,
                            size: 33,
                          ),
                        ),
                        IconButton(
                          /// here we call delete function
                          onPressed: () {},
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                            size: 33,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }

  /// here we create function to show snackbar message
  void mySnackBar({required String message, Color? backgroundColor}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 21,
            color: Colors.white,
          ),
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}

/// IN THIS VIDE WE UPLOAD
/// UPLOAD PDF , WORD FILE , XLXS FILE , PPT FILES , AUDIO , VIDEO ON SUPABASE
/// AND ALSO OPEN THESE ALL FILES
///
/// Simple Steps
/// Step 1 => DONE
/// connect flutter with supabase  , this project is already connect with supabase , you first connect
/// link in the description box
/// Step 2  => DONE
/// add dependency
/// Step 3 => DONE
/// create simple ui
/// Step 4 => DONE , busket name = files , same name use in uploading time
/// create busket in supabase storage
/// Step 5 => DONE
/// upload files
/// Step 6 => DONE
/// Fetch all Files
/// Step 7 => DONE
/// delete operation & open
/// Step 8 => DONE
/// final check
/// start
/// ------ THANKS ---------- ///
///
///
///
///
