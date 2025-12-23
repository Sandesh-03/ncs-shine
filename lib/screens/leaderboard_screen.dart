// lib/screens/leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_theme.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});
  static const routeName = '/leaderboard';

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with TickerProviderStateMixin {
  final firestore = FirebaseFirestore.instance;
  late AnimationController _controller;
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _listController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _controller.forward();
    _listController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _listController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> get leaderboardStream {
    return firestore
        .collection('user_board')
        .orderBy('score', descending: true)
        .limit(50)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: leaderboardStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: RotatingEarthLoader(size: 80),
          );
        }

        if (snapshot.hasError) {
          return Center(child: _buildErrorState(snapshot.error.toString()));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: _buildEmptyState());
        }

        final users = snapshot.data!.docs;

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FadeTransition(
                  opacity: _controller,
                  child: const Text(
                    'Leaderboard',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Top 3 Podium
              if (users.length >= 3) _buildPodium(users, currentUser),

              const SizedBox(height: 30),

              // Rest of the leaderboard
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppTheme.glassContainer(
                  padding: const EdgeInsets.all(20),
                  borderRadius: 24,
                  opacity: 0.12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Leaderboard',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your leaderboard gives you instant reference',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(
                        users.length > 3 ? users.length - 3 : 0,
                            (index) {
                          final actualIndex = index + 3;
                          final data = users[actualIndex].data()
                          as Map<String, dynamic>;
                          final userId = users[actualIndex].id;
                          final name = data['username'] ?? 'Unknown';
                          final score = data['score'] ?? 0;
                          final email = data['email'] ?? '';
                          final isCurrentUser = currentUser?.uid == userId;
                          final rank = actualIndex + 1;

                          return _buildLeaderboardItem(
                            rank: rank,
                            name: isCurrentUser ? 'You' : name,
                            score: score,
                            isCurrentUser: isCurrentUser,
                            delay: index * 0.05,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPodium(List<QueryDocumentSnapshot> users, User? currentUser) {
    // Get top 3 users
    final first = users.length > 0 ? users[0].data() as Map<String, dynamic> : null;
    final second = users.length > 1 ? users[1].data() as Map<String, dynamic> : null;
    final third = users.length > 2 ? users[2].data() as Map<String, dynamic> : null;

    // Check if current user is in top 3
    final firstId = users.length > 0 ? users[0].id : null;
    final secondId = users.length > 1 ? users[1].id : null;
    final thirdId = users.length > 2 ? users[2].id : null;

    return SizedBox(
      height: 400,
      child: Stack(
        children: [
          // Background Cards
          Positioned(
            left: 16,
            right: 16,
            top: 120,
            bottom: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Second Place
                if (second != null)
                  Expanded(
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(-1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
                      )),
                      child: _buildPodiumCard(
                        height: 180,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primaryGreen.withOpacity(0.6),
                            AppTheme.lightGreen.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                // First Place
                if (first != null)
                  Expanded(
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, -1),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
                      )),
                      child: _buildPodiumCard(
                        height: 220,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.accentGold.withOpacity(0.6),
                            AppTheme.primaryGreen.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                // Third Place
                if (third != null)
                  Expanded(
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: _controller,
                        curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
                      )),
                      child: _buildPodiumCard(
                        height: 160,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.lightGreen.withOpacity(0.6),
                            AppTheme.primaryGreen.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Profile Pictures and Info
          Positioned(
            left: 16,
            right: 16,
            top: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Second Place Profile
                if (second != null)
                  Expanded(
                    child: FadeTransition(
                      opacity: _controller,
                      child: _buildPodiumProfile(
                        rank: 2,
                        name: currentUser?.uid == secondId
                            ? 'You'
                            : (second['username'] ?? 'Unknown'),
                        score: second['score'] ?? 0,
                        rankColor: const Color(0xFFC0C0C0),
                        isCurrentUser: currentUser?.uid == secondId,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                // First Place Profile
                if (first != null)
                  Expanded(
                    child: FadeTransition(
                      opacity: _controller,
                      child: _buildPodiumProfile(
                        rank: 1,
                        name: currentUser?.uid == firstId
                            ? 'You'
                            : (first['username'] ?? 'Unknown'),
                        score: first['score'] ?? 0,
                        rankColor: AppTheme.accentGold,
                        isFirst: true,
                        isCurrentUser: currentUser?.uid == firstId,
                      ),
                    ),
                  ),
                const SizedBox(width: 12),
                // Third Place Profile
                if (third != null)
                  Expanded(
                    child: FadeTransition(
                      opacity: _controller,
                      child: _buildPodiumProfile(
                        rank: 3,
                        name: currentUser?.uid == thirdId
                            ? 'You'
                            : (third['username'] ?? 'Unknown'),
                        score: third['score'] ?? 0,
                        rankColor: const Color(0xFFCD7F32),
                        isCurrentUser: currentUser?.uid == thirdId,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumCard({
    required double height,
    required Gradient gradient,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumProfile({
    required int rank,
    required String name,
    required int score,
    required Color rankColor,
    bool isFirst = false,
    bool isCurrentUser = false, // ✨ ADDED
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Profile Picture with Medal
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: isFirst ? 100 : 80,
              height: isFirst ? 100 : 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrentUser ? AppTheme.accentGold : rankColor, // ✨ HIGHLIGHT
                  width: isCurrentUser ? 5 : 4, // ✨ THICKER FOR CURRENT USER
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isCurrentUser ? AppTheme.accentGold : rankColor)
                        .withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: ClipOval(
                child: Container(
                  color: isCurrentUser
                      ? AppTheme.accentGold.withOpacity(0.3) // ✨ GOLD FOR CURRENT USER
                      : AppTheme.primaryGreen,
                  child: Icon(
                    Icons.person,
                    size: isFirst ? 50 : 40,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Medal Badge
            Positioned(
              bottom: -5,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? AppTheme.accentGold : rankColor, // ✨ GOLD FOR CURRENT USER
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isCurrentUser ? AppTheme.accentGold : rankColor)
                            .withOpacity(0.6),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    isCurrentUser ? Icons.emoji_events : Icons.star, // ✨ TROPHY FOR CURRENT USER
                    color: Colors.white,
                    size: isFirst ? 24 : 20,
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: isFirst ? 20 : 16),

        // Name - "You" for current user
        Text(
          name,
          style: TextStyle(
            fontSize: isFirst ? 18 : 16,
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w600,
            color: isCurrentUser ? AppTheme.accentGold : Colors.white,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Score Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isCurrentUser ? AppTheme.accentGold : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
              ),
            ],
          ),
          child: Text(
            '$score points',
            style: TextStyle(
              fontSize: isFirst ? 16 : 14,
              fontWeight: FontWeight.bold,
              color: isCurrentUser ? Colors.white : AppTheme.primaryGreen, // ✨ WHITE TEXT FOR CURRENT USER
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required int score,
    required bool isCurrentUser,
    required double delay,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _listController,
          curve: Interval(
            delay.clamp(0.0, 0.9),
            1.0,
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? AppTheme.accentGold.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentUser
                ? AppTheme.accentGold.withOpacity(0.5)
                : Colors.white.withOpacity(0.1),
            width: isCurrentUser ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Rank Number
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCurrentUser
                      ? [AppTheme.accentGold, AppTheme.accentGold.withOpacity(0.7)]
                      : [AppTheme.primaryGreen, AppTheme.lightGreen],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Profile Picture
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrentUser
                      ? AppTheme.accentGold
                      : AppTheme.primaryGreen,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: Container(
                  color: isCurrentUser
                      ? AppTheme.accentGold.withOpacity(0.3)
                      : AppTheme.primaryGreen.withOpacity(0.3),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Name and Progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isCurrentUser
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isCurrentUser
                                ? AppTheme.accentGold
                                : Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.emoji_events,
                          color: AppTheme.accentGold,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: (score / 10000).clamp(0.0, 1.0),
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isCurrentUser
                            ? AppTheme.accentGold
                            : AppTheme.primaryGreen,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Score
            Text(
              '$score points',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isCurrentUser
                    ? AppTheme.accentGold
                    : AppTheme.primaryGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: AppTheme.glassContainer(
        padding: const EdgeInsets.all(32),
        borderRadius: 24,
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
                Icons.leaderboard,
                size: 60,
                color: AppTheme.darkGreen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Champions Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Be the first to make a difference! 🌱',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: AppTheme.glassContainer(
        padding: const EdgeInsets.all(24),
        borderRadius: 24,
        opacity: 0.12,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'Error Loading',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
