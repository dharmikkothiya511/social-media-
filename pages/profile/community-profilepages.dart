import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyCommunityProfilepages extends StatefulWidget {
  const MyCommunityProfilepages({super.key});

  @override
  State<MyCommunityProfilepages> createState() =>
      _MyCommunityProfilepagesState();
}

class _MyCommunityProfilepagesState extends State<MyCommunityProfilepages> {
  final supabase = Supabase.instance.client;
  List<dynamic> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    final response = await supabase
        .from('community_posts')
        .select()
        .order('created_at', ascending: false);

    setState(() {
      posts = response;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Community"),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search + New Post Button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Search in community...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    // Open new post screen
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("New Post"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Post List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : posts.isEmpty
                  ? const Center(child: Text("No posts yet 😕"))
                  : ListView.separated(
                      itemCount: posts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final post = posts[index];

                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Avatar
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: post['avatar_url'] != null
                                      ? NetworkImage(post['avatar_url'])
                                      : const AssetImage(
                                              'assets/default_avatar.png',
                                            )
                                            as ImageProvider,
                                ),
                                const SizedBox(width: 16),

                                // Post Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Username & Time
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            post['user_name'] ?? "Anonymous",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            timeAgo(post['created_at']),
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Title
                                      Text(
                                        post['title'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      const SizedBox(height: 12),

                                      // Reactions
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.favorite,
                                            size: 18,
                                            color: Colors.red.shade300,
                                          ),
                                          const SizedBox(width: 4),
                                          Text("${post['likes']}"),

                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.comment,
                                            size: 18,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text("${post['comments']}"),

                                          const SizedBox(width: 16),
                                          Icon(
                                            Icons.visibility,
                                            size: 18,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Text("${post['views']}"),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to convert timestamp to time ago format
  String timeAgo(String timestamp) {
    final postDate = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(postDate);

    if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays}d ago";
    }
  }
}
