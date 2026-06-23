import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/game/sound_provider.dart';
import '../../../services/hive_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late int _timerSeconds;
  late int _questionCount;
  late String _difficulty;

  @override
  void initState() {
    super.initState();
    _timerSeconds = HiveService.getGameTimerSeconds();
    _questionCount = HiveService.getGameQuestionCount();
    _difficulty = HiveService.getGameDifficulty();
  }

  String _formatTimer(int s) {
    if (s <= 0) return 'No timer';
    final m = s ~/ 60;
    final r = s % 60;
    return m > 0 ? '$m:${r.toString().padLeft(2, '0')}' : '${r}s';
  }

  String _difficultyLabel(String d) {
    switch (d) {
      case 'easy':
        return 'Easy';
      case 'intermediate':
        return 'Intermediate';
      case 'hard':
        return 'Hard';
      default:
        return 'Easy';
    }
  }

  Future<void> _pickTimer() async {
    const options = [0, 30, 45, 60, 90, 120];
    final selected = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Default Timer'),
        children: options.map((s) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, s),
            child: Row(
              children: [
                Icon(
                  s == _timerSeconds ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(_formatTimer(s)),
              ],
            ),
          );
        }).toList(),
      ),
    );
    if (selected != null && selected != _timerSeconds) {
      await HiveService.setGameTimerSeconds(selected);
      setState(() => _timerSeconds = selected);
    }
  }

  Future<void> _pickQuestionCount() async {
    const options = [5, 10, 15, 20, 25];
    final selected = await showDialog<int>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Questions Per Game'),
        children: options.map((c) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, c),
            child: Row(
              children: [
                Icon(
                  c == _questionCount ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text('$c questions'),
              ],
            ),
          );
        }).toList(),
      ),
    );
    if (selected != null && selected != _questionCount) {
      await HiveService.setGameQuestionCount(selected);
      setState(() => _questionCount = selected);
    }
  }

  Future<void> _pickDifficulty() async {
    const options = ['easy', 'intermediate', 'hard'];
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Default Difficulty'),
        children: options.map((d) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, d),
            child: Row(
              children: [
                Icon(
                  d == _difficulty ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(_difficultyLabel(d)),
              ],
            ),
          );
        }).toList(),
      ),
    );
    if (selected != null && selected != _difficulty) {
      await HiveService.setGameDifficulty(selected);
      setState(() => _difficulty = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final soundState = ref.watch(soundProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _SettingsSection(
            title: 'Appearance',
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark theme'),
                value: themeState.isDark,
                onChanged: (value) => ref.read(themeProvider.notifier).setThemeMode(
                  value ? ThemeMode.dark : ThemeMode.light,
                ),
                secondary: Icon(themeState.isDark ? Icons.dark_mode : Icons.light_mode, color: AppColors.primary),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Sound Section
          _SettingsSection(
            title: 'Sound',
            children: [
              SwitchListTile(
                title: const Text('Sound Effects'),
                subtitle: const Text('Enable game sounds'),
                value: !soundState.isMuted,
                onChanged: (value) {
                  ref.read(soundProvider.notifier).setMuted(!value);
                  if (value) ref.read(soundProvider.notifier).playButtonTap();
                },
                secondary: Icon(soundState.isMuted ? Icons.volume_off : Icons.volume_up, color: AppColors.primary),
              ),
              if (!soundState.isMuted)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.volume_down, size: 20),
                      Expanded(
                        child: Slider(
                          value: soundState.volume,
                          min: 0.0,
                          max: 1.0,
                          onChanged: (value) => ref.read(soundProvider.notifier).setVolume(value),
                          activeColor: AppColors.primary,
                        ),
                      ),
                      const Icon(Icons.volume_up, size: 20),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Game Settings Section
          _SettingsSection(
            title: 'Game Settings',
            children: [
              ListTile(
                leading: const Icon(Icons.timer, color: AppColors.primary),
                title: const Text('Default Timer'),
                subtitle: Text(_formatTimer(_timerSeconds)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickTimer,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.quiz, color: AppColors.primary),
                title: const Text('Questions Per Game'),
                subtitle: Text('$_questionCount questions'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickQuestionCount,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.tune, color: AppColors.primary),
                title: const Text('Default Difficulty'),
                subtitle: Text(_difficultyLabel(_difficulty)),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickDifficulty,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Account Section
          _SettingsSection(
            title: 'Account',
            children: [
              ListTile(
                leading: const Icon(Icons.sync, color: AppColors.primary),
                title: const Text('Sync Data'),
                subtitle: const Text('Sync with Firebase'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sync feature coming soon!')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: AppColors.error),
                title: const Text('Clear Local Data'),
                subtitle: const Text('Delete all cached data'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showClearDataDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // About Section
          _SettingsSection(
            title: 'About',
            children: [
              const ListTile(
                leading: Icon(Icons.info, color: AppColors.primary),
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.help, color: AppColors.primary),
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Help page coming soon!')),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Reset Progress Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showResetProgressDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Reset All Progress', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Local Data?'),
        content: const Text('This will delete all cached data. Your progress will be preserved if synced.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await HiveService.clearAllCaches();
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Local data cleared')),
                );
              }
            },
            child: const Text('Clear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showResetProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Progress?'),
        content: const Text('This will permanently delete all your progress, XP, coins, and achievements. This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await HiveService.clearAllCaches();
              if (context.mounted) Navigator.pop(context);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Progress reset')),
                );
              }
            },
            child: const Text('Reset', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          ...children,
        ],
      ),
    );
  }
}
