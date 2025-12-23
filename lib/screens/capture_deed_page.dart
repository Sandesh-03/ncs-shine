// lib/screens/capture_deed_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_theme.dart';
import '../repositories/deed_repository.dart';
import '../services/ai_service.dart';

class CaptureDeedPage extends StatefulWidget {
  const CaptureDeedPage({super.key});

  @override
  State<CaptureDeedPage> createState() => _CaptureDeedPageState();
}

class _CaptureDeedPageState extends State<CaptureDeedPage> {
  final ImagePicker _picker = ImagePicker();
  final AIService _aiService = AIService();
  File? _imageFile;
  bool _isProcessing = false;
  bool _isAnalyzing = false;
  String? _detectedDeed;
  String? _selectedDeed;
  final TextEditingController _commentController = TextEditingController();

  final List<Map<String, dynamic>> deedOptions = [
    {
      'label': 'Blood Donation',
      'points': 100,
      'icon': Icons.bloodtype,
    },
    {
      'label': 'Tree Plantation',
      'points': 70,
      'icon': Icons.park,
    },
    {
      'label': 'Waste Cleaning',
      'points': 50,
      'icon': Icons.delete_sweep,
    },
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
        _detectedDeed = null;
        _selectedDeed = null;
      });
      await _analyzeImage();
    }
  }


  Future<void> _analyzeImage() async {
    if (_imageFile == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final result = await _aiService.recognizeImage(_imageFile!);

      setState(() {
        _detectedDeed = result;
        _selectedDeed = result;
        _isAnalyzing = false;
      });

      if (result == null || result.toLowerCase() == 'none') {
        _showNoDeedDetectedDialog();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Detected: $result'),
                ],
              ),
              backgroundColor: AppTheme.primaryGreen,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isAnalyzing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Analysis failed: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  void _showNoDeedDetectedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
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
            padding: const EdgeInsets.all(28),
            borderRadius: 24,
            opacity: 0.15,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Valid Deed Detected',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Please capture a clear image showing one of these activities:',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildDeedInfoItem(Icons.bloodtype, 'Blood Donation'),
                const SizedBox(height: 12),
                _buildDeedInfoItem(Icons.park, 'Tree Plantation'),
                const SizedBox(height: 12),
                _buildDeedInfoItem(Icons.delete_sweep, 'Waste Cleaning'),
                const SizedBox(height: 24),
                AppTheme.glassButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _imageFile = null;
                      _detectedDeed = null;
                      _selectedDeed = null;
                    });
                  },
                  text: 'Try Again',
                  icon: Icons.refresh,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeedInfoItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentGold.withOpacity(0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitDeed() async {
    if (_imageFile == null || _selectedDeed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Please capture a valid good deed')),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final repo = DeedRepositoryFirebase();
      final option = deedOptions.firstWhere(
            (d) => d['label'].toString().toLowerCase() == _selectedDeed!.toLowerCase(),
      );
      final points = option['points'] as int;

      await repo.addGoodDeed(
        deedType: _selectedDeed!,
        points: points,
        imageUrl: _imageFile!.path,
        comment: _commentController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.celebration, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Good deed posted! +$points points 🎉')),
              ],
            ),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Failed: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        height: double.maxFinite,
        width: double.maxFinite,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Capture Good Deed',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Image Preview Card
                AppTheme.glassContainer(
                  padding: EdgeInsets.zero,
                  borderRadius: 24,
                  opacity: 0.12,
                  child: InkWell(
                    onTap: _isAnalyzing ? null : () => _takePicture(),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: _isAnalyzing
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const RotatingEarthLoader(size: 80),
                            const SizedBox(height: 24),
                            Text(
                              'Analyzing your good deed...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This may take a moment',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      )
                          : _imageFile == null
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryGreen.withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 70,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Capture Your Good Deed',
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tap to take a photo 📸',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      )
                          : ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                            if (_detectedDeed != null && _detectedDeed != 'none')
                              Positioned(
                                top: 20,
                                right: 20,
                                child: AppTheme.glassContainer(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  borderRadius: 24,
                                  opacity: 0.2,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryGreen,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'Verified!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
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
                ),

                const SizedBox(height: 20),


                // Deed selection
                if (_detectedDeed != null && _detectedDeed != 'none') ...[
                  const SizedBox(height: 28),

                  // Deed Type Selection
                  AppTheme.glassContainer(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 24,
                    opacity: 0.12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.category,
                                color: AppTheme.darkGreen,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Select Deed Type',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ...deedOptions.map((deed) {
                          final isSelected = _selectedDeed == deed['label'];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => setState(() => _selectedDeed = deed['label']),
                                borderRadius: BorderRadius.circular(18),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                      colors: [
                                        AppTheme.primaryGreen.withOpacity(0.6),
                                        AppTheme.primaryGreen.withOpacity(0.3),
                                      ],
                                    )
                                        : LinearGradient(
                                      colors: [
                                        Colors.white.withOpacity(0.1),
                                        Colors.white.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.accentGold
                                          : Colors.white.withOpacity(0.2),
                                      width: isSelected ? 2.5 : 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                      BoxShadow(
                                        color: AppTheme.accentGold.withOpacity(0.3),
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                        : null,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryGreen.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Icon(
                                          deed['icon'],
                                          color: Colors.white,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              deed['label'],
                                              style: TextStyle(
                                                fontSize: 17,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Earn ${deed['points']} points',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.white.withOpacity(0.7),
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
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.stars,
                                              color: AppTheme.darkGreen,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              '${deed['points']}',
                                              style: TextStyle(
                                                color: AppTheme.darkGreen,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Comment Field
                  AppTheme.glassContainer(
                    padding: const EdgeInsets.all(24),
                    borderRadius: 24,
                    opacity: 0.12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.edit_note,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Add a Comment',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Optional - Share your experience',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _commentController,
                          maxLines: 4,
                          maxLength: 200,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Share what inspired you... 💭',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            counterStyle: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Post Button
                  AppTheme.glassButton(
                    onPressed: () => _submitDeed(),
                    text: 'Post Good Deed',
                    icon: Icons.publish,
                    isLoading: _isProcessing,
                  ),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
