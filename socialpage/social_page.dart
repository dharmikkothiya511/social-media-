import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:social_app/widgetpge/widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SocialFeedPage extends StatefulWidget {
  const SocialFeedPage({super.key});

  @override
  State<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends State<SocialFeedPage> {
  final supabase = Supabase.instance.client;
  List<Post> feed = [];

  @override
  void initState() {
    super.initState();
    _loadFeed();

    supabase.from('post').stream(primaryKey: ['id']).listen((_) => _loadFeed());
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
      final postsData = await supabase.from('posts').select();
      final likesRaw = await supabase.from('likes').select('post_id');
      final cmtsRaw = await supabase
          .from('comments')
          .select('post_id, comment');
      final emojiRaw = await supabase
          .from('emoji_reactions')
          .select('post_id, emoji');

      final likeMap = <int, int>{};
      for (var l in likesRaw) {
        likeMap[l['post_id']] = (likeMap[l['post_id']] ?? 0) + 1;
      }

      final cmtMap = <int, List<String>>{};
      for (var c in cmtsRaw) {
        cmtMap
            .putIfAbsent(c['post_id'] as int, () => [])
            .add(c['comment'] as String);
      }

      final emojiMap = <int, List<String>>{};
      for (var e in emojiRaw) {
        emojiMap
            .putIfAbsent(e['post_id'] as int, () => [])
            .add(e['emoji'] as String);
      }

      setState(() {
        feed = postsData.map<Post>((row) {
          int id = row['id'] as int;
          return Post(
            id: id,
            imageUrl: row['image_url'] as String,
            likeCount: likeMap[id] ?? 0,
            comments: cmtMap[id] ?? [],
            emojis: emojiMap[id] ?? [],
          );
        }).toList();
      });
    } catch (e) {
      debugPrint('Load feed error: $e');
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
      debugPrint('Error toggling like: $e');
    }
  }

  Future<void> _addComment(int postId, String comment) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await supabase.from('comments').insert({
        'post_id': postId,
        'user_id': userId,
        'comment': comment,
      });
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Feed'),
        backgroundColor: Colors.white12,
      ),
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
  final int likeCount;
  final List<String> comments;
  final List<String> emojis;

  Post({
    required this.id,
    required this.imageUrl,
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
  bool isFavorite = false;
  late int likeCount;
  late List<String> comments;
  late List<String> emojis;
  bool showComments = false;
  final TextEditingController ctrl = TextEditingController();
  String selectedEmoji = '';

  @override
  void initState() {
    super.initState();
    likeCount = widget.post.likeCount;
    comments = List<String>.from(widget.post.comments);
    emojis = List<String>.from(widget.post.emojis);
    _checkIfLiked();
    _checkIfFavorite();
  }

  Future<void> _checkIfLiked() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final res = await Supabase.instance.client
        .from('likes')
        .select()
        .eq('post_id', widget.post.id)
        .eq('user_id', userId)
        .maybeSingle();

    setState(() => liked = res != null);
  }

  Future<void> _checkIfFavorite() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final res = await Supabase.instance.client
        .from('favorites')
        .select('id')
        .eq('post_id', widget.post.id)
        .eq('user_id', userId)
        .maybeSingle();
    setState(() => isFavorite = res != null);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: Image.network(
              widget.post.imageUrl,
              height: 250,
              width: double.infinity,
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
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.emoji_emotions),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => EmojiFeedbackDialog(
                        onEmojiSelected: (emoji) async {
                          final userId =
                              Supabase.instance.client.auth.currentUser?.id;
                          if (userId != null) {
                            await Supabase.instance.client
                                .from('emoji_reactions')
                                .insert({
                                  'post_id': widget.post.id,
                                  'user_id': userId,
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
                if (selectedEmoji.isNotEmpty)
                  Text(selectedEmoji, style: const TextStyle(fontSize: 24)),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    color: isFavorite ? Colors.black : null,
                  ),
                  onPressed: () async {
                    final userId =
                        Supabase.instance.client.auth.currentUser?.id;
                    if (userId == null) return;

                    if (isFavorite) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Already in favorites")),
                      );
                      return;
                    }

                    try {
                      await Supabase.instance.client.from('favorites').insert({
                        'user_id': userId,
                        'post_id': widget.post.id,
                        'image_url': widget.post.imageUrl,
                      });
                      setState(() => isFavorite = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Added to favorites")),
                      );
                    } catch (e) {
                      debugPrint("Favorite insert error: $e");
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
                  vertical: 5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: comments.map((c) => Text('• $c')).toList(),
                ),
              ),
          ],
          if (emojis.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
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
      title: const Text('React with an Emoji'),
      content: Wrap(
        spacing: 10,
        children: emojis
            .map(
              (e) => GestureDetector(
                onTap: () => onEmojiSelected(e),
                child: Text(e, style: const TextStyle(fontSize: 28)),
              ),
            )
            .toList(),
      ),
    );
  }
}
