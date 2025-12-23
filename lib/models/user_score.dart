// lib/domain/entities/user_score.dart
class UserScore {
  final String userId;
  final String userName;
  final int totalPoints;
  final int weeklyPoints;
  final int monthlyPoints;
  final int yearlyPoints;

  UserScore({
    required this.userId,
    required this.userName,
    required this.totalPoints,
    required this.weeklyPoints,
    required this.monthlyPoints,
    required this.yearlyPoints,
  });
}
