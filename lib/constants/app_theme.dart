// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:math' as math;

class AppTheme {
  // PRIMARY
  static const Color primaryGreen = Color(0xFF2D5016);   // Forest Green
  static const Color accentGold = Color(0xFFFFD700);     // Gold
  static const Color neutralWhite = Color(0xFFF5F5F5);   // Off White

  // Supporting shades
  static const Color darkGreen = Color(0xFF1A3010);
  static const Color lightGreen = Color(0xFF4A7029);

  // Background asset path
  static const String backgroundImage = 'assets/images/nature_bg.jpg';

  // Glass morphism container
  static Widget glassContainer({
    required Widget child,
    EdgeInsets? padding,
    double borderRadius = 20,
    double opacity = 0.12,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // Glass morphism button
  static Widget glassButton({
    required VoidCallback onPressed,
    required String text,
    IconData? icon,
    bool isLoading = false,
    bool isDisabled = false,
    double borderRadius = 16,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: (isLoading || isDisabled) ? null : onPressed,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: (isLoading || isDisabled)
                      ? [
                    Colors.grey.withOpacity(0.3),
                    Colors.grey.withOpacity(0.2),
                  ]
                      : [
                    primaryGreen,
                    lightGreen,
                  ],
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: isLoading
                  ? const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: RotatingEarthLoader(size: 24),
                ),
              )
                  : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: neutralWhite, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      color: neutralWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Glass text field
  static InputDecoration glassInputDecoration({
    required String label,
    IconData? icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Colors.white70) : null,
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.white,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.red.withOpacity(0.7),
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }
}

