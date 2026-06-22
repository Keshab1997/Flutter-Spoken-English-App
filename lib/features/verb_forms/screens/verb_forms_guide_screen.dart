import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class VerbFormsGuideScreen extends StatelessWidget {
  const VerbFormsGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verb Forms Guide',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header(context, 'Verb Forms কী?',
              'Verb Forms (ক্রিয়ার রূপ) হচ্ছে ইংরেজি grammar-এর একটি গুরুত্বপূর্ণ অংশ। একটি verb-এর পাঁচটি রূপ (V1-V5) আছে, যা বিভিন্ন tense ও sentence-এ ব্যবহৃত হয়।'),
          _section(context, 'V1 — Base Form (মূল রূপ)', AppColors.primary, [
            _point('ক্রিয়ার মূল বা সাধারণ রূপ'),
            _point('Present Simple Tense-এ ব্যবহৃত (I, You, We, They-এর সাথে)'),
            _point('Imperative Sentence-এ ব্যবহৃত'),
            _point('Modal verbs (can, must, should) -এর পরে ব্যবহৃত'),
            _example(context, 'I walk every morning.', 'আমি প্রতিদিন সকালে হাঁটি।'),
            _example(context, 'They play football.', 'তারা ফুটবল খেলে।'),
            _example(context, 'Please sit down.', 'দয়া করে বসুন।'),
            _example(context, 'You should study hard.', 'তোমার কঠোর পড়া উচিত।'),
          ]),
          _section(context, 'V2 — Past Form (অতীত রূপ)', AppColors.secondary, [
            _point('ক্রিয়ার অতীত রূপ — Past Simple Tense-এ ব্যবহৃত'),
            _point('সাধারণত V1-এর শেষে -ed যোগ করে V2 গঠন করা হয় (Regular verb)'),
            _point('কিছু verb-এর V2 আলাদা রূপ নেয় (Irregular verb)'),
            _example(context, 'I walked yesterday.', 'আমি গতকাল হেঁটেছিলাম।'),
            _example(context, 'She ate an apple.', 'সে একটি আপেল খেয়েছিল।'),
            _example(context, 'They went to school.', 'তারা স্কুলে গিয়েছিল।'),
          ]),
          _section(context, 'V3 — Past Participle (অতীত কৃদন্ত)', AppColors.warning, [
            _point('Perfect Tense-এ ব্যবহৃত (have/has/had + V3)'),
            _point('Passive Voice-এ ব্যবহৃত (be + V3)'),
            _point('Perfect Tense: I have eaten, She had gone'),
            _point('Passive Voice: The book was written'),
            _example(context, 'I have finished my homework.', 'আমি আমার বাড়ির কাজ শেষ করেছি।'),
            _example(context, 'The letter was sent yesterday.', 'চিঠিটি গতকাল পাঠানো হয়েছিল।'),
            _example(context, 'She has never been to London.', 'সে কখনো লন্ডনে যায়নি।'),
          ]),
          _section(context, 'V4 — Present Participle / Gerund (-ing form)', AppColors.info, [
            _point('Continuous Tense-এ ব্যবহৃত (be + V4)'),
            _point('Gerund হিসেবে noun-এর মতো ব্যবহৃত'),
            _point('Continuous: I am reading, They were playing'),
            _point('Gerund: Swimming is fun (সাতার কাটা মজার)'),
            _example(context, 'She is singing a song.', 'সে একটি গান গাইছে।'),
            _example(context, 'They were watching TV.', 'তারা টিভি দেখছিল।'),
            _example(context, 'Reading books is a good habit.', 'বই পড়া একটি ভালো অভ্যাস।'),
          ]),
          _section(context, 'V5 — Third Person Singular Form', AppColors.pinkGradient[0], [
            _point('Present Simple Tense-এ He/She/It-এর সাথে ব্যবহৃত'),
            _point('V1-এর শেষে -s বা -es যোগ করে গঠন করা হয়'),
            _point('He walks, She goes, It runs'),
            _example(context, 'He walks to school every day.', 'সে প্রতিদিন স্কুলে হেঁটে যায়।'),
            _example(context, 'She watches TV at night.', 'সে রাতে টিভি দেখে।'),
            _example(context, 'The baby cries a lot.', 'বাচ্চাটি অনেক কাঁদে।'),
          ]),
          _section(context, 'Regular vs Irregular Verb', AppColors.primary, [
            _point('Regular Verb: V2 এবং V3 -ed যোগ করে গঠিত হয়'),
            _point('Irregular Verb: V2 এবং V3 আলাদা রূপ নেয় (মুখস্থ করতে হয়)'),
            _point(''),
            _point('Regular উদাহরণ:'),
            _example(context, 'Walk → Walked → Walked', 'হাঁটা'),
            _example(context, 'Play → Played → Played', 'খেলা'),
            _example(context, 'Talk → Talked → Talked', 'কথা বলা'),
            _point(''),
            _point('Irregular উদাহরণ:'),
            _example(context, 'Go → Went → Gone', 'যাওয়া'),
            _example(context, 'Eat → Ate → Eaten', 'খাওয়া'),
            _example(context, 'Write → Wrote → Written', 'লেখা'),
          ]),
          _section(context, 'V1-V5 এর সম্পূর্ণ উদাহরণ (Common Verb)', AppColors.secondary, [
            _point('Verb: Eat (খাওয়া)'),
            _example(context, 'V1 — eat : I eat rice.', 'আমি ভাত খাই।'),
            _example(context, 'V2 — ate : She ate an apple.', 'সে একটি আপেল খেয়েছিল।'),
            _example(context, 'V3 — eaten : They have eaten lunch.', 'তারা লাঞ্চ খেয়েছে।'),
            _example(context, 'V4 — eating : He is eating now.', 'সে এখন খাচ্ছে।'),
            _example(context, 'V5 — eats : He eats fish.', 'সে মাছ খায়।'),
            const SizedBox(height: 8),
            _point('Verb: Write (লেখা)'),
            _example(context, 'V1 — write : I write letters.', 'আমি চিঠি লিখি।'),
            _example(context, 'V2 — wrote : She wrote a poem.', 'সে একটি কবিতা লিখেছিল।'),
            _example(context, 'V3 — written : He has written a book.', 'সে একটি বই লিখেছে।'),
            _example(context, 'V4 — writing : They are writing now.', 'তারা এখন লিখছে।'),
            _example(context, 'V5 — writes : He writes stories.', 'সে গল্প লেখে।'),
          ]),
          _section(context, 'Verb Forms মনে রাখার টিপস', AppColors.warning, [
            _point('Irregular verb-গুলোর V2 ও V3 মুখস্থ করতে হবে'),
            _point('V4 সবসময় V1 + -ing (যেমন: eat → eating)'),
            _point('V5 সবসময় He/She/It-এর সাথে, V1 + -s/-es'),
            _point('Regular verb-এর V2 ও V3 একই (V1 + -ed)'),
            _point('নিচের ক্যাটাগরিগুলো থেকে শুরু করে ধীরে ধীরে সব verb শিখুন'),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5)),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, Color color, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 17, color: color)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _point(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.start),
          ),
        ],
      ),
    );
  }

  Widget _example(BuildContext context, String eng, String bangla) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 6, left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: (isDark ? AppColors.borderDark : AppColors.borderLight)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(eng,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87)),
          ),
          const SizedBox(width: 8),
          Text(bangla,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}
