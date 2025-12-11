import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:social_app/widgetpge/widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> users = [];
  bool isLoading = false;

  // 📌 Static explore images
  final List<String> arrContent = [
    "https://letsenhance.io/static/8f5e523ee6b2479e26ecc91b9c25261e/1015f/MainAfter.jpg",
    "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_1280.jpg",
    "https://cdn.pixabay.com/photo/2024/05/26/10/15/bird-8788491_640.jpg",
    "https://pixlr.com/images/generator/how-to-generate.webp",
    "https://cdn.pixabay.com/photo/2016/11/29/01/14/forest-1868418_1280.jpg",
    "https://cdn.pixabay.com/photo/2021/08/25/06/24/cat-6573546_640.jpg",
    "https://cdn.pixabay.com/photo/2024/02/12/09/16/mountain-8567031_640.jpg",
    "https://cdn.pixabay.com/photo/2020/06/12/16/14/flower-5296231_640.jpg",
  ];

  // 🔍 Search users by full_name
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      setState(() => users = []);
      return;
    }

    setState(() => isLoading = true);

    final response = await supabase
        .from('profiles')
        .select('id, username, full_name, avatar_url')
        .ilike('full_name', '%$query%'); // search by full_name

    setState(() {
      users = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Instagram dark theme
      body: SafeArea(
        child: Column(
          children: [
            // 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: searchUsers,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[900],
                  hintText: "Search",
                  hintStyle: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.white,
                    size: 22,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 15,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),

            // 📌 Categories (like Instagram chips)
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildCategory("IGTV", icon: Icons.tv),
                  _buildCategory("Shop", icon: Icons.shopping_bag),
                  _buildCategory("Style"),
                  _buildCategory("Sports"),
                  _buildCategory("Auto"),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 📌 Show users if searching, else show grid
            Expanded(
              child: searchController.text.isNotEmpty
                  ? (isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : users.isEmpty
                        ? const Center(
                            child: Text(
                              "No users found",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : ListView.builder(
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: user['avatar_url'] != null
                                      ? NetworkImage(user['avatar_url'])
                                      : null,
                                  child: user['avatar_url'] == null
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                title: Text(
                                  user['full_name'] ?? 'No Name',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  user['username'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                onTap: () {
                                  // 👉 Navigate to profile screen with user['id']
                                },
                              );
                            },
                          ))
                  : MasonryGridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                      padding: const EdgeInsets.all(4),
                      itemCount: arrContent.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            arrContent[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.grey[800]),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }

  // 📌 Category chip widget
  Widget _buildCategory(String text, {IconData? icon}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(20),
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 5),
          ],
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}
