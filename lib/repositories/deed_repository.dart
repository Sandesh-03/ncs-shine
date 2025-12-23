// lib/repositories/deed_repository_firebase.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DeedRepositoryFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get usrId => _auth.currentUser?.uid ?? '';

  Future<void> addGoodDeed({
    required String deedType,
    required int points,
    required String? imageUrl,
    required String comment,
  }) async {
    if (usrId.isEmpty) throw Exception('User not authenticated');

    final user = _auth.currentUser!;
    final deedRef = _firestore.collection('good_deeds').doc();
    final deedId = deedRef.id;

    final deedData = {
      'deedId': deedId,
      'userId': usrId,
      'username': user.displayName ?? user.email ?? 'Anonymous',
      'deedType': deedType,
      'points': points,
      'comment': comment,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    };

    // Save deed
    await deedRef.set(deedData);

    // Update user score in user_board (increment)
    final userBoardRef = _firestore.collection('user_board').doc(usrId);
    await _firestore.runTransaction((tx) async {
      final snapshot = await tx.get(userBoardRef);
      if (!snapshot.exists) {
        tx.set(userBoardRef, {
          'userId': usrId,
          'username': deedData['username'],
          'score': points,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        final current = (snapshot.data()?['score'] ?? 0) as int;
        tx.update(userBoardRef, {
          'score': current + points,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Stream<QuerySnapshot> streamDeeds({int limit = 50}) {
    return _firestore
        .collection('good_deeds')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<void> likeDeed(String deedId) async {
    final userId = usrId;
    if (userId.isEmpty) throw Exception('Not authenticated');
    final likeRef = _firestore.collection('good_deeds').doc(deedId).collection('likes').doc(userId);
    await likeRef.set({'likedAt': FieldValue.serverTimestamp()});
  }

  Future<void> unlikeDeed(String deedId) async {
    final userId = usrId;
    final likeRef = _firestore.collection('good_deeds').doc(deedId).collection('likes').doc(userId);
    await likeRef.delete();
  }

  Future<bool> isLiked(String deedId) async {
    final userId = usrId;
    if (userId.isEmpty) return false;
    final doc = await _firestore.collection('good_deeds').doc(deedId).collection('likes').doc(userId).get();
    return doc.exists;
  }

  Stream<QuerySnapshot> streamLikes(String deedId) {
    return _firestore.collection('good_deeds').doc(deedId).collection('likes').snapshots();
  }

  Future<void> addComment(String deedId, String text) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final commentRef = _firestore.collection('good_deeds').doc(deedId).collection('comments').doc();
    await commentRef.set({
      'commentId': commentRef.id,
      'userId': user.uid,
      'username': user.displayName ?? user.email ?? 'Anonymous',
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> streamComments(String deedId, {int limit = 50}) {
    return _firestore
        .collection('good_deeds')
        .doc(deedId)
        .collection('comments')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots();
  }

  Future<void> saveDeed(String deedId) async {
    final userId = usrId;
    if (userId.isEmpty) throw Exception('Not authenticated');
    final saveRef = _firestore.collection('good_deeds').doc(deedId).collection('saves').doc(userId);
    await saveRef.set({'savedAt': FieldValue.serverTimestamp()});
  }

  Future<void> unsaveDeed(String deedId) async {
    final userId = usrId;
    final saveRef = _firestore.collection('good_deeds').doc(deedId).collection('saves').doc(userId);
    await saveRef.delete();
  }

  Stream<QuerySnapshot> streamSaves(String deedId) {
    return _firestore.collection('good_deeds').doc(deedId).collection('saves').snapshots();
  }
}
