import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:social_app/widgetpge/widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  List<Post> feed = [];

  @override
  void initState() {
    super.initState();
    _loadFeed();
    supabase
        .from('posts')
        .stream(primaryKey: ['id'])
        .listen((_) => _loadFeed());
    supabase
        .from('likes')
        .stream(primaryKey: ['id'])
        .listen((_) => _loadFeed());
    supabase
        .from('comments')
        .stream(primaryKey: ['id'])
        .listen((_) => _loadFeed());
    supabase
        .from('emoji_reactions')
        .stream(primaryKey: ['id'])
        .listen((_) => _loadFeed());
  }

  Future<void> _loadFeed() async {
    try {
      // Select posts + profiles
      final postsData = await supabase.from('posts').select('''
            id, image_url, user_id,
            profiles(full_name, avatar_url)
          ''');

      final likesRaw = await supabase.from('likes').select('post_id');
      final cmtsRaw = await supabase
          .from('comments')
          .select('post_id, comment');
      final emojiRaw = await supabase
          .from('emoji_reactions')
          .select('post_id, emoji');

      // Build maps:
      final likeMap = <int, int>{};
      for (var l in likesRaw) {
        likeMap[l['post_id']] = (likeMap[l['post_id']] ?? 0) + 1;
      }
      final cmtMap = <int, List<String>>{};
      for (var c in cmtsRaw) {
        cmtMap.putIfAbsent(c['post_id'], () => []).add(c['comment']);
      }
      final emojiMap = <int, List<String>>{};
      for (var e in emojiRaw) {
        emojiMap.putIfAbsent(e['post_id'], () => []).add(e['emoji']);
      }

      setState(() {
        feed = postsData.map<Post>((row) {
          final id = row['id'] as int;
          final profile = row['profiles'] ?? {};
          return Post(
            id: id,
            imageUrl: row['image_url'],
            fullName: profile['full_name'] ?? 'User',
            avatarUrl: profile['avatar_url'],
            likeCount: likeMap[id] ?? 0,
            comments: cmtMap[id] ?? [],
            emojis: emojiMap[id] ?? [],
          );
        }).toList();
      });
    } catch (e) {
      debugPrint("Load feed error: $e");
    }
  }

  Future<void> _toggleLike(int postId, bool isLiked) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      if (isLiked) {
        await supabase.from('likes').insert({
          'post_id': postId,
          'user_id': userId,
        });
      } else {
        await supabase.from('likes').delete().match({
          'post_id': postId,
          'user_id': userId,
        });
      }
    } catch (e) {
      debugPrint("Like error: $e");
    }
  }

  Future<void> _addComment(int postId, String c) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await supabase.from('comments').insert({
        'post_id': postId,
        'user_id': userId,
        'comment': c,
      });
    } catch (e) {
      debugPrint("Comment error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Social Home")),
      body: ListView.builder(
        itemCount: feed.length,
        itemBuilder: (_, idx) {
          final post = feed[idx];
          return PostCard(
            post: post,
            onLike: (val) => _toggleLike(post.id, val),
            onComment: (txt) => _addComment(post.id, txt),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBarWidget(),
    );
  }
}

class Post {
  final int id;
  final String imageUrl;
  final String fullName;
  final String? avatarUrl;
  final int likeCount;
  final List<String> comments;
  final List<String> emojis;

  Post({
    required this.id,
    required this.imageUrl,
    required this.fullName,
    required this.avatarUrl,
    required this.likeCount,
    required this.comments,
    required this.emojis,
  });
}

class PostCard extends StatefulWidget {
  final Post post;
  final Future<void> Function(bool) onLike;
  final Future<void> Function(String) onComment;

  const PostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool liked = false;
  late int likeCount;
  bool showComments = false;
  late List<String> comments;
  late List<String> emojis;
  bool isFavorite = false;

  final TextEditingController ctrl = TextEditingController();
  String selectedEmoji = '';

  @override
  void initState() {
    super.initState();
    likeCount = widget.post.likeCount;
    comments = List<String>.from(widget.post.comments);
    emojis = List<String>.from(widget.post.emojis);
    _checkLiked();
    _checkFavorite();
  }

  Future<void> _checkLiked() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final res = await Supabase.instance.client
        .from('likes')
        .select()
        .eq('post_id', widget.post.id)
        .eq('user_id', uid)
        .maybeSingle();

    setState(() => liked = res != null);
  }

  Future<void> _checkFavorite() async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;
    final res = await Supabase.instance.client
        .from('favorites')
        .select('id')
        .eq('post_id', widget.post.id)
        .eq('user_id', uid)
        .maybeSingle();
    setState(() => isFavorite = res != null);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar showing profile
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  (widget.post.avatarUrl != null &&
                      widget.post.avatarUrl!.isNotEmpty)
                  ? NetworkImage(widget.post.avatarUrl!)
                  : null,
              child:
                  (widget.post.avatarUrl == null ||
                      widget.post.avatarUrl!.isEmpty)
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(widget.post.fullName),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.post.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                LikeButton(
                  size: 30,
                  isLiked: liked,
                  likeCount: likeCount,
                  countBuilder: (cnt, _, __) => Text('$cnt'),
                  onTap: (isLiked) async {
                    await widget.onLike(!isLiked);
                    setState(() {
                      liked = !isLiked;
                      likeCount += liked ? 1 : -1;
                    });
                    return !isLiked;
                  },
                ),
                const SizedBox(width: 15),
                IconButton(
                  icon: const Icon(Icons.emoji_emotions),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => EmojiFeedbackDialog(
                        onEmojiSelected: (emoji) async {
                          final uid =
                              Supabase.instance.client.auth.currentUser?.id;
                          if (uid != null) {
                            await Supabase.instance.client
                                .from('emoji_reactions')
                                .insert({
                                  'post_id': widget.post.id,
                                  'user_id': uid,
                                  'emoji': emoji,
                                });
                          }
                          setState(() {
                            selectedEmoji = emoji;
                            emojis.add(emoji);
                          });
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () => setState(() => showComments = !showComments),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    color: isFavorite ? Colors.black : null,
                  ),
                  onPressed: () async {
                    final uid = Supabase.instance.client.auth.currentUser?.id;
                    if (uid == null) return;
                    if (isFavorite) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Already in favorites')),
                      );
                      return;
                    }
                    try {
                      await Supabase.instance.client.from('favorites').insert({
                        'user_id': uid,
                        'post_id': widget.post.id,
                        'image_url': widget.post.imageUrl,
                      });
                      setState(() => isFavorite = true);
                    } catch (e) {
                      debugPrint('Favorite error: $e');
                    }
                  },
                ),
              ],
            ),
          ),
          if (showComments) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                controller: ctrl,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      final txt = ctrl.text.trim();
                      if (txt.isNotEmpty) {
                        await widget.onComment(txt);
                        setState(() => comments.add(txt));
                        ctrl.clear();
                      }
                    },
                  ),
                ),
              ),
            ),
            if (comments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: comments.map((c) => Text('• $c')).toList(),
                ),
              ),
          ],
          if (emojis.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Wrap(
                spacing: 8,
                children: emojis
                    .map((e) => Text(e, style: const TextStyle(fontSize: 22)))
                    .toList(),
              ),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class EmojiFeedbackDialog extends StatelessWidget {
  final void Function(String emoji) onEmojiSelected;
  const EmojiFeedbackDialog({super.key, required this.onEmojiSelected});
  @override
  Widget build(BuildContext context) {
    final emojis = ['😀', '😍', '😢', '😡', '👍', '🎉'];
    return AlertDialog(
      title: const Text("React with Emoji"),
      content: Wrap(
        spacing: 10,
        children: emojis.map((e) {
          return GestureDetector(
            onTap: () => onEmojiSelected(e),
            child: Text(e, style: const TextStyle(fontSize: 28)),
          );
        }).toList(),
      ),
    );
  }
}
