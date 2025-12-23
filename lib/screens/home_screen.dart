// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import '../constants/app_theme.dart';
import '../providers/home_provider.dart';
import '../providers/auth_provider.dart';

import 'deed_history_page.dart';
import 'feeds_page.dart';
import 'capture_deed_page.dart';
import 'leaderboard_screen.dart';
import 'settings_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 1;

  final List<IconData> iconList = [
    Icons.history_rounded,
    Icons.feed_outlined,
    Icons.emoji_events_outlined,
    Icons.settings_outlined,
  ];

  final List<Widget> _pages = const [
    DeedHistoryPage(),
    FeedsPage(),
    LeaderboardScreen(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeProvider>().loadSavedScore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthenticationProvider>();
    final score = context.watch<HomeProvider>().counter;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
        title: AppTheme.glassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          borderRadius: 16,
          opacity: 0.15,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.eco, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'Hi, ${auth.currentUser?.displayName ?? 'User'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AppTheme.glassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              borderRadius: 16,
              opacity: 0.15,
              child: Row(
                children: [
                  Icon(Icons.stars, color: AppTheme.accentGold, size: 20),
                  const SizedBox(width: 6),
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: score),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) {
                      return Text(
                        '$value',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'pts',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
          child: _pages[_selectedIndex],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
            boxShadow: [BoxShadow(
          color: AppTheme.accentGold.withOpacity(0.5),
          blurRadius: 20,
          spreadRadius: 5,
        )]),
        child: FloatingActionButton(
          backgroundColor: AppTheme.accentGold,
          elevation: 8,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CaptureDeedPage()),
            );
          },
          child: Icon(Icons.add_a_photo, color: AppTheme.darkGreen, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: iconList,
        activeIndex: _selectedIndex,
        gapLocation: GapLocation.center,
        notchMargin: 8,
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 24,
        rightCornerRadius: 24,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: AppTheme.primaryGreen.withOpacity(0.95),
        activeColor: AppTheme.accentGold,
        inactiveColor: AppTheme.neutralWhite.withOpacity(0.6),
        height: 60,
        splashColor: AppTheme.accentGold.withOpacity(0.3),
        splashSpeedInMilliseconds: 300,
        shadow: BoxShadow(
          offset: const Offset(0, -2),
          blurRadius: 20,
          color: Colors.black.withOpacity(0.3),
        ),
      ),
    );
  }
}
