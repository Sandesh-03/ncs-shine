// lib/screens/deed_comments_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../providers/feed_provider.dart';

class DeedCommentsPage extends StatefulWidget {
  final String deedId;

  const DeedCommentsPage({required this.deedId, super.key});

  @override
  State<DeedCommentsPage> createState() => _DeedCommentsPageState();
}

class _DeedCommentsPageState extends State<DeedCommentsPage> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FeedProvider(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppTheme.backgroundImage),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.3),
                BlendMode.darken,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Comments',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Consumer<FeedProvider>(
                    builder: (context, feed, _) {
                      return StreamBuilder<QuerySnapshot>(
                        stream: feed.commentsStream(widget.deedId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: RotatingEarthLoader(size: 80),
                            );
                          }

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
                                        size: 64,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Error Loading Comments',
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

                          final comments = snapshot.data?.docs ?? [];

                          if (comments.isEmpty) {
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
                                          Icons.comment_outlined,
                                          size: 60,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      const Text(
                                        'No comments yet',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Be the first to comment! 💬',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index].data() as Map<String, dynamic>;
                              final username = comment['username'] ?? 'Anonymous';
                              final text = comment['text'] ?? '';
                              final timestamp = (comment['timestamp'] as Timestamp?)?.toDate();

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: AppTheme.glassContainer(
                                  padding: const EdgeInsets.all(16),
                                  borderRadius: 16,
                                  opacity: 0.12,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryGreen,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.white,
                                              size: 20,
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
                                                    color: Colors.white,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                if (timestamp != null)
                                                  Text(
                                                    _formatTimeAgo(timestamp),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white.withOpacity(0.6),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        text,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.95),
                                          fontSize: 14,
                                          height: 1.4,
                                        ),
                                      ),
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
                ),

                // Comment input
                Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 12,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                  ),
                  child: AppTheme.glassContainer(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    borderRadius: 24,
                    opacity: 0.15,
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            focusNode: _focusNode,
                            style: const TextStyle(color: Colors.white),
                            maxLines: null,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                        Consumer<FeedProvider>(
                          builder: (context, feed, _) {
                            return IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              onPressed: () async {
                                if (_commentController.text.trim().isNotEmpty) {
                                  await feed.addComment(
                                    widget.deedId,
                                    _commentController.text.trim(),
                                  );
                                  _commentController.clear();
                                  _focusNode.unfocus();

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Comment added! 💬'),
                                        backgroundColor: AppTheme.primaryGreen,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '${diff.inSeconds}s ago';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
