// lib/core/config/enums.dart
enum ViewState { busy, idle, error, success }

enum LeaderBoardFilter { today, weekly, all }

// Add deed types enum
enum GoodDeedType {
  bloodDonation('Blood Donation', 100),
  treePlantation('Tree Plantation', 70),
  wasteCleaning('Waste Cleaning', 50);

  final String displayName;
  final int points;

  const GoodDeedType(this.displayName, this.points);

  static GoodDeedType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'blood donation':
        return GoodDeedType.bloodDonation;
      case 'tree plantation':
        return GoodDeedType.treePlantation;
      case 'waste cleaning':
        return GoodDeedType.wasteCleaning;
      default:
        throw Exception('Unknown deed type: $value');
    }
  }
}
