// lib/repositories/auth_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sign up with email & password and create Firestore user doc + user_board entry.
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    required String username,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = cred.user;
    if (user == null) {
      throw FirebaseAuthException(code: 'user-null', message: 'User is null after sign up');
    }

    await user.updateDisplayName(username);
    await user.reload();

    // Create / merge Firestore user doc
    final userDoc = _firestore.collection('users').doc(user.uid);
    await userDoc.set({
      'userId': user.uid,
      'username': username,
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Create user_board entry to track user score
    final boardDoc = _firestore.collection('user_board').doc(user.uid);
    await boardDoc.set({
      'userId': user.uid,
      'username': username,
      'score': 0,
      'email': email.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return cred;
  }

  /// Sign in with email & password
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = cred.user;
    if (user != null) {
      final userDocRef = _firestore.collection('users').doc(user.uid);
      final snapshot = await userDocRef.get();
      if (!snapshot.exists) {
        await userDocRef.set({
          'userId': user.uid,
          'username': user.displayName ?? 'Anonymous',
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // ensure user_board exists
      final boardRef = _firestore.collection('user_board').doc(user.uid);
      final boardSnap = await boardRef.get();
      if (!boardSnap.exists) {
        await boardRef.set({
          'userId': user.uid,
          'username': user.displayName ?? 'Anonymous',
          'score': 0,
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
          'timestamp': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }

    return cred;
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Return current Firebase user (nullable)
  User? currentUser() {
    return _auth.currentUser;
  }

  /// Update user profile fields (username/email) in Firestore
  Future<void> updateUserProfile({
    required String userId,
    required String username,
    required String email,
  }) async {
    final userDoc = _firestore.collection('users').doc(userId);
    await userDoc.set({
      'userId': userId,
      'username': username,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Also sync username to user_board
    final userBoardDoc = _firestore.collection('user_board').doc(userId);
    await userBoardDoc.set({
      'userId': userId,
      'username': username,
      'email': email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
