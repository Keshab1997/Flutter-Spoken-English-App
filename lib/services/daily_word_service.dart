import 'package:cloud_firestore/cloud_firestore.dart';

class DailyWordData {
  final String word;
  final String banglaMeaning;
  final String exampleSentence;
  final String? pronunciation;

  const DailyWordData({
    required this.word,
    required this.banglaMeaning,
    required this.exampleSentence,
    this.pronunciation,
  });

  factory DailyWordData.fromMap(Map<String, dynamic> map) {
    return DailyWordData(
      word: map['word'] as String? ?? '',
      banglaMeaning: map['banglaMeaning'] as String? ?? '',
      exampleSentence: map['example'] as String? ?? '',
      pronunciation: map['pronunciation'] as String?,
    );
  }
}

class DailyWordService {
  /// Fallback vocabulary pool used when Firestore has no word for today.
  static const List<DailyWordData> _fallbackWords = [
    DailyWordData(word: 'Eloquent', banglaMeaning: 'স্পষ্টভাষী', exampleSentence: 'She gave an eloquent speech.'),
    DailyWordData(word: 'Resilient', banglaMeaning: 'স্থিতিস্থাপক', exampleSentence: 'Children are remarkably resilient.'),
    DailyWordData(word: 'Ambition', banglaMeaning: 'উচ্চাকাঙ্ক্ষা', exampleSentence: 'His ambition drove him to succeed.'),
    DailyWordData(word: 'Diligent', banglaMeaning: 'পরিশ্রমী', exampleSentence: 'Be diligent in your studies.'),
    DailyWordData(word: 'Empathy', banglaMeaning: 'সহমর্মিতা', exampleSentence: 'She showed great empathy for others.'),
    DailyWordData(word: 'Gratitude', banglaMeaning: 'কৃতজ্ঞতা', exampleSentence: 'Express gratitude every day.'),
    DailyWordData(word: 'Persevere', banglaMeaning: 'অটল থাকা', exampleSentence: 'Persevere through challenges.'),
    DailyWordData(word: 'Confident', banglaMeaning: 'আত্মবিশ্বাসী', exampleSentence: 'Be confident in your abilities.'),
    DailyWordData(word: 'Curious', banglaMeaning: 'কৌতূহলী', exampleSentence: 'Stay curious about the world.'),
    DailyWordData(word: 'Generous', banglaMeaning: 'উদার', exampleSentence: 'Be generous with your time.'),
    DailyWordData(word: 'Humble', banglaMeaning: 'বিনয়ী', exampleSentence: 'Stay humble and kind.'),
    DailyWordData(word: 'Optimistic', banglaMeaning: 'আশাবাদী', exampleSentence: 'Stay optimistic about the future.'),
    DailyWordData(word: 'Patient', banglaMeaning: 'ধৈর্যশীল', exampleSentence: 'Be patient with yourself.'),
    DailyWordData(word: 'Sincere', banglaMeaning: 'আন্তরিক', exampleSentence: 'She gave a sincere apology.'),
    DailyWordData(word: 'Thoughtful', banglaMeaning: 'চিন্তাশীল', exampleSentence: 'That was a thoughtful gesture.'),
    DailyWordData(word: 'Adaptable', banglaMeaning: 'খাপখাওয়ানো', exampleSentence: 'Be adaptable to change.'),
    DailyWordData(word: 'Brave', banglaMeaning: 'সাহসী', exampleSentence: 'Be brave and take risks.'),
    DailyWordData(word: 'Creative', banglaMeaning: 'সৃজনশীল', exampleSentence: 'Think creative thoughts.'),
    DailyWordData(word: 'Determined', banglaMeaning: 'দৃঢ়প্রতিজ্ঞ', exampleSentence: 'She was determined to succeed.'),
    DailyWordData(word: 'Enthusiastic', banglaMeaning: 'উৎসাহী', exampleSentence: 'Be enthusiastic about learning.'),
    DailyWordData(word: 'Friendly', banglaMeaning: 'বন্ধুত্বপূর্ণ', exampleSentence: 'Stay friendly to everyone.'),
    DailyWordData(word: 'Honest', banglaMeaning: 'সৎ', exampleSentence: 'Always be honest.'),
    DailyWordData(word: 'Innovative', banglaMeaning: 'উদ্ভাবনী', exampleSentence: 'Think innovative solutions.'),
    DailyWordData(word: 'Joyful', banglaMeaning: 'আনন্দিত', exampleSentence: 'Find joyful moments every day.'),
    DailyWordData(word: 'Kind', banglaMeaning: 'দয়ালু', exampleSentence: 'Be kind to yourself and others.'),
    DailyWordData(word: 'Loyal', banglaMeaning: 'বিশ্বস্ত', exampleSentence: 'Stay loyal to your values.'),
    DailyWordData(word: 'Mindful', banglaMeaning: 'সচেতন', exampleSentence: 'Be mindful of the present.'),
    DailyWordData(word: 'Noble', banglaMeaning: 'মহৎ', exampleSentence: 'That was a noble cause.'),
    DailyWordData(word: 'Organized', banglaMeaning: 'সংগঠিত', exampleSentence: 'Stay organized and focused.'),
    DailyWordData(word: 'Passionate', banglaMeaning: 'আবেগী', exampleSentence: 'Follow your passionate dreams.'),
  ];

  /// Returns the word of the day. Tries Firestore first; falls back to a
  /// deterministic selection from the local pool based on the current date.
  static Future<DailyWordData> getTodayWord() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('daily_words')
          .doc(_todayDateString())
          .get();
      if (doc.exists && doc.data() != null) {
        return DailyWordData.fromMap(doc.data()!);
      }
    } catch (_) {
      // Firestore unavailable — use local fallback
    }

    // Deterministic selection from local pool using day-of-year
    final dayOfYear = DateTime.now().difference(
      DateTime(DateTime.now().year, 1, 1),
    ).inDays;
    return _fallbackWords[dayOfYear % _fallbackWords.length];
  }

  /// Returns today's date as "yyyy-MM-dd" for Firestore document lookup.
  static String _todayDateString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
