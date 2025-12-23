// lib/providers/deed_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../repositories/deed_repository.dart';

class DeedModel {
  final String deedId;
  final String userId;
  final String username;
  final String deedType;
  final int points;
  final String? comment;
  final String? imageUrl;
  final DateTime? timestamp;

  DeedModel({
    required this.deedId,
    required this.userId,
    required this.username,
    required this.deedType,
    required this.points,
    this.comment,
    this.imageUrl,
    this.timestamp,
  });

  factory DeedModel.fromMap(String id, Map<String, dynamic>? map) {
    if (map == null) {
      throw ArgumentError('map is null for deed $id');
    }

    return DeedModel(
      deedId: map['deedId'] as String? ?? id,
      userId: map['userId'] as String? ?? '',
      username: map['username'] as String? ?? 'Unknown',
      deedType: map['deedType'] as String? ?? '',
      points: (map['points'] is int) ? (map['points'] as int) : int.tryParse('${map['points'] ?? 0}') ?? 0,
      comment: map['comment'] as String?,
      imageUrl: map['imageUrl'] as String?,
      timestamp: (map['timestamp'] is Timestamp)
          ? (map['timestamp'] as Timestamp).toDate()
          : (map['timestamp'] is String)
          ? DateTime.tryParse(map['timestamp'] as String)
          : null,
    );
  }
}

/// DeedProvider
class DeedProvider with ChangeNotifier {
  final DeedRepositoryFirebase repository;

  DeedProvider({required this.repository});

  bool _isLoading = false;
  String? _error;
  List<DeedModel> _deeds = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<DeedModel> get deeds => List.unmodifiable(_deeds);

  StreamSubscription<QuerySnapshot>? _feedSub;
  StreamSubscription<QuerySnapshot>? _userSub;

  void startFeedListener({int limit = 100}) {
    _feedSub?.cancel();
    _feedSub = repository.streamDeeds(limit: limit).listen((snap) {
      _deeds = snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>?;
        return DeedModel.fromMap(d.id, data);
      }).toList();
      notifyListeners();
    }, onError: (e) {
      _error = e.toString();
      notifyListeners();
    });
  }

  void stopFeedListener() {
    _feedSub?.cancel();
    _feedSub = null;
  }

  Stream<List<DeedModel>> userDeedsStream({required String userId}) {
    final snapStream = FirebaseFirestore.instance
        .collection('good_deeds')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();

    return snapStream.map((snap) => snap.docs.map((d) {
      final data = d.data() as Map<String, dynamic>?;
      return DeedModel.fromMap(d.id, data);
    }).toList());
  }

  Future<void> loadDeedsOnce({int limit = 100}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snap = await repository.streamDeeds(limit: limit).first;
      _deeds = snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>?;
        return DeedModel.fromMap(d.id, data);
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDeed({
    required String deedType,
    required int points,
    required String? imagePathOrUrl,
    String comment = '',
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repository.addGoodDeed(
        deedType: deedType,
        points: points,
        imageUrl: imagePathOrUrl,
        comment: comment,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _feedSub?.cancel();
    _userSub?.cancel();
    super.dispose();
  }
}
