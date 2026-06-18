import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/hive_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  String _selectedLanguage = 'English (US)';

  @override
  void initState() {
    super.initState();
    _darkMode = HiveService.isDarkMode();
    _notifications = HiveService.isNotificationEnabled();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w900)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Appearance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white60 : Colors.black45)),
            const SizedBox(height: 8),
            _buildSettingsCard([
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Switch between light and dark theme'),
                secondary: Icon(_darkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppColors.primary),
                value: _darkMode,
                onChanged: (val) {
                  setState(() => _darkMode = val);
                  HiveService.setDarkMode(val);
                },
                activeColor: AppColors.primary,
              ),
            ]),
            const SizedBox(height: 24),
            Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white60 : Colors.black45)),
            const SizedBox(height: 8),
            _buildSettingsCard([
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Daily word and practice reminders'),
                secondary: const Icon(Icons.notifications_none_rounded, color: AppColors.primary),
                value: _notifications,
                onChanged: (val) {
                  setState(() => _notifications = val);
                  HiveService.setNotificationEnabled(val);
                },
                activeColor: AppColors.primary,
              ),
            ]),
            const SizedBox(height: 24),
            Text('Language', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white60 : Colors.black45)),
            const SizedBox(height: 8),
            _buildSettingsCard([
              ListTile(
                leading: const Icon(Icons.language_rounded, color: AppColors.primary),
                title: const Text('Learning Language'),
                subtitle: Text(_selectedLanguage),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: ['English (US)', 'English (UK)', 'English (AU)'].map((lang) {
                        return ListTile(
                          title: Text(lang),
                          trailing: lang == _selectedLanguage ? const Icon(Icons.check, color: AppColors.primary) : null,
                          onTap: () {
                            setState(() => _selectedLanguage = lang);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ]),
            const SizedBox(height: 24),
            Text('Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white60 : Colors.black45)),
            const SizedBox(height: 8),
            _buildSettingsCard([
              ListTile(
                leading: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                title: const Text('Edit Profile'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {},
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.security_rounded, color: AppColors.primary),
                title: const Text('Privacy & Security'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () {},
              ),
            ]),
            const SizedBox(height: 24),
            Text('About', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white60 : Colors.black45)),
            const SizedBox(height: 8),
            _buildSettingsCard([
              const ListTile(
                leading: Icon(Icons.info_outline_rounded, color: AppColors.primary),
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(children: children),
    );
  }
}
