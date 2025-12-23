// lib/screens/deed_history_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_theme.dart';
import '../providers/deed_provider.dart';

class DeedHistoryPage extends StatelessWidget {
  const DeedHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: AppTheme.glassContainer(
            padding: const EdgeInsets.all(32),
            opacity: 0.12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 64,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Please sign in',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to view your deed history',
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

    final deedProvider = context.read<DeedProvider>();

    return StreamBuilder<List<DeedModel>>(
      stream: deedProvider.userDeedsStream(userId: user.uid),
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
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Error loading your deeds',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final deeds = snapshot.data ?? [];

        if (deeds.isEmpty) {
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
                        color: AppTheme.accentGold,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.history,
                        size: 60,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No Deeds Recorded',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Start making a difference!\nCapture your first good deed 🌱',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.5,
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
          itemCount: deeds.length,
          itemBuilder: (context, index) {
            final deed = deeds[index];
            final date = deed.timestamp != null
                ? '${deed.timestamp!.day}/${deed.timestamp!.month}/${deed.timestamp!.year}'
                : 'Unknown date';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppTheme.glassContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 16,
                opacity: 0.12,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon/Image
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: deed.imageUrl != null && deed.imageUrl!.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _buildImage(deed.imageUrl!),
                      )
                          : Icon(
                        _getDeedIcon(deed.deedType),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Deed Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            deed.deedType,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          if (deed.comment != null && deed.comment!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                deed.comment!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.stars,
                                      size: 14,
                                      color: AppTheme.darkGreen,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${deed.points} pts',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.darkGreen,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: Colors.white.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                date,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
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
        );
      },
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, _, __) => const Icon(
          Icons.broken_image,
          color: Colors.white,
        ),
      );
    } else {
      final file = File(imageUrl);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      } else {
        return const Icon(Icons.broken_image, color: Colors.white);
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
}
