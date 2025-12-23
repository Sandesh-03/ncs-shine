// lib/models/deed.dart
class Deed {
  final String id;
  final String userId;
  final String userName;
  final DeedType type;
  final int points;
  final DateTime date;
  final String? imagePath;

  Deed({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.points,
    required this.date,
    this.imagePath,
  });
}

enum DeedType { bloodDonation, treePlantation, wasteCleaning }

extension DeedTypeExtension on DeedType {
  String get name {
    switch (this) {
      case DeedType.bloodDonation:
        return 'Blood Donation';
      case DeedType.treePlantation:
        return 'Tree Plantation';
      case DeedType.wasteCleaning:
        return 'Waste Cleaning';
    }
  }

  int get points {
    switch (this) {
      case DeedType.bloodDonation:
        return 100;
      case DeedType.treePlantation:
        return 70;
      case DeedType.wasteCleaning:
        return 50;
    }
  }

  /// Helper to convert a string (like "blood donation" or "tree plantation")
  /// into the corresponding DeedType. Returns null if not recognized.
  static DeedType? fromString(String? value) {
    if (value == null) return null;
    final v = value.trim().toLowerCase();
    if (v.contains('blood')) return DeedType.bloodDonation;
    if (v.contains('tree') || v.contains('plant')) return DeedType.treePlantation;
    if (v.contains('waste') || v.contains('trash') || v.contains('clean')) return DeedType.wasteCleaning;
    return null;
  }
}
