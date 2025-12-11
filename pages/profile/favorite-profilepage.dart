import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyFavoritesProfilepage extends StatefulWidget {
  const MyFavoritesProfilepage({super.key});

  @override
  State<MyFavoritesProfilepage> createState() => _MyFavoritesProfilepageState();
}

class _MyFavoritesProfilepageState extends State<MyFavoritesProfilepage> {
  final supabase = Supabase.instance.client;
  List<dynamic> favoritePosts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      final data = await supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      setState(() {
        favoritePosts = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Load favorites failed: $e");
    }
  }

  Future<void> _removeFromFavorites(int id) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    debugPrint("Deleting favorite -> id: $id, user_id: $userId");

    try {
      final response = await supabase
          .from('favorites')
          .delete()
          .eq('id', id)
          .eq('user_id', userId);

      if (response.error != null) {
        debugPrint('Supabase error: ${response.error!.message}');
      } else {
        debugPrint('Delete success: ${response.data}');

        setState(() {
          favoritePosts.removeWhere((post) => post['id'] == id);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Removed from favorites")));
      }
    } catch (e) {
      debugPrint("Failed to remove favorite: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorites 💕")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : favoritePosts.isEmpty
          ? const Center(child: Text("No favorite posts yet 😔"))
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: favoritePosts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final post = favoritePosts[index];
                final imageUrl = post['image_url'];
                final id =
                    post['id']; // This must match your Supabase column name

                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, _, __) =>
                            const Icon(Icons.broken_image_rounded),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          tooltip: "Remove from favorites",
                          onPressed: () => _removeFromFavorites(id),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
