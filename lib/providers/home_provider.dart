// lib/providers/home_provider.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeProvider extends ChangeNotifier {
  static const String _scoreKey = 'user_score';
  int _counter = 0;
  int get counter => _counter;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Load saved score from local storage
  Future<void> loadSavedScore() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      _counter = prefs.getInt(_scoreKey) ?? 0;

      await _loadRemoteScore();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      log('Error loading saved score: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add points and update local + Firestore
  Future<void> increment(int points) async {
    _counter += points;
    notifyListeners();

    await _saveLocalScore();
    await _saveRemoteScore();
  }

  /// Update local storage
  Future<void> _saveLocalScore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_scoreKey, _counter);
    } catch (e) {
      log('Failed to save score locally: $e');
    }
  }

  /// Sync score
  Future<void> _saveRemoteScore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final ref = FirebaseFirestore.instance.collection('user_board').doc(user.uid);
      await ref.set({
        'userId': user.uid,
        'username': user.displayName ?? 'Anonymous',
        'score': _counter,
        'email': user.email,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      log('Score synced to Firestore: $_counter');
    } catch (e) {
      log('Error saving score to Firestore: $e');
    }
  }

  /// Load the latest remote score
  Future<void> _loadRemoteScore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('user_board')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['score'] != null) {
          _counter = data['score'] as int;
          await _saveLocalScore();
          log('Remote score loaded: $_counter');
        }
      }
    } catch (e) {
      log('Error loading score from Firestore: $e');
    }
  }

  /// Reset score
  Future<void> resetScore() async {
    _counter = 0;
    notifyListeners();
    await _saveLocalScore();
    await _saveRemoteScore();
  }
}
