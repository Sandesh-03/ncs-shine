// lib/screens/feeds_page.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/feed_provider.dart';
import '../repositories/deed_repository.dart';
import 'deed_comments_page.dart';

class FeedsPage extends StatelessWidget {
  const FeedsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedProvider(),
      child: Consumer<FeedProvider>(
        builder: (context, feed, child) {
          return StreamBuilder<QuerySnapshot>(
            stream: feed.feedStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: AppTheme.glassContainer(
                      padding: const EdgeInsets.all(24),
                      opacity: 0.12,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.white,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Error Loading Feeds',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: RotatingEarthLoader(size: 80),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: AppTheme.glassContainer(
                      padding: const EdgeInsets.all(32),
                      opacity: 0.12,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.feed,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'No Posts Yet',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Be the first to share a good deed! 🌱',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final deedId = data['deedId'] as String? ?? doc.id;
                  final username = data['username'] ?? 'Unknown';
                  final deedType = data['deedType'] ?? '';
                  final comment = data['comment'] ?? '';
                  final imageUrl = data['imageUrl'] as String?;
                  final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
                  final points = data['points'] ?? 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppTheme.glassContainer(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 20,
                      opacity: 0.12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryGreen.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      username,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    if (timestamp != null)
                                      Text(
                                        _formatTimeAgo(timestamp),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white.withOpacity(0.6),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.accentGold.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.stars,
                                      color: AppTheme.darkGreen,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$points',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.darkGreen,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Deed Type Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.primaryGreen.withOpacity(0.5),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getDeedIcon(deedType),
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  deedType,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Comment
                          if (comment.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(
                              comment,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.95),
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                          ],

                          // Image
                          if (imageUrl != null && imageUrl.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: _buildImage(imageUrl),
                            ),
                          ],

                          const SizedBox(height: 14),

                          // Divider
                          Container(
                            height: 1,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.1),
                                  Colors.white.withOpacity(0.3),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Actions
                          PostActions(deedId: deedId),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        height: 240,
        width: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          height: 240,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.white, size: 48),
          ),
        ),
      );
    } else {
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: BoxFit.cover,
          height: 240,
          width: double.infinity,
        );
      } else {
        return Container(
          height: 240,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(Icons.broken_image, color: Colors.white, size: 48),
          ),
        );
      }
    }
  }

  IconData _getDeedIcon(String deedType) {
    switch (deedType.toLowerCase()) {
      case 'blood donation':
        return Icons.bloodtype;
      case 'tree plantation':
        return Icons.park;
      case 'waste cleaning':
        return Icons.delete_sweep;
      default:
        return Icons.volunteer_activism;
    }
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }
}

// Post Actions Widget
class PostActions extends StatefulWidget {
  final String deedId;

  const PostActions({required this.deedId, super.key});

  @override
  State<PostActions> createState() => _PostActionsState();
}

class _PostActionsState extends State<PostActions> {
  bool liked = false;
  bool saved = false;
  int likesCount = 0;
  int commentsCount = 0;
  final DeedRepositoryFirebase repo = DeedRepositoryFirebase();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    repo.isLiked(widget.deedId).then((val) {
      if (mounted) setState(() => liked = val);
    });

    repo.streamLikes(widget.deedId).listen((snap) {
      if (mounted) setState(() => likesCount = snap.docs.length);
    });

    repo.streamComments(widget.deedId).listen((snap) {
      if (mounted) setState(() => commentsCount = snap.docs.length);
    });

    repo.streamSaves(widget.deedId).listen((snap) {
      if (mounted) {
        setState(() => saved = snap.docs.any((d) => d.id == repo.usrId));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final feed = Provider.of<FeedProvider>(context, listen: false);

    return Row(
      children: [
        _buildActionButton(
          icon: liked ? Icons.favorite : Icons.favorite_border,
          label: likesCount > 0 ? '$likesCount' : 'Like',
          color: liked ? Colors.red : Colors.white,
          onTap: () async {
            await feed.toggleLike(widget.deedId, liked);
            setState(() => liked = !liked);
          },
        ),
        const SizedBox(width: 20),
        _buildActionButton(
          icon: Icons.mode_comment_outlined,
          label: commentsCount > 0 ? '$commentsCount' : 'Comment',
          color: Colors.white,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DeedCommentsPage(deedId: widget.deedId),
              ),
            );
          },
        ),
        const Spacer(),
        _buildActionButton(
          icon: saved ? Icons.bookmark : Icons.bookmark_border,
          label: '',
          color: saved ? AppTheme.accentGold : Colors.white,
          onTap: () async {
            await feed.toggleSave(widget.deedId, saved);
            setState(() => saved = !saved);
          },
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          icon: Icons.share_outlined,
          label: '',
          color: Colors.white,
          onTap: () async {
            final doc = await FirebaseFirestore.instance
                .collection('good_deeds')
                .doc(widget.deedId)
                .get();
            final data = doc.data();
            final text =
                '${data?['username'] ?? 'Someone'} shared: ${data?['deedType'] ?? 'a good deed'}';
            await feed.shareDeed(widget.deedId, text);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Shared successfully! 🎉'),
                  backgroundColor: AppTheme.primaryGreen,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
