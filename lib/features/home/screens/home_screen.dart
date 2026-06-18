import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigateToTab;
  final VoidCallback? onNavigateToLessons;

  const HomeScreen({
    super.key,
    this.onNavigateToTab,
    this.onNavigateToLessons,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isWordFavorited = false;
  bool _isSpeaking = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _speakWord() {
    setState(() {
      _isSpeaking = true;
    });
    // Simulate speech audio playing with a short active visual feedback
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSpeaking = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.translate_rounded,
              color: AppColors.primary,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'SpeakEasy',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, size: 28),
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => widget.onNavigateToTab?.call(4), // Profile tab
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text(
                  'U',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Section
              _buildGreetingSection(theme),
              const SizedBox(height: 20),

              // Progress Card
              _buildProgressCard(theme, isDark),
              const SizedBox(height: 24),

              // Today's Word Card
              _buildTodaysWordCard(theme, isDark),
              const SizedBox(height: 24),

              // AI Teacher Banner
              _buildAiTeacherBanner(theme),
              const SizedBox(height: 24),

              // Continue Learning Section
              _buildContinueLearningSection(theme, isDark),
              const SizedBox(height: 24),

              // Daily Challenge Card
              _buildDailyChallengeCard(theme),
              const SizedBox(height: 24),

              // Quick Practice Section
              _buildQuickPracticeSection(theme, isDark),
              const SizedBox(height: 24),

              // Achievements Section
              _buildAchievementsSection(theme, isDark),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // GREETING SECTION
  Widget _buildGreetingSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Good Morning, User ',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 26,
              ),
            ),
            const Text(
              '👋',
              style: TextStyle(fontSize: 26),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Keep practicing English every day.',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // PROGRESS CARD
  Widget _buildProgressCard(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Overall Progress',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Text('🔥 ', style: TextStyle(fontSize: 12)),
                    Text(
                      '7 Days Streak',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '60%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Progress Today',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  color: Colors.white.withOpacity(0.25),
                ),
                FractionallySizedBox(
                  widthFactor: 0.60,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('📚 ', style: TextStyle(fontSize: 14)),
              Text(
                '15 Lessons Completed',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Text('🎯 ', style: TextStyle(fontSize: 14)),
              Text(
                'Target: 25',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TODAY'S WORD CARD
  Widget _buildTodaysWordCard(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: AppColors.accent.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(
                    Icons.wb_sunny_outlined,
                    color: AppColors.accent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "TODAY'S WORD",
                    style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Beautiful',
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '/ˈbjuːtɪfl/',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          // Speaker Button
                          GestureDetector(
                            onTap: _speakWord,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _isSpeaking
                                    ? AppColors.primary.withOpacity(0.2)
                                    : (isDark ? Colors.grey[800] : Colors.grey[100]),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isSpeaking ? Icons.volume_up_rounded : Icons.volume_mute_rounded,
                                color: _isSpeaking ? AppColors.primary : (isDark ? Colors.white70 : Colors.black54),
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Favorite Button
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isWordFavorited = !_isWordFavorited;
                              });
                              _animationController.forward().then((_) => _animationController.reverse());
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    _isWordFavorited ? 'Added to favorites' : 'Removed from favorites',
                                  ),
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _isWordFavorited
                                      ? Colors.red.withOpacity(0.1)
                                      : (isDark ? Colors.grey[800] : Colors.grey[100]),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isWordFavorited ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                  color: _isWordFavorited ? Colors.red : (isDark ? Colors.white70 : Colors.black54),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  const Text(
                    'Meaning (অর্থ):',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'সুন্দর',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Example Sentence:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[900]?.withOpacity(0.5) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'She is a beautiful girl.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CONTINUE LEARNING
  Widget _buildContinueLearningSection(ThemeData theme, bool isDark) {
    final courses = [
      {
        'title': 'Beginner English',
        'progress': 0.8,
        'lessons': '12/15 Lessons',
        'gradient': AppColors.primaryGradient,
        'emoji': '🌱',
      },
      {
        'title': 'Grammar Basics',
        'progress': 0.4,
        'lessons': '8/20 Lessons',
        'gradient': AppColors.purpleGradient,
        'emoji': '✏️',
      },
      {
        'title': 'Daily Conversation',
        'progress': 0.15,
        'lessons': '3/20 Lessons',
        'gradient': AppColors.secondaryGradient,
        'emoji': '💬',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Continue Learning',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            TextButton(
              onPressed: () => widget.onNavigateToLessons?.call(),
              child: const Row(
                children: [
                  Text('See All'),
                  Icon(Icons.chevron_right_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: courses.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final course = courses[index];
              final double progressVal = course['progress'] as double;
              final listGradient = course['gradient'] as List<Color>;

              return GestureDetector(
                onTap: () => widget.onNavigateToLessons?.call(),
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: listGradient),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              course['emoji'] as String,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          Text(
                            '${(progressVal * 100).toInt()}%',
                            style: TextStyle(
                              color: listGradient[0],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        course['title'] as String,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        course['lessons'] as String,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Stack(
                          children: [
                            Container(
                              height: 6,
                              width: double.infinity,
                              color: isDark ? Colors.grey[800] : Colors.grey[200],
                            ),
                            FractionallySizedBox(
                              widthFactor: progressVal,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: listGradient),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // QUICK PRACTICE GRID
  Widget _buildQuickPracticeSection(ThemeData theme, bool isDark) {
    final practiceItems = [
      {
        'title': 'Vocabulary',
        'desc': 'বই বা Word Illustration',
        'icon': Icons.menu_book_rounded,
        'gradient': AppColors.primaryGradient,
        'tab': 2, // Practice/Learn tab
      },
      {
        'title': 'Grammar',
        'desc': 'Notebook + Pencil',
        'icon': Icons.edit_note_rounded,
        'gradient': AppColors.purpleGradient,
        'tab': 1, // Learn tab
      },
      {
        'title': 'Conversation',
        'desc': 'দুইজন কথা বলছে',
        'icon': Icons.forum_rounded,
        'gradient': AppColors.secondaryGradient,
        'tab': 2, // Practice tab
      },
      {
        'title': 'Listening',
        'desc': 'Headphone',
        'icon': Icons.headset_rounded,
        'gradient': AppColors.infoGradient,
        'tab': 2,
      },
      {
        'title': 'Speaking',
        'desc': 'Microphone',
        'icon': Icons.mic_rounded,
        'gradient': AppColors.pinkGradient,
        'tab': 2,
      },
      {
        'title': 'Quiz',
        'desc': 'Exam Paper',
        'icon': Icons.quiz_rounded,
        'gradient': AppColors.accentGradient,
        'tab': 2,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Practice',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.45,
          ),
          itemCount: practiceItems.length,
          itemBuilder: (context, index) {
            final item = practiceItems[index];
            final itemIcon = item['icon'] as IconData;
            final itemGrad = item['gradient'] as List<Color>;

            return GestureDetector(
              onTap: () {
                widget.onNavigateToTab?.call(item['tab'] as int);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.01),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: itemGrad[0].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        itemIcon,
                        color: itemGrad[0],
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['title'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // DAILY CHALLENGE CARD
  Widget _buildDailyChallengeCard(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFF8C00), const Color(0xFFFF4500)], // Fire Gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background accent circle decoration
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.local_fire_department_rounded,
              size: 130,
              color: Colors.white.withOpacity(0.12),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "DAILY CHALLENGE",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Text('🔥', style: TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Today's Challenge",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Speak 10 English sentences",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    widget.onNavigateToTab?.call(2); // Practice Screen / Speaking
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Launching Daily Speaking Challenge..."),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.deepOrange,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Start Now',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // AI TEACHER BANNER
  Widget _buildAiTeacherBanner(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.smart_toy_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI TEACHER',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Practice with AI Teacher',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Get real-time feedback on speaking & grammar.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => widget.onNavigateToTab?.call(3), // AI Teacher Tab
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.5),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Start Chat',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // AI Robot Illustration (Custom Icon Design inside a structured widget)
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.face_retouching_natural_rounded,
              color: AppColors.primary,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  // ACHIEVEMENTS SECTION
  Widget _buildAchievementsSection(ThemeData theme, bool isDark) {
    final badges = [
      {
        'title': 'Beginner Badge',
        'icon': Icons.emoji_events_rounded,
        'color': Colors.amber,
        'description': 'First steps completed',
      },
      {
        'title': '7 Day Streak',
        'icon': Icons.local_fire_department_rounded,
        'color': Colors.deepOrange,
        'description': 'Daily practitioner',
      },
      {
        'title': 'Vocabulary Master',
        'icon': Icons.stars_rounded,
        'color': Colors.blue,
        'description': 'Learned 50 words',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: badges.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final badge = badges[index];
              final badgeColor = badge['color'] as Color;

              return Container(
                width: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        badge['icon'] as IconData,
                        color: badgeColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            badge['title'] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            badge['description'] as String,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 11,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
