// lib/providers/auth_provider.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ViewState { idle, busy, success, error }

class AuthenticationProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ViewState _viewState = ViewState.idle;
  ViewState get viewState => _viewState;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  bool get isLoading => _viewState == ViewState.busy;

  void _setState(ViewState s) {
    _viewState = s;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    _viewState = ViewState.error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Register
  Future<bool> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _setState(ViewState.busy);
    clearError();

    try {
      final UserCredential uc = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = uc.user;
      if (user == null) {
        _setError('Registration failed: no user returned');
        return false;
      }

      // Optionally set display name on the Firebase User
      if (displayName != null && displayName.trim().isNotEmpty) {
        await user.updateDisplayName(displayName.trim());
        await user.reload();
      }

      // Create / update
      final userDoc = _firestore.collection('users').doc(user.uid);
      await userDoc.set({
        'userId': user.uid,
        'username': user.displayName ?? displayName ?? 'Anonymous',
        'email': user.email,
        'photoURL': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // leaderboard
      final boardDoc = _firestore.collection('user_board').doc(user.uid);
      final boardSnapshot = await boardDoc.get();
      if (!boardSnapshot.exists) {
        await boardDoc.set({
          'userId': user.uid,
          'username': user.displayName ?? displayName ?? 'Anonymous',
          'email': user.email,
          'score': 0,
          'timestamp': FieldValue.serverTimestamp(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      _setState(ViewState.success);
      return true;
    } on FirebaseAuthException catch (e) {
      // exceptions
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already in use.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'weak-password':
          message = 'Password is too weak (min 6 characters).';
          break;
        case 'operation-not-allowed':
          message = 'Operation not allowed. Check Firebase config.';
          break;
        default:
          message = e.message ?? 'Registration failed: ${e.code}';
      }
      log('SignUp error: $e');
      _setError(message);
      return false;
    } catch (e, st) {
      log('Unexpected signUp error: $e\n$st');
      _setError('An unexpected error occurred during registration.');
      return false;
    }
  }

  /// Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setState(ViewState.busy);
    clearError();

    try {
      final UserCredential uc = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = uc.user;
      if (user == null) {
        _setError('Login failed: no user returned');
        return false;
      }

      final userDoc = _firestore.collection('users').doc(user.uid);
      await userDoc.set({
        'userId': user.uid,
        'username': user.displayName ?? 'Anonymous',
        'email': user.email,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _setState(ViewState.success);
      return true;
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password.';
          break;
        case 'invalid-email':
          message = 'Invalid email address.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        default:
          message = e.message ?? 'Login failed: ${e.code}';
      }
      log('Login error: $e');
      _setError(message);
      return false;
    } catch (e, st) {
      log('Unexpected login error: $e\n$st');
      _setError('An unexpected error occurred during login.');
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setState(ViewState.busy);
    clearError();

    try {
      await _auth.signOut();
      _setState(ViewState.success);
    } catch (e) {
      log('SignOut error: $e');
      _setError('Sign out failed.');
    }
  }
}
