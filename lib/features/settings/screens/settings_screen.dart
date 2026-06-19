import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/hive_service.dart';
import '../../../services/ai_service.dart';
import '../../../providers/theme_provider.dart';
import 'api_setup_guide_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  String _selectedLanguage = 'English (US)';
  List<Map<String, dynamic>> _aiKeys = [];

  List<String> get _modelOptions => [
    'gpt-4o-mini',
    'gpt-4o',
    'gpt-4.1-mini',
    'gpt-5-mini',
    'gpt-5-nano',
    'deepseek-v3',
    'deepseek-r1',
    'gemini-2.5-flash',
    'claude-sonnet-4-6',
  ];

  @override
  void initState() {
    super.initState();
    _darkMode = HiveService.isDarkMode();
    _notifications = HiveService.isNotificationEnabled();
    _loadAiKeys();
  }

  void _loadAiKeys() {
    setState(() => _aiKeys = HiveService.getAiKeys());
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
                  ref.read(themeModeProvider.notifier).state =
                      val ? ThemeMode.dark : ThemeMode.light;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('AI Teacher', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white60 : Colors.black45)),
                TextButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ApiSetupGuideScreen())),
                  icon: const Icon(Icons.help_outline_rounded, size: 16, color: AppColors.primary),
                  label: const Text('How to get API key?', style: TextStyle(fontSize: 12, color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildAiKeysList(isDark),
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

  Widget _buildAiKeysList(bool isDark) {
    return _buildSettingsCard([
      if (_aiKeys.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Center(
            child: Text('No API keys saved yet. Tap below to add one.',
                style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13)),
          ),
        )
      else
        ..._aiKeys.asMap().entries.map((entry) {
          final idx = entry.key;
          final key = entry.value;
          final isActive = key['isActive'] == true;
          final maskedKey = _maskKey(key['key'] as String);
          final name = key['name'] as String? ?? 'Key ${idx + 1}';
          return Column(
            children: [
              if (idx > 0) const Divider(height: 1),
              InkWell(
                onTap: () {
                  if (!isActive) {
                    HiveService.setActiveAiKey(key['id'] as String);
                    _loadAiKeys();
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary.withOpacity(0.15) : (isDark ? Colors.white10 : Colors.white24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.vpn_key_rounded,
                            color: isActive ? AppColors.primary : Colors.grey, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                if (isActive) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text('Active', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(maskedKey, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black45)),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert_rounded, size: 18, color: isDark ? Colors.white54 : Colors.black54),
                        onSelected: (val) async {
                          if (val == 'edit') {
                            _showAddKeyDialog(existingKey: key);
                          } else if (val == 'test') {
                            _testKey(key['id'] as String);
                          } else if (val == 'delete') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete Key'),
                                content: Text('Delete "$name"?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                  TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await HiveService.deleteAiKey(key['id'] as String);
                              _loadAiKeys();
                            }
                          }
                        },
                        itemBuilder: (_) => [
                          const PopupMenuItem(value: 'test', child: Row(children: [Icon(Icons.wifi_find_rounded, size: 18), SizedBox(width: 8), Text('Test')])),
                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_rounded, size: 18), SizedBox(width: 8), Text('Edit')])),
                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      const Divider(height: 1),
      InkWell(
        onTap: () => _showAddKeyDialog(),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 6),
              const Text('Add API Key', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
        ),
      ),
    ]);
  }

  void _showAddKeyDialog({Map<String, dynamic>? existingKey}) {
    final nameCtl = TextEditingController(text: existingKey?['name'] as String? ?? '');
    final keyCtl = TextEditingController(text: existingKey?['key'] as String? ?? '');
    final urlCtl = TextEditingController(text: existingKey?['baseUrl'] as String? ?? 'https://api.chatanywhere.tech/v1');
    String selectedModel = existingKey?['model'] as String? ?? 'gpt-4o-mini';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) => Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(existingKey != null ? 'Edit API Key' : 'Add API Key',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameCtl,
                    decoration: InputDecoration(
                      labelText: 'Key Name',
                      hintText: 'e.g. ChatAnywhere Free',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: keyCtl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'API Key',
                      hintText: 'sk-...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: urlCtl,
                    decoration: InputDecoration(
                      labelText: 'Base URL',
                      hintText: 'https://api.chatanywhere.tech/v1',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () {
                      showModalBottomSheet(
                        context: ctx,
                        builder: (mctx) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _modelOptions.map((m) {
                            return ListTile(
                              title: Text(m),
                              trailing: m == selectedModel ? const Icon(Icons.check, color: AppColors.primary) : null,
                              onTap: () {
                                setDialogState(() => selectedModel = m);
                                Navigator.pop(mctx);
                              },
                            );
                          }).toList(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.model_training_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(selectedModel, style: const TextStyle(fontSize: 14)),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        final id = existingKey?['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString();
                        final config = {
                          'id': id,
                          'name': nameCtl.text.trim().isEmpty ? 'Key ${_aiKeys.length + 1}' : nameCtl.text.trim(),
                          'key': keyCtl.text.trim(),
                          'baseUrl': urlCtl.text.trim().isEmpty ? 'https://api.chatanywhere.tech/v1' : urlCtl.text.trim(),
                          'model': selectedModel,
                          'isActive': existingKey?['isActive'] == true || _aiKeys.isEmpty,
                        };
                        await HiveService.saveAiKey(config);
                        if (_aiKeys.isEmpty && config['isActive'] == true) {
                          await HiveService.setActiveAiKey(id);
                        }
                        Navigator.pop(ctx);
                        _loadAiKeys();
                      },
                      child: Text(existingKey != null ? 'Save Changes' : 'Add Key'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _testKey(String id) async {
    final active = HiveService.getActiveAiKey();
    if (active?['id'] != id) {
      await HiveService.setActiveAiKey(id);
      _loadAiKeys();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Testing connection...'), behavior: SnackBarBehavior.floating),
    );
    final ok = await AIService().testConnection();
    if (mounted) {
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection successful!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection failed. Check API key or URL.'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  String _maskKey(String key) {
    if (key.length <= 8) return '****';
    return '${key.substring(0, 4)}...${key.substring(key.length - 4)}';
  }
}
