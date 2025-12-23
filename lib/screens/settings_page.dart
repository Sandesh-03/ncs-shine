// lib/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';
import 'auth_screen.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _notificationsEnabled = true;
  bool _emailNotifications = false;
  int totalPoints = 0;
  int totalDeeds = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Get user board data
      final userDoc = await FirebaseFirestore.instance
          .collection('user_board')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data();
        setState(() {
          totalPoints = data?['score'] ?? 0;
        });
      }

      // Count total deeds
      final deedsSnapshot = await FirebaseFirestore.instance
          .collection('good_deeds')
          .where('userId', isEqualTo: user.uid)
          .get();

      setState(() {
        totalDeeds = deedsSnapshot.docs.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final auth = context.watch<AuthenticationProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Profile Header Card
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
            )),
            child: FadeTransition(
              opacity: _animationController,
              child: AppTheme.glassContainer(
                padding: const EdgeInsets.all(24),
                borderRadius: 24,
                opacity: 0.12,
                child: Column(
                  children: [
                    // Profile Picture
                    Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.accentGold,
                                AppTheme.primaryGreen,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentGold.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // User Name
                    Text(
                      user?.displayName ?? 'User',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Email
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.email,
                            size: 16,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stats Row
                    if (_isLoading)
                      const RotatingEarthLoader(size: 40)
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            icon: Icons.stars,
                            label: 'Points',
                            value: totalPoints.toString(),
                            color: AppTheme.accentGold,
                          ),
                          Container(
                            width: 1,
                            height: 40,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          _buildStatItem(
                            icon: Icons.volunteer_activism,
                            label: 'Good Deeds',
                            value: totalDeeds.toString(),
                            color: AppTheme.primaryGreen,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Account Section
          _buildAnimatedSection(
            delay: 0.1,
            title: 'Account',
            items: [
              _SettingItem(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                subtitle: 'Update your personal information',
                onTap: () => _showEditProfileDialog(context),
              ),
              _SettingItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: () => _showChangePasswordDialog(context),
              ),
              _SettingItem(
                icon: Icons.delete_outline,
                title: 'Delete Account',
                subtitle: 'Permanently delete your account',
                onTap: () => _showDeleteAccountDialog(context),
                isDestructive: true,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Notifications Section
          _buildAnimatedSection(
            delay: 0.2,
            title: 'Notifications',
            items: [
              _SettingItemWithSwitch(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive push notifications',
                value: _notificationsEnabled,
                onChanged: (val) {
                  setState(() => _notificationsEnabled = val);
                  _showSnackBar('Push notifications ${val ? 'enabled' : 'disabled'}');
                },
              ),
              _SettingItemWithSwitch(
                icon: Icons.email_outlined,
                title: 'Email Notifications',
                subtitle: 'Receive email updates',
                value: _emailNotifications,
                onChanged: (val) {
                  setState(() => _emailNotifications = val);
                  _showSnackBar('Email notifications ${val ? 'enabled' : 'disabled'}');
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Privacy & Security Section
          _buildAnimatedSection(
            delay: 0.3,
            title: 'Privacy & Security',
            items: [
              _SettingItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () => _showPrivacyPolicyDialog(context),
              ),
              _SettingItem(
                icon: Icons.security_outlined,
                title: 'Terms of Service',
                subtitle: 'View terms and conditions',
                onTap: () => _showTermsDialog(context),
              ),
              _SettingItem(
                icon: Icons.shield_outlined,
                title: 'Data & Storage',
                subtitle: 'Manage your data',
                onTap: () {
                  _showSnackBar('Coming soon! 🚀');
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Support Section
          _buildAnimatedSection(
            delay: 0.4,
            title: 'Support',
            items: [
              _SettingItem(
                icon: Icons.help_outline,
                title: 'Help Center',
                subtitle: 'Get help and support',
                onTap: () {
                  _showSnackBar('Coming soon! 🚀');
                },
              ),
              _SettingItem(
                icon: Icons.feedback_outlined,
                title: 'Send Feedback',
                subtitle: 'Share your thoughts',
                onTap: () => _showFeedbackDialog(context),
              ),
              _SettingItem(
                icon: Icons.bug_report_outlined,
                title: 'Report a Bug',
                subtitle: 'Help us improve',
                onTap: () => _showBugReportDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // About Section
          _buildAnimatedSection(
            delay: 0.5,
            title: 'About',
            items: [
              _SettingItem(
                icon: Icons.info_outline,
                title: 'About App',
                subtitle: 'Version 1.0.0',
                onTap: () => _showAboutDialog(context),
              ),
              _SettingItem(
                icon: Icons.share_outlined,
                title: 'Share App',
                subtitle: 'Tell your friends',
                onTap: () {
                  _showSnackBar('Thanks for sharing! 🎉');
                },
              ),
              _SettingItem(
                icon: Icons.star_outline,
                title: 'Rate Us',
                subtitle: 'Rate on app store',
                onTap: () {
                  _showSnackBar('Thank you! ⭐');
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Logout Button
          SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
            )),
            child: FadeTransition(
              opacity: _animationController,
              child: SizedBox(
                width: double.infinity,
                child: AppTheme.glassButton(
                  onPressed: () async {
                    final confirm = await _showLogoutConfirmDialog(context);
                    if (confirm == true && context.mounted) {
                      await auth.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed(
                          AuthScreen.routeName,
                        );
                      }
                    }
                  },
                  text: 'Sign Out',
                  icon: Icons.logout,
                  isLoading: auth.isLoading,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Footer
          Center(
            child: Text(
              '© 2025 Ncs Shine\nMade with 💚 for a better world',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedSection({
    required double delay,
    required String title,
    required List<Widget> items,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-0.5, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(delay, delay + 0.3, curve: Curves.easeOut),
      )),
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _animationController,
          curve: Interval(delay, delay + 0.3, curve: Curves.easeIn),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            AppTheme.glassContainer(
              padding: const EdgeInsets.all(8),
              borderRadius: 20,
              opacity: 0.12,
              child: Column(children: items),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool?> _showLogoutConfirmDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => _buildDialog(
        title: 'Sign Out',
        icon: Icons.logout,
        iconColor: Colors.orange,
        content: Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
          ),
          AppTheme.glassButton(
            onPressed: () => Navigator.pop(context, true),
            text: 'Sign Out',
            icon: Icons.logout,
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final nameController = TextEditingController(
      text: FirebaseAuth.instance.currentUser?.displayName ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => _buildDialog(
        title: 'Edit Profile',
        icon: Icons.person,
        iconColor: AppTheme.primaryGreen,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: AppTheme.glassInputDecoration(
                label: 'Display Name',
                icon: Icons.person,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
          ),
          AppTheme.glassButton(
            onPressed: () async {
              await FirebaseAuth.instance.currentUser
                  ?.updateDisplayName(nameController.text.trim());
              if (context.mounted) {
                Navigator.pop(context);
                _showSnackBar('Profile updated! ✅');
              }
            },
            text: 'Save',
            icon: Icons.check,
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => _buildDialog(
        title: 'Change Password',
        icon: Icons.lock,
        iconColor: AppTheme.primaryGreen,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: currentPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: AppTheme.glassInputDecoration(
                label: 'Current Password',
                icon: Icons.lock_outline,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: newPasswordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: AppTheme.glassInputDecoration(
                label: 'New Password',
                icon: Icons.lock,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
          ),
          AppTheme.glassButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Password updated! 🔒');
            },
            text: 'Update',
            icon: Icons.check,
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildDialog(
        title: 'Delete Account',
        icon: Icons.warning,
        iconColor: Colors.red,
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
          ),
          AppTheme.glassButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Account deletion cancelled');
            },
            text: 'Delete',
            icon: Icons.delete,
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildDialog(
        title: 'Privacy Policy',
        icon: Icons.privacy_tip,
        iconColor: AppTheme.primaryGreen,
        content: SingleChildScrollView(
          child: Text(
            'We value your privacy and are committed to protecting your personal information.\n\n'
                '• We collect only necessary information\n'
                '• Your data is securely stored\n'
                '• We never sell your information\n'
                '• You can delete your account anytime',
            style: TextStyle(color: Colors.white.withOpacity(0.9), height: 1.5),
          ),
        ),
        actions: [
          AppTheme.glassButton(
            onPressed: () => Navigator.pop(context),
            text: 'Close',
            icon: Icons.close,
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildDialog(
        title: 'Terms of Service',
        icon: Icons.description,
        iconColor: AppTheme.primaryGreen,
        content: SingleChildScrollView(
          child: Text(
            'By using Ncs Shine, you agree to:\n\n'
                '• Post authentic good deeds only\n'
                '• Respect other users\n'
                '• Not misuse the platform\n'
                '• Follow community guidelines',
            style: TextStyle(color: Colors.white.withOpacity(0.9), height: 1.5),
          ),
        ),
        actions: [
          AppTheme.glassButton(
            onPressed: () => Navigator.pop(context),
            text: 'Close',
            icon: Icons.close,
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => _buildDialog(
        title: 'Send Feedback',
        icon: Icons.feedback,
        iconColor: AppTheme.accentGold,
        content: TextFormField(
          controller: feedbackController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: AppTheme.glassInputDecoration(
            label: 'Your Feedback',
            hint: 'Tell us what you think...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
          ),
          AppTheme.glassButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Thank you for your feedback! 💚');
            },
            text: 'Send',
            icon: Icons.send,
          ),
        ],
      ),
    );
  }

  void _showBugReportDialog(BuildContext context) {
    final bugController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => _buildDialog(
        title: 'Report a Bug',
        icon: Icons.bug_report,
        iconColor: Colors.orange,
        content: TextFormField(
          controller: bugController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: AppTheme.glassInputDecoration(
            label: 'Describe the bug',
            hint: 'What went wrong?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
          ),
          AppTheme.glassButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Bug report submitted! 🐛');
            },
            text: 'Submit',
            icon: Icons.send,
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildDialog(
        title: 'About Ncs Shine',
        icon: Icons.volunteer_activism,
        iconColor: AppTheme.accentGold,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Track and share your good deeds with the community. '
                  'Make the world a better place, one deed at a time. 🌍',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          AppTheme.glassButton(
            onPressed: () => Navigator.pop(context),
            text: 'Close',
            icon: Icons.close,
          ),
        ],
      ),
    );
  }

  Widget _buildDialog({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget content,
    required List<Widget> actions,
  }) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppTheme.backgroundImage),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.7),
              BlendMode.darken,
            ),
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: AppTheme.glassContainer(
          padding: const EdgeInsets.all(24),
          borderRadius: 24,
          opacity: 0.15,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(icon, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              content,
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Setting Item Widget
class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDestructive
                      ? Colors.red.withOpacity(0.2)
                      : AppTheme.primaryGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isDestructive ? Colors.red : Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDestructive ? Colors.red : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDestructive
                            ? Colors.red.withOpacity(0.7)
                            : Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDestructive
                    ? Colors.red.withOpacity(0.5)
                    : Colors.white.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Setting Item with Switch Widget
class _SettingItemWithSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingItemWithSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.accentGold,
            activeTrackColor: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }
}
