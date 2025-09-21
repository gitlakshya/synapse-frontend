import 'dart:convert';
import 'dart:math';
import 'dart:html' as html;

class GamificationService {
  static const _userStatsKey = 'user_stats';
  static const _achievementsKey = 'achievements';
  static const _challengesKey = 'challenges';

  static Future<UserStats> getUserStats() async {
    try {
      final statsJson = html.window.localStorage[_userStatsKey];
      if (statsJson != null) {
        return UserStats.fromJson(json.decode(statsJson));
      }
    } catch (e) {
      print('Error reading user stats: $e');
    }
    return UserStats.initial();
  }

  static Future<void> updateUserStats(UserStats stats) async {
    html.window.localStorage[_userStatsKey] = json.encode(stats.toJson());
  }

  static Future<void> awardPoints(int points, String reason) async {
    final stats = await getUserStats();
    stats.totalPoints += points;
    stats.currentStreak = _calculateStreak(stats);
    stats.level = _calculateLevel(stats.totalPoints);
    
    await updateUserStats(stats);
    await _checkAchievements(stats);
  }

  static Future<List<Achievement>> getAchievements() async {
    try {
      final achievementsJson = html.window.localStorage[_achievementsKey];
      if (achievementsJson != null) {
        final List<dynamic> achievementsList = json.decode(achievementsJson);
        return achievementsList.map((a) => Achievement.fromJson(a)).toList();
      }
    } catch (e) {
      print('Error reading achievements: $e');
    }
    return _getDefaultAchievements();
  }

  static Future<void> unlockAchievement(String achievementId) async {
    final achievements = await getAchievements();
    final achievement = achievements.firstWhere((a) => a.id == achievementId);
    achievement.isUnlocked = true;
    achievement.unlockedAt = DateTime.now();
    
    html.window.localStorage[_achievementsKey] = json.encode(achievements.map((a) => a.toJson()).toList());
  }

  static Future<List<Challenge>> getActiveChallenges() async {
    try {
      final challengesJson = html.window.localStorage[_challengesKey];
      if (challengesJson != null) {
        final List<dynamic> challengesList = json.decode(challengesJson);
        return challengesList.map((c) => Challenge.fromJson(c)).toList();
      }
    } catch (e) {
      print('Error reading challenges: $e');
    }
    return _getDefaultChallenges();
  }

  static Future<void> updateChallengeProgress(String challengeId, int progress) async {
    final challenges = await getActiveChallenges();
    final challenge = challenges.firstWhere((c) => c.id == challengeId);
    challenge.currentProgress = progress;
    
    if (challenge.currentProgress >= challenge.targetProgress && !challenge.isCompleted) {
      challenge.isCompleted = true;
      challenge.completedAt = DateTime.now();
      await awardPoints(challenge.rewardPoints, 'Challenge completed: ${challenge.title}');
    }
    
    html.window.localStorage[_challengesKey] = json.encode(challenges.map((c) => c.toJson()).toList());
  }

  static Future<Leaderboard> getLeaderboard() async {
    // Mock leaderboard data
    final random = Random();
    return Leaderboard(
      entries: List.generate(10, (index) => LeaderboardEntry(
        rank: index + 1,
        username: 'Traveler${index + 1}',
        points: 5000 - (index * 500) + random.nextInt(200),
        level: 'Explorer',
        avatar: 'https://i.pravatar.cc/150?img=${index + 1}',
      )),
      userRank: 5,
      totalParticipants: 1247,
    );
  }

  static int _calculateStreak(UserStats stats) {
    // Mock streak calculation
    return stats.tripsCompleted > 0 ? min(stats.tripsCompleted, 30) : 0;
  }

  static String _calculateLevel(int points) {
    if (points < 1000) return 'Novice';
    if (points < 2500) return 'Explorer';
    if (points < 5000) return 'Adventurer';
    if (points < 10000) return 'Wanderer';
    if (points < 20000) return 'Globe Trotter';
    return 'Travel Master';
  }

  static Future<void> _checkAchievements(UserStats stats) async {
    final achievements = await getAchievements();
    
    for (final achievement in achievements) {
      if (!achievement.isUnlocked && _checkAchievementCondition(achievement, stats)) {
        await unlockAchievement(achievement.id);
      }
    }
  }

  static bool _checkAchievementCondition(Achievement achievement, UserStats stats) {
    switch (achievement.id) {
      case 'first_trip':
        return stats.tripsCompleted >= 1;
      case 'budget_saver':
        return stats.totalSaved >= 5000;
      case 'social_butterfly':
        return stats.tripsShared >= 5;
      case 'eco_warrior':
        return stats.carbonOffset >= 100;
      case 'streak_master':
        return stats.currentStreak >= 7;
      default:
        return false;
    }
  }

  static List<Achievement> _getDefaultAchievements() {
    return [
      Achievement(
        id: 'first_trip',
        title: 'First Adventure',
        description: 'Complete your first trip',
        icon: 'flight_takeoff',
        points: 100,
        rarity: AchievementRarity.common,
      ),
      Achievement(
        id: 'budget_saver',
        title: 'Budget Master',
        description: 'Save ₹5,000 through smart planning',
        icon: 'savings',
        points: 250,
        rarity: AchievementRarity.rare,
      ),
      Achievement(
        id: 'social_butterfly',
        title: 'Social Traveler',
        description: 'Share 5 trip experiences',
        icon: 'share',
        points: 150,
        rarity: AchievementRarity.uncommon,
      ),
      Achievement(
        id: 'eco_warrior',
        title: 'Eco Warrior',
        description: 'Offset 100kg of CO2 emissions',
        icon: 'eco',
        points: 300,
        rarity: AchievementRarity.epic,
      ),
      Achievement(
        id: 'streak_master',
        title: 'Streak Master',
        description: 'Maintain a 7-day planning streak',
        icon: 'local_fire_department',
        points: 200,
        rarity: AchievementRarity.rare,
      ),
    ];
  }

  static List<Challenge> _getDefaultChallenges() {
    final now = DateTime.now();
    return [
      Challenge(
        id: 'monthly_planner',
        title: 'Monthly Planner',
        description: 'Plan 3 trips this month',
        targetProgress: 3,
        currentProgress: 0,
        rewardPoints: 500,
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
        category: ChallengeCategory.planning,
      ),
      Challenge(
        id: 'budget_optimizer',
        title: 'Budget Optimizer',
        description: 'Save ₹2,000 through optimization',
        targetProgress: 2000,
        currentProgress: 0,
        rewardPoints: 300,
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        category: ChallengeCategory.savings,
      ),
      Challenge(
        id: 'social_sharer',
        title: 'Social Sharer',
        description: 'Share 5 travel stories',
        targetProgress: 5,
        currentProgress: 0,
        rewardPoints: 200,
        startDate: now,
        endDate: now.add(const Duration(days: 14)),
        category: ChallengeCategory.social,
      ),
    ];
  }
}

class UserStats {
  int totalPoints;
  String level;
  int tripsCompleted;
  int currentStreak;
  double totalSaved;
  int tripsShared;
  double carbonOffset;
  DateTime lastActivity;

  UserStats({
    required this.totalPoints,
    required this.level,
    required this.tripsCompleted,
    required this.currentStreak,
    required this.totalSaved,
    required this.tripsShared,
    required this.carbonOffset,
    required this.lastActivity,
  });

  factory UserStats.initial() {
    return UserStats(
      totalPoints: 0,
      level: 'Novice',
      tripsCompleted: 0,
      currentStreak: 0,
      totalSaved: 0,
      tripsShared: 0,
      carbonOffset: 0,
      lastActivity: DateTime.now(),
    );
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalPoints: json['totalPoints'],
      level: json['level'],
      tripsCompleted: json['tripsCompleted'],
      currentStreak: json['currentStreak'],
      totalSaved: json['totalSaved'].toDouble(),
      tripsShared: json['tripsShared'],
      carbonOffset: json['carbonOffset'].toDouble(),
      lastActivity: DateTime.parse(json['lastActivity']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'level': level,
      'tripsCompleted': tripsCompleted,
      'currentStreak': currentStreak,
      'totalSaved': totalSaved,
      'tripsShared': tripsShared,
      'carbonOffset': carbonOffset,
      'lastActivity': lastActivity.toIso8601String(),
    };
  }
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int points;
  final AchievementRarity rarity;
  bool isUnlocked;
  DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.points,
    required this.rarity,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      icon: json['icon'],
      points: json['points'],
      rarity: AchievementRarity.values[json['rarity']],
      isUnlocked: json['isUnlocked'],
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'points': points,
      'rarity': rarity.index,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final int targetProgress;
  int currentProgress;
  final int rewardPoints;
  final DateTime startDate;
  final DateTime endDate;
  final ChallengeCategory category;
  bool isCompleted;
  DateTime? completedAt;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.targetProgress,
    required this.currentProgress,
    required this.rewardPoints,
    required this.startDate,
    required this.endDate,
    required this.category,
    this.isCompleted = false,
    this.completedAt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetProgress: json['targetProgress'],
      currentProgress: json['currentProgress'],
      rewardPoints: json['rewardPoints'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      category: ChallengeCategory.values[json['category']],
      isCompleted: json['isCompleted'],
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetProgress': targetProgress,
      'currentProgress': currentProgress,
      'rewardPoints': rewardPoints,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'category': category.index,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  double get progressPercentage => currentProgress / targetProgress;
}

class Leaderboard {
  final List<LeaderboardEntry> entries;
  final int userRank;
  final int totalParticipants;

  Leaderboard({
    required this.entries,
    required this.userRank,
    required this.totalParticipants,
  });
}

class LeaderboardEntry {
  final int rank;
  final String username;
  final int points;
  final String level;
  final String avatar;

  LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.points,
    required this.level,
    required this.avatar,
  });
}

enum AchievementRarity { common, uncommon, rare, epic, legendary }
enum ChallengeCategory { planning, savings, social, exploration, sustainability }