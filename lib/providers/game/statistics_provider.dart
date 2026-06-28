import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/statistics_service.dart';
import '../../services/streak_service.dart';
import '../../repositories/statistics_repository.dart';
import '../../repositories/progress_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Statistics State ──

class StatisticsState {
  // Overall counts
  final int totalGamesPlayed;
  final int totalCorrectAnswers;
  final int totalWrongAnswers;
  final double overallAccuracy;

  // Rewards
  final int totalEarnedXP;
  final int totalEarnedCoins;

  // Current live values (mirrored from progress so the screen has
  // them without needing to also watch xpProvider/coinProvider).
  final int currentXP;
  final int currentLevel;
  final int currentCoins;
  final int currentStreak;
  final int bestStreak;

  // Performance
  final int highestScore;
  final double averageScore;
  final String performanceRating;

  // Phase 18 additions
  final int bossWins;
  final int dailyChallengeWins;
  final int timePlayedSeconds;
  final String timePlayedFormatted;

  // Loading / error
  final bool isLoading;

  const StatisticsState({
    this.totalGamesPlayed = 0,
    this.totalCorrectAnswers = 0,
    this.totalWrongAnswers = 0,
    this.overallAccuracy = 0.0,
    this.totalEarnedXP = 0,
    this.totalEarnedCoins = 0,
    this.currentXP = 0,
    this.currentLevel = 1,
    this.currentCoins = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.highestScore = 0,
    this.averageScore = 0.0,
    this.performanceRating = 'Needs Practice',
    this.bossWins = 0,
    this.dailyChallengeWins = 0,
    this.timePlayedSeconds = 0,
    this.timePlayedFormatted = '0m',
    this.isLoading = false,
  });

  StatisticsState copyWith({
    int? totalGamesPlayed,
    int? totalCorrectAnswers,
    int? totalWrongAnswers,
    double? overallAccuracy,
    int? totalEarnedXP,
    int? totalEarnedCoins,
    int? currentXP,
    int? currentLevel,
    int? currentCoins,
    int? currentStreak,
    int? bestStreak,
    int? highestScore,
    double? averageScore,
    String? performanceRating,
    int? bossWins,
    int? dailyChallengeWins,
    int? timePlayedSeconds,
    String? timePlayedFormatted,
    bool? isLoading,
  }) {
    return StatisticsState(
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      totalWrongAnswers: totalWrongAnswers ?? this.totalWrongAnswers,
      overallAccuracy: overallAccuracy ?? this.overallAccuracy,
      totalEarnedXP: totalEarnedXP ?? this.totalEarnedXP,
      totalEarnedCoins: totalEarnedCoins ?? this.totalEarnedCoins,
      currentXP: currentXP ?? this.currentXP,
      currentLevel: currentLevel ?? this.currentLevel,
      currentCoins: currentCoins ?? this.currentCoins,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      highestScore: highestScore ?? this.highestScore,
      averageScore: averageScore ?? this.averageScore,
      performanceRating: performanceRating ?? this.performanceRating,
      bossWins: bossWins ?? this.bossWins,
      dailyChallengeWins: dailyChallengeWins ?? this.dailyChallengeWins,
      timePlayedSeconds: timePlayedSeconds ?? this.timePlayedSeconds,
      timePlayedFormatted:
          timePlayedFormatted ?? this.timePlayedFormatted,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get totalQuestionsAnswered => totalCorrectAnswers + totalWrongAnswers;
}

class StatisticsNotifier extends StateNotifier<StatisticsState> {
  final StatisticsService _statisticsService;
  
  // Real-time stream subscriptions
  StreamSubscription<DocumentSnapshot>? _progressSubscription;
  StreamSubscription<DocumentSnapshot>? _metaSubscription;
  StreamSubscription<QuerySnapshot>? _resultsSubscription;
  String? _currentUserId;

  StatisticsNotifier(this._statisticsService) : super(const StatisticsState()) {
    _refresh();
    _startRealtimeListeners();
  }

  /// Initial load from Hive (fast startup).
  Future<void> _refresh() async {
    final summary = await _statisticsService.getFullSummary();
    state = StatisticsState(
      totalGamesPlayed: summary['totalGamesPlayed'] as int,
      totalCorrectAnswers: summary['totalCorrectAnswers'] as int,
      totalWrongAnswers: summary['totalWrongAnswers'] as int,
      overallAccuracy: summary['overallAccuracy'] as double,
      totalEarnedXP: summary['totalEarnedXP'] as int,
      totalEarnedCoins: summary['totalEarnedCoins'] as int,
      currentXP: summary['currentXP'] as int,
      currentLevel: summary['currentLevel'] as int,
      currentCoins: summary['currentCoins'] as int,
      currentStreak: summary['currentStreak'] as int,
      bestStreak: summary['bestStreak'] as int,
      highestScore: summary['highestScore'] as int? ?? 0,
      averageScore: (summary['averageScore'] as num?)?.toDouble() ?? 0.0,
      performanceRating: summary['performanceRating'] as String,
      bossWins: summary['bossWins'] as int? ?? 0,
      dailyChallengeWins: summary['dailyChallengeWins'] as int? ?? 0,
      timePlayedSeconds: summary['timePlayedSeconds'] as int? ?? 0,
      timePlayedFormatted:
          summary['timePlayedFormatted'] as String? ?? '0m',
    );
  }

  void _startRealtimeListeners() {
    _currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (_currentUserId == null || _currentUserId!.isEmpty) return;

    // ── 1. game_progress listener ──
    // Reads currentXP, currentLevel, totalCoins, streak directly from Firebase.
    _progressSubscription = FirebaseFirestore.instance
        .collection('game_progress')
        .doc(_currentUserId!)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) {
        _refresh();
        return;
      }
      final data = snapshot.data();
      if (data == null) {
        _refresh();
        return;
      }

      // Update state directly from Firestore snapshot
      state = state.copyWith(
        currentXP: data['currentXP'] as int? ?? state.currentXP,
        currentLevel: data['currentLevel'] as int? ?? state.currentLevel,
        currentCoins: data['totalCoins'] as int? ?? state.currentCoins,
        currentStreak: data['streak'] as int? ?? state.currentStreak,
        bestStreak: data['longestStreak'] as int? ?? state.bestStreak,
      );

      // Background sync to Hive for offline support
      try {
        await _statisticsService.syncProgressFromFirestoreToHive(_currentUserId!);
      } catch (_) {}
    });

    // ── 2. game_statistics_meta listener ──
    // Reads bossWins, dailyChallengeWins, timePlayedSeconds directly.
    _metaSubscription = FirebaseFirestore.instance
        .collection('game_statistics_meta')
        .doc(_currentUserId!)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) {
        _refresh();
        return;
      }
      final data = snapshot.data();
      if (data == null) {
        _refresh();
        return;
      }

      final int timeSecs = data['timePlayedSeconds'] as int? ?? 0;

      state = state.copyWith(
        bossWins: data['bossWins'] as int? ?? state.bossWins,
        dailyChallengeWins: data['dailyChallengeWins'] as int? ?? state.dailyChallengeWins,
        timePlayedSeconds: timeSecs,
        timePlayedFormatted: _formatTimePlayed(timeSecs),
      );

      // Background sync to Hive
      try {
        await _statisticsService.syncMetaFromFirestoreToHive(_currentUserId!);
      } catch (_) {}
    });

    // ── 3. game_statistics listener ──
    // Aggregates game results (total games, XP, coins, accuracy) directly.
    _resultsSubscription = FirebaseFirestore.instance
        .collection('game_statistics')
        .where('userId', isEqualTo: _currentUserId!)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docChanges.isEmpty) {
        _refresh();
        return;
      }

      // Aggregate directly from Firestore snapshot data
      final docs = snapshot.docs;
      int totalGames = docs.length;
      int totalCorrect = 0;
      int totalWrong = 0;
      int totalXP = 0;
      int totalCoins = 0;
      int highestScore = 0;

      for (final doc in docs) {
        final d = doc.data();
        final correct = d['correctAnswers'] as int? ?? 0;
        final wrong = d['wrongAnswers'] as int? ?? 0;
        totalCorrect += correct;
        totalWrong += wrong;
        totalXP += d['earnedXP'] as int? ?? 0;
        totalCoins += d['earnedCoins'] as int? ?? 0;
        final score = d['score'] as int? ?? 0;
        if (score > highestScore) highestScore = score;
      }

      final totalQuestions = totalCorrect + totalWrong;
      final accuracy = totalQuestions > 0 ? totalCorrect / totalQuestions : 0.0;
      final avgScore = totalGames > 0 ? (totalXP / totalGames) : 0.0;
      final rating = _computeRating(accuracy);

      state = state.copyWith(
        totalGamesPlayed: totalGames,
        totalCorrectAnswers: totalCorrect,
        totalWrongAnswers: totalWrong,
        overallAccuracy: accuracy,
        totalEarnedXP: totalXP,
        totalEarnedCoins: totalCoins,
        highestScore: highestScore,
        averageScore: avgScore,
        performanceRating: rating,
      );

      // Background sync to Hive
      try {
        await _statisticsService.syncResultsFromFirestoreToHive(_currentUserId!);
      } catch (_) {}
    });
  }

  /// Formats seconds into a human-readable string like "12m 30s".
  String _formatTimePlayed(int totalSeconds) {
    if (totalSeconds <= 0) return '0m';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String _computeRating(double accuracy) {
    if (accuracy >= 0.95) return 'Excellent';
    if (accuracy >= 0.85) return 'Great';
    if (accuracy >= 0.70) return 'Good';
    if (accuracy >= 0.50) return 'Fair';
    return 'Needs Practice';
  }

  /// Public refresh hook so providers that mutate progress (XP, coins,
  /// streak, achievements) can call this after their own refresh to
  /// keep the statistics view in sync.
  void refresh() {
    _refresh();
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    _metaSubscription?.cancel();
    _resultsSubscription?.cancel();
    super.dispose();
  }

  // Recording helpers — UI / other providers can call these to keep
  // counters in sync without needing to know about the repository.

  Future<void> recordBossWin() async {
    await _statisticsService.recordBossWin();
    _refresh();
  }

  Future<void> recordDailyChallengeWin() async {
    await _statisticsService.recordDailyChallengeWin();
    _refresh();
  }
}

final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  return StatisticsService(
    statisticsRepository: StatisticsRepository(),
    progressRepository: ProgressRepository(),
    streakService: StreakService(
      progressRepository: ProgressRepository(),
    ),
  );
});

final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, StatisticsState>((ref) {
  final statisticsService = ref.watch(statisticsServiceProvider);
  return StatisticsNotifier(statisticsService);
});
