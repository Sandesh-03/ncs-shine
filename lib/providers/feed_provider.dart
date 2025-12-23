// lib/providers/feed_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../repositories/deed_repository.dart';


class FeedProvider with ChangeNotifier {
  final DeedRepositoryFirebase _repo = DeedRepositoryFirebase();

  Stream<QuerySnapshot> get feedStream => _repo.streamDeeds();

  Stream<QuerySnapshot> likesStream(String deedId) => _repo.streamLikes(deedId);

  Stream<QuerySnapshot> commentsStream(String deedId) => _repo.streamComments(deedId);

  Future<void> toggleLike(String deedId, bool currentlyLiked) async {
    if (currentlyLiked) {
      await _repo.unlikeDeed(deedId);
    } else {
      await _repo.likeDeed(deedId);
    }
  }

  Future<void> addComment(String deedId, String text) async {
    if (text.trim().isEmpty) return;
    await _repo.addComment(deedId, text.trim());
  }

  Future<void> shareDeed(String deedId, String text) async {
    await Share.share(text);
  }

  Future<void> toggleSave(String deedId, bool currentlySaved) async {
    if (currentlySaved) {
      await _repo.unsaveDeed(deedId);
    } else {
      await _repo.saveDeed(deedId);
    }
  }
}
