import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:social_app/widgetpge/widget.dart';

class Myaccount extends StatefulWidget {
  const Myaccount({super.key});

  @override
  State<Myaccount> createState() => _MyaccountState();
}

class _MyaccountState extends State<Myaccount> {
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

  // Future<void> _pickAndUploadImage() async {
  //   final pickedFile = await ImagePicker().pickImage(
  //     source: ImageSource.gallery,
  //   );

  //   if (pickedFile != null) {
  //     final Uint8List fileBytes = await pickedFile.readAsBytes();
  //     final fileName = "${DateTime.now().millisecondsSinceEpoch}.jpg";

  //     await supabase.storage.from("image").uploadBinary(fileName, fileBytes);
  //     final imageUrl = supabase.storage.from("image").getPublicUrl(fileName);

  //     final user = supabase.auth.currentUser;
  //     if (user != null) {
  //       await supabase
  //           .from('profiles')
  //           .update({'avatar_url': imageUrl})
  //           .eq('id', user.id);
  //     }

  //     setState(() {
  //       _image = fileBytes;
  //       profile?['avatar_url'] = imageUrl;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: const Color(0xffffffff),
      body: ListView(
        padding: const EdgeInsets.all(12),
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 5),
          // ✅ Inline profile image + name
          ListTile(
            leading: GestureDetector(
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
              profile?['full_name'] ?? 'Loading...',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(profile?['email'] ?? ''),
          ),
          const SizedBox(height: 12),
          divider(),
          colorTiles(),
          divider(),
          bwTiles(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget divider() {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Divider(thickness: 1.5),
    );
  }

  Widget colorTiles() {
    return Column(
      children: [
        colorTile(Icons.person_outline, Colors.deepPurple, "Personal data"),
        colorTile(Icons.settings_outlined, Colors.blue, "Settings"),
        colorTile(Icons.credit_card, Colors.pink, "Payment"),
        colorTile(Icons.favorite_border, Colors.orange, "Favorites"),
      ],
    );
  }

  Widget bwTiles() {
    return Column(
      children: [
        bwTile(Icons.info_outline, "FAQs"),
        bwTile(Icons.border_color_outlined, "Handbook"),
        bwTile(Icons.textsms_outlined, "Community"),
        bwTile(Icons.logout, "Logout"),
      ],
    );
  }

  Widget bwTile(IconData icon, String text) {
    return colorTile(icon, Colors.black, text, blackAndWhite: true);
  }

  Widget colorTile(
    IconData icon,
    Color color,
    String text, {
    bool blackAndWhite = false,
  }) {
    final Color pickedColor = const Color(0xfff3f4fe);

    final Map<String, String> routeMap = <String, String>{
      "Personal data": "presonal",
      "Settings": 'setting',
      "Payment": "payment",
      "Favorites": "favorites",
      "FAQs": "FAQs",
      "Handbook": "hanbook",
      "Community": "community",
      "Logout": "logout",
    };

    return InkWell(
      onTap: () {
        final route = routeMap[text];
        if (route != null) {
          Navigator.pushNamed(context, route);
        }
      },
      child: ListTile(
        leading: Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: blackAndWhite ? pickedColor : color.withOpacity(0.09),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.black,
          size: 20,
        ),
      ),
    );
  }
}
